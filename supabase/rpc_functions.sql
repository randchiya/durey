-- ============================================================================
-- DuRey Mobile Game - Secure RPC Functions
-- Production-Ready Database Functions for Client-Side Operations
-- ============================================================================

-- ============================================================================
-- FUNCTION: Get random approved question
-- Returns a random approved question that the device hasn't voted on yet
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_random_question(p_device_id TEXT)
RETURNS TABLE (
    id UUID,
    question_text TEXT,
    option_a TEXT,
    option_b TEXT,
    category TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        q.id,
        q.question_text,
        q.option_a,
        q.option_b,
        q.category
    FROM public.questions q
    WHERE q.is_approved = TRUE
    AND q.id NOT IN (
        SELECT v.question_id 
        FROM public.votes v 
        WHERE v.device_id = p_device_id
    )
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_random_question(TEXT) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.get_random_question IS 'Returns a random approved question that the device has not voted on';

-- ============================================================================
-- FUNCTION: Submit vote with validation and rate limiting
-- Securely submits a vote with duplicate prevention and rate limiting
-- ============================================================================

CREATE OR REPLACE FUNCTION public.submit_vote(
    p_question_id UUID,
    p_device_id TEXT,
    p_option_selected TEXT,
    p_user_id UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_vote_id UUID;
    v_rate_limit_exceeded BOOLEAN;
    v_question_exists BOOLEAN;
BEGIN
    -- Validate option
    IF p_option_selected NOT IN ('A', 'B') THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Invalid option selected'
        );
    END IF;
    
    -- Check if question exists and is approved
    SELECT EXISTS(
        SELECT 1 FROM public.questions 
        WHERE id = p_question_id AND is_approved = TRUE
    ) INTO v_question_exists;
    
    IF NOT v_question_exists THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Question not found or not approved'
        );
    END IF;
    
    -- Check rate limiting (max 100 votes per device per hour)
    SELECT EXISTS(
        SELECT 1 FROM public.votes
        WHERE device_id = p_device_id
        AND created_at > NOW() - INTERVAL '1 hour'
        GROUP BY device_id
        HAVING COUNT(*) >= 100
    ) INTO v_rate_limit_exceeded;
    
    IF v_rate_limit_exceeded THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Rate limit exceeded. Please try again later.'
        );
    END IF;
    
    -- Insert vote (will fail if duplicate due to unique constraint)
    BEGIN
        INSERT INTO public.votes (
            question_id,
            device_id,
            option_selected,
            user_id
        ) VALUES (
            p_question_id,
            p_device_id,
            p_option_selected,
            p_user_id
        )
        RETURNING id INTO v_vote_id;
        
        RETURN json_build_object(
            'success', true,
            'vote_id', v_vote_id,
            'message', 'Vote submitted successfully'
        );
    EXCEPTION
        WHEN unique_violation THEN
            RETURN json_build_object(
                'success', false,
                'error', 'You have already voted on this question'
            );
        WHEN OTHERS THEN
            RETURN json_build_object(
                'success', false,
                'error', 'Failed to submit vote'
            );
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.submit_vote(UUID, TEXT, TEXT, UUID) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.submit_vote IS 'Securely submits a vote with validation and rate limiting';

-- ============================================================================
-- FUNCTION: Get vote statistics for a question
-- Returns aggregated vote data with percentages
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_question_stats(p_question_id UUID)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'question_id', q.id,
        'question_text', q.question_text,
        'option_a', q.option_a,
        'option_b', q.option_b,
        'category', q.category,
        'total_votes', COALESCE(COUNT(v.id), 0),
        'votes_a', COALESCE(COUNT(v.id) FILTER (WHERE v.option_selected = 'A'), 0),
        'votes_b', COALESCE(COUNT(v.id) FILTER (WHERE v.option_selected = 'B'), 0),
        'percentage_a', ROUND(
            COALESCE(
                COUNT(v.id) FILTER (WHERE v.option_selected = 'A')::NUMERIC / 
                NULLIF(COUNT(v.id), 0) * 100, 
                0
            ), 2
        ),
        'percentage_b', ROUND(
            COALESCE(
                COUNT(v.id) FILTER (WHERE v.option_selected = 'B')::NUMERIC / 
                NULLIF(COUNT(v.id), 0) * 100, 
                0
            ), 2
        )
    ) INTO v_result
    FROM public.questions q
    LEFT JOIN public.votes v ON q.id = v.question_id
    WHERE q.id = p_question_id AND q.is_approved = TRUE
    GROUP BY q.id, q.question_text, q.option_a, q.option_b, q.category;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_question_stats(UUID) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.get_question_stats IS 'Returns vote statistics for a specific question';

-- ============================================================================
-- FUNCTION: Get trending questions
-- Returns questions with most votes in the last 24 hours
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_trending_questions(p_limit INTEGER DEFAULT 10)
RETURNS TABLE (
    id UUID,
    question_text TEXT,
    option_a TEXT,
    option_b TEXT,
    category TEXT,
    total_votes BIGINT,
    votes_a BIGINT,
    votes_b BIGINT,
    percentage_a NUMERIC,
    percentage_b NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        q.id,
        q.question_text,
        q.option_a,
        q.option_b,
        q.category,
        COUNT(v.id) AS total_votes,
        COUNT(v.id) FILTER (WHERE v.option_selected = 'A') AS votes_a,
        COUNT(v.id) FILTER (WHERE v.option_selected = 'B') AS votes_b,
        ROUND(
            COALESCE(
                COUNT(v.id) FILTER (WHERE v.option_selected = 'A')::NUMERIC / 
                NULLIF(COUNT(v.id), 0) * 100, 
                0
            ), 2
        ) AS percentage_a,
        ROUND(
            COALESCE(
                COUNT(v.id) FILTER (WHERE v.option_selected = 'B')::NUMERIC / 
                NULLIF(COUNT(v.id), 0) * 100, 
                0
            ), 2
        ) AS percentage_b
    FROM public.questions q
    LEFT JOIN public.votes v ON q.id = v.question_id 
        AND v.created_at > NOW() - INTERVAL '24 hours'
    WHERE q.is_approved = TRUE
    GROUP BY q.id, q.question_text, q.option_a, q.option_b, q.category
    HAVING COUNT(v.id) > 0
    ORDER BY COUNT(v.id) DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_trending_questions(INTEGER) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.get_trending_questions IS 'Returns trending questions based on recent vote activity';

-- ============================================================================
-- FUNCTION: Register or get user by device ID
-- Creates a new user or returns existing user by device ID
-- ============================================================================

CREATE OR REPLACE FUNCTION public.register_or_get_user(
    p_device_id TEXT,
    p_country TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_is_new BOOLEAN;
BEGIN
    -- Try to get existing user
    SELECT id INTO v_user_id
    FROM public.users
    WHERE device_id = p_device_id;
    
    IF v_user_id IS NULL THEN
        -- Create new user
        INSERT INTO public.users (device_id, country, app_version, last_active_at)
        VALUES (p_device_id, p_country, p_app_version, NOW())
        RETURNING id INTO v_user_id;
        
        v_is_new := TRUE;
    ELSE
        -- Update existing user
        UPDATE public.users
        SET 
            last_active_at = NOW(),
            country = COALESCE(p_country, country),
            app_version = COALESCE(p_app_version, app_version)
        WHERE id = v_user_id;
        
        v_is_new := FALSE;
    END IF;
    
    RETURN json_build_object(
        'user_id', v_user_id,
        'is_new', v_is_new,
        'device_id', p_device_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.register_or_get_user(TEXT, TEXT, TEXT) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.register_or_get_user IS 'Registers a new user or returns existing user by device ID';

-- ============================================================================
-- FUNCTION: Start game session
-- Creates a new game session for a user
-- ============================================================================

CREATE OR REPLACE FUNCTION public.start_game_session(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_session_id UUID;
BEGIN
    INSERT INTO public.game_sessions (user_id, questions_played)
    VALUES (p_user_id, 0)
    RETURNING id INTO v_session_id;
    
    RETURN json_build_object(
        'success', true,
        'session_id', v_session_id,
        'started_at', NOW()
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to start game session'
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.start_game_session(UUID) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.start_game_session IS 'Creates a new game session for a user';

-- ============================================================================
-- FUNCTION: End game session
-- Updates game session with final statistics
-- ============================================================================

CREATE OR REPLACE FUNCTION public.end_game_session(
    p_session_id UUID,
    p_questions_played INTEGER,
    p_session_duration_seconds INTEGER
)
RETURNS JSON AS $$
BEGIN
    UPDATE public.game_sessions
    SET 
        questions_played = p_questions_played,
        session_duration_seconds = p_session_duration_seconds,
        ended_at = NOW()
    WHERE id = p_session_id;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Session ended successfully'
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'error', 'Session not found'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Failed to end game session'
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.end_game_session(UUID, INTEGER, INTEGER) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.end_game_session IS 'Ends a game session and records statistics';

-- ============================================================================
-- FUNCTION: Get user statistics
-- Returns comprehensive user statistics
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_user_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'user_id', u.id,
        'device_id', u.device_id,
        'member_since', u.created_at,
        'last_active', u.last_active_at,
        'total_votes', (
            SELECT COUNT(*) FROM public.votes WHERE user_id = u.id
        ),
        'total_sessions', (
            SELECT COUNT(*) FROM public.game_sessions WHERE user_id = u.id
        ),
        'total_questions_played', (
            SELECT COALESCE(SUM(questions_played), 0) 
            FROM public.game_sessions 
            WHERE user_id = u.id
        ),
        'total_playtime_seconds', (
            SELECT COALESCE(SUM(session_duration_seconds), 0) 
            FROM public.game_sessions 
            WHERE user_id = u.id
        ),
        'favorite_category', (
            SELECT q.category
            FROM public.votes v
            JOIN public.questions q ON v.question_id = q.id
            WHERE v.user_id = u.id
            GROUP BY q.category
            ORDER BY COUNT(*) DESC
            LIMIT 1
        )
    ) INTO v_result
    FROM public.users u
    WHERE u.id = p_user_id;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_user_stats(UUID) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.get_user_stats IS 'Returns comprehensive statistics for a user';

-- ============================================================================
-- FUNCTION: Get questions by category
-- Returns approved questions filtered by category
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_questions_by_category(
    p_category TEXT,
    p_device_id TEXT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    question_text TEXT,
    option_a TEXT,
    option_b TEXT,
    category TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        q.id,
        q.question_text,
        q.option_a,
        q.option_b,
        q.category
    FROM public.questions q
    WHERE q.is_approved = TRUE
    AND q.category = p_category
    AND q.id NOT IN (
        SELECT v.question_id 
        FROM public.votes v 
        WHERE v.device_id = p_device_id
    )
    ORDER BY RANDOM()
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_questions_by_category(TEXT, TEXT, INTEGER) TO anon, authenticated;

-- Comments
COMMENT ON FUNCTION public.get_questions_by_category IS 'Returns approved questions filtered by category';

-- ============================================================================
-- ADMIN FUNCTION: Approve question
-- Allows admins to approve questions
-- ============================================================================

CREATE OR REPLACE FUNCTION public.approve_question(p_question_id UUID)
RETURNS JSON AS $$
BEGIN
    -- Check if user is admin
    IF NOT public.is_admin() THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Unauthorized: Admin access required'
        );
    END IF;
    
    UPDATE public.questions
    SET is_approved = TRUE
    WHERE id = p_question_id;
    
    IF FOUND THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Question approved successfully'
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'error', 'Question not found'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.approve_question(UUID) TO authenticated;

-- Comments
COMMENT ON FUNCTION public.approve_question IS 'Allows admins to approve questions';

-- ============================================================================
-- RPC FUNCTIONS COMPLETE
-- ============================================================================

-- Summary of available RPC functions:
-- 1. get_random_question(device_id) - Get random unanswered question
-- 2. submit_vote(question_id, device_id, option, user_id) - Submit vote
-- 3. get_question_stats(question_id) - Get vote statistics
-- 4. get_trending_questions(limit) - Get trending questions
-- 5. register_or_get_user(device_id, country, app_version) - User registration
-- 6. start_game_session(user_id) - Start game session
-- 7. end_game_session(session_id, questions, duration) - End session
-- 8. get_user_stats(user_id) - Get user statistics
-- 9. get_questions_by_category(category, device_id, limit) - Filter by category
-- 10. approve_question(question_id) - Admin approval
