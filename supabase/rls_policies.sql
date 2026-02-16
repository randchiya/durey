-- ============================================================================
-- DuRey Mobile Game - Row Level Security (RLS) Policies
-- Production-Ready Security Configuration
-- ============================================================================

-- ============================================================================
-- STEP 1: ENABLE ROW LEVEL SECURITY ON ALL TABLES
-- ============================================================================

ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 2: QUESTIONS TABLE POLICIES
-- ============================================================================

-- Policy: Allow public SELECT access ONLY to approved questions
CREATE POLICY "Allow public read approved questions"
    ON public.questions
    FOR SELECT
    USING (is_approved = true);

-- Policy: Admin full access to questions (authenticated users with admin role)
CREATE POLICY "Admin full access questions"
    ON public.questions
    FOR ALL
    TO authenticated
    USING (
        (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
    )
    WITH CHECK (
        (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
    );

-- Policy: Service role has full access (for backend operations)
CREATE POLICY "Service role full access questions"
    ON public.questions
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- STEP 3: VOTES TABLE POLICIES
-- ============================================================================

-- Policy: Allow public INSERT for votes
CREATE POLICY "Allow public vote insert"
    ON public.votes
    FOR INSERT
    WITH CHECK (true);

-- Policy: Allow public SELECT for vote aggregation
CREATE POLICY "Allow public vote read"
    ON public.votes
    FOR SELECT
    USING (true);

-- Policy: Service role has full access
CREATE POLICY "Service role full access votes"
    ON public.votes
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- STEP 4: USERS TABLE POLICIES
-- ============================================================================

-- Policy: Allow public INSERT for user registration
CREATE POLICY "Allow public user registration"
    ON public.users
    FOR INSERT
    WITH CHECK (true);

-- Policy: Allow public SELECT for user data (limited by application logic)
CREATE POLICY "Allow public user read"
    ON public.users
    FOR SELECT
    USING (true);

-- Policy: Service role has full access
CREATE POLICY "Service role full access users"
    ON public.users
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- STEP 5: GAME_SESSIONS TABLE POLICIES
-- ============================================================================

-- Policy: Allow public INSERT for game sessions
CREATE POLICY "Allow public session insert"
    ON public.game_sessions
    FOR INSERT
    WITH CHECK (true);

-- Policy: Allow public SELECT for game sessions
CREATE POLICY "Allow public session read"
    ON public.game_sessions
    FOR SELECT
    USING (true);

-- Policy: Allow public UPDATE for game sessions
CREATE POLICY "Allow public session update"
    ON public.game_sessions
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Policy: Service role has full access
CREATE POLICY "Service role full access sessions"
    ON public.game_sessions
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- STEP 6: RATE LIMITING PROTECTION
-- ============================================================================

-- The unique constraint is already defined in schema.sql:
-- CONSTRAINT unique_vote_per_device_per_question UNIQUE (question_id, device_id)

-- Verify the constraint exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'unique_vote_per_device_per_question'
        AND table_name = 'votes'
    ) THEN
        ALTER TABLE public.votes
        ADD CONSTRAINT unique_vote_per_device_per_question 
        UNIQUE (question_id, device_id);
    END IF;
END $$;

-- ============================================================================
-- STEP 7: ADVANCED RATE LIMITING (OPTIONAL)
-- Prevent rapid repeat voting (within 3 seconds)
-- ============================================================================

-- Create function to prevent vote spam
CREATE OR REPLACE FUNCTION public.prevent_vote_spam()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if device has voted in the last 3 seconds
    IF EXISTS (
        SELECT 1 FROM public.votes
        WHERE device_id = NEW.device_id
        AND created_at > NOW() - INTERVAL '3 seconds'
        AND id != NEW.id
    ) THEN
        RAISE EXCEPTION 'Rate limit exceeded. Please wait before voting again.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to votes table
DROP TRIGGER IF EXISTS vote_rate_limit_trigger ON public.votes;
CREATE TRIGGER vote_rate_limit_trigger
    BEFORE INSERT ON public.votes
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_vote_spam();

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN COALESCE(
        (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin',
        false
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated, anon;

-- ============================================================================
-- RLS POLICIES COMPLETE
-- ============================================================================

-- Security Summary:
-- ✓ RLS enabled on all tables
-- ✓ questions: Public read only if approved, admin full access
-- ✓ votes: Public insert and read allowed
-- ✓ users: Public insert and read allowed
-- ✓ game_sessions: Public insert, read, and update allowed
-- ✓ Duplicate voting prevented by unique constraint
-- ✓ Rapid spam prevented by trigger (3-second cooldown)
-- ✓ All other operations locked by default
