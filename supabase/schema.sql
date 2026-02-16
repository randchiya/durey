-- ============================================================================
-- DuRey Mobile Game - PostgreSQL Database Schema
-- Production-Ready Schema with Security, Indexing, and Relationships
-- All primary keys use UUID for scalability and security
-- ============================================================================

-- Enable required extensions for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- TABLE 1: users
-- Stores user information and device tracking
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_active_at TIMESTAMP WITH TIME ZONE,
    country TEXT,
    app_version TEXT,
    
    -- Constraints
    CONSTRAINT device_id_not_empty CHECK (LENGTH(TRIM(device_id)) > 0)
);

-- Indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_users_last_active_at ON public.users(last_active_at DESC);
CREATE INDEX IF NOT EXISTS idx_users_device_id ON public.users(device_id);

-- Comments for documentation
COMMENT ON TABLE public.users IS 'Stores user profiles and device information for the DuRey game';
COMMENT ON COLUMN public.users.device_id IS 'Unique device identifier for tracking users';
COMMENT ON COLUMN public.users.last_active_at IS 'Last time user was active in the app';

-- ============================================================================
-- TABLE 2: questions
-- Stores game questions with approval workflow
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_text TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL,
    category TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT FALSE NOT NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Constraints
    CONSTRAINT question_text_not_empty CHECK (LENGTH(TRIM(question_text)) > 0),
    CONSTRAINT option_a_not_empty CHECK (LENGTH(TRIM(option_a)) > 0),
    CONSTRAINT option_b_not_empty CHECK (LENGTH(TRIM(option_b)) > 0),
    CONSTRAINT options_must_differ CHECK (TRIM(option_a) != TRIM(option_b)),
    CONSTRAINT category_not_empty CHECK (LENGTH(TRIM(category)) > 0)
);

-- Indexes for questions table
CREATE INDEX IF NOT EXISTS idx_questions_is_approved ON public.questions(is_approved) WHERE is_approved = TRUE;
CREATE INDEX IF NOT EXISTS idx_questions_created_at ON public.questions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_questions_category ON public.questions(category);
CREATE INDEX IF NOT EXISTS idx_questions_created_by ON public.questions(created_by);

-- Composite index for approved questions by category
CREATE INDEX IF NOT EXISTS idx_questions_approved_category ON public.questions(category, created_at DESC) WHERE is_approved = TRUE;

-- Comments for documentation
COMMENT ON TABLE public.questions IS 'Stores game questions with approval workflow';
COMMENT ON COLUMN public.questions.is_approved IS 'Admin approval flag - only approved questions are shown to users';
COMMENT ON COLUMN public.questions.created_by IS 'Reference to admin user who created the question';

-- ============================================================================
-- TABLE 3: votes
-- Stores user votes with duplicate prevention
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    device_id TEXT NOT NULL,
    option_selected TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Constraints
    CONSTRAINT option_selected_valid CHECK (option_selected IN ('A', 'B')),
    CONSTRAINT device_id_not_empty CHECK (LENGTH(TRIM(device_id)) > 0),
    
    -- Unique constraint to prevent duplicate voting
    CONSTRAINT unique_vote_per_device_per_question UNIQUE (question_id, device_id)
);

-- Indexes for votes table
CREATE INDEX IF NOT EXISTS idx_votes_question_id ON public.votes(question_id);
CREATE INDEX IF NOT EXISTS idx_votes_created_at ON public.votes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_votes_device_id ON public.votes(device_id);
CREATE INDEX IF NOT EXISTS idx_votes_user_id ON public.votes(user_id);

-- Composite index for efficient vote counting
CREATE INDEX IF NOT EXISTS idx_votes_question_option ON public.votes(question_id, option_selected);

-- Comments for documentation
COMMENT ON TABLE public.votes IS 'Stores user votes with duplicate prevention per device';
COMMENT ON COLUMN public.votes.device_id IS 'Device identifier to prevent duplicate voting';
COMMENT ON CONSTRAINT unique_vote_per_device_per_question ON public.votes IS 'Ensures one vote per device per question';

-- ============================================================================
-- TABLE 4: game_sessions
-- Tracks user game sessions and engagement metrics
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.game_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    questions_played INTEGER NOT NULL DEFAULT 0,
    session_duration_seconds INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT questions_played_non_negative CHECK (questions_played >= 0),
    CONSTRAINT session_duration_non_negative CHECK (session_duration_seconds IS NULL OR session_duration_seconds >= 0)
);

-- Indexes for game_sessions table
CREATE INDEX IF NOT EXISTS idx_game_sessions_user_id ON public.game_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_game_sessions_created_at ON public.game_sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_sessions_user_created ON public.game_sessions(user_id, created_at DESC);

-- Comments for documentation
COMMENT ON TABLE public.game_sessions IS 'Tracks user game sessions and engagement metrics';
COMMENT ON COLUMN public.game_sessions.questions_played IS 'Number of questions answered in this session';
COMMENT ON COLUMN public.game_sessions.session_duration_seconds IS 'Total duration of the session in seconds';

-- ============================================================================
-- TRIGGER: Update updated_at timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_questions_updated_at
    BEFORE UPDATE ON public.questions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TRIGGER: Update user last_active_at on vote
-- ============================================================================

CREATE OR REPLACE FUNCTION update_user_last_active()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        UPDATE public.users
        SET last_active_at = NOW()
        WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_activity_on_vote
    AFTER INSERT ON public.votes
    FOR EACH ROW
    EXECUTE FUNCTION update_user_last_active();

-- ============================================================================
-- ANALYTICS TABLE: vote_statistics (Materialized View for Performance)
-- ============================================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS public.vote_statistics AS
SELECT 
    q.id AS question_id,
    q.question_text,
    q.option_a,
    q.option_b,
    q.category,
    COUNT(v.id) AS total_votes,
    COUNT(CASE WHEN v.option_selected = 'A' THEN 1 END) AS votes_a,
    COUNT(CASE WHEN v.option_selected = 'B' THEN 1 END) AS votes_b,
    ROUND(
        (COUNT(CASE WHEN v.option_selected = 'A' THEN 1 END)::NUMERIC / 
        NULLIF(COUNT(v.id), 0) * 100), 2
    ) AS percentage_a,
    ROUND(
        (COUNT(CASE WHEN v.option_selected = 'B' THEN 1 END)::NUMERIC / 
        NULLIF(COUNT(v.id), 0) * 100), 2
    ) AS percentage_b,
    MAX(v.created_at) AS last_vote_at
FROM public.questions q
LEFT JOIN public.votes v ON q.id = v.question_id
WHERE q.is_approved = TRUE
GROUP BY q.id, q.question_text, q.option_a, q.option_b, q.category;

-- Index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS idx_vote_statistics_question_id ON public.vote_statistics(question_id);
CREATE INDEX IF NOT EXISTS idx_vote_statistics_category ON public.vote_statistics(category);
CREATE INDEX IF NOT EXISTS idx_vote_statistics_total_votes ON public.vote_statistics(total_votes DESC);

-- Comments
COMMENT ON MATERIALIZED VIEW public.vote_statistics IS 'Pre-computed vote statistics for performance';

-- Refresh function for materialized view
CREATE OR REPLACE FUNCTION refresh_vote_statistics()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.vote_statistics;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SCHEMA VALIDATION COMPLETE
-- ============================================================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON public.vote_statistics TO anon, authenticated;
