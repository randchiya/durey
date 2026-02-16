-- ============================================================================
-- Insert 10 Kurdish (Sorani) Questions into DuRey Database
-- Run this in Supabase SQL Editor after schema.sql and rls_policies.sql
-- ============================================================================

-- Insert 10 manually written Kurdish questions
INSERT INTO public.questions (
    question_text,
    option_a,
    option_b,
    category,
    is_approved
) VALUES
    (
        'باشترە هەمیشە درۆ بکەیت یان هەمیشە راست بڵێیت؟',
        'هەمیشە درۆ',
        'هەمیشە راست',
        'General',
        true
    ),
    (
        'باشترە زۆر پارە هەبێت بەڵام هاوڕێت نەبێت، یان هاوڕێی زۆر هەبێت بەڵام پارەت نەبێت؟',
        'پارە زۆر',
        'هاوڕێی زۆر',
        'Life',
        true
    ),
    (
        'باشترە هەرگیز مۆبایل بەکار نەهێنیت یان هەرگیز ئینتەرنێت نەبێت؟',
        'بێ مۆبایل',
        'بێ ئینتەرنێت',
        'Technology',
        true
    ),
    (
        'باشترە دڵت بشکێنرێت یان دڵی کەسێک بشکێنیت؟',
        'دڵم بشکێنرێت',
        'دڵی کەسێک بشکێنم',
        'Relationship',
        true
    ),
    (
        'باشترە ناودار بیت بەڵام هەژار بیت، یان دەستەنگ بیت بەڵام کەس نەناسێت؟',
        'ناودار و هەژار',
        'دەستەنگ و نەناسراو',
        'Life',
        true
    ),
    (
        'باشترە بتوانیت داهاتوو ببینیت یان رابردوو بگۆڕیت؟',
        'داهاتوو ببینم',
        'رابردوو بگۆڕم',
        'Extreme',
        true
    ),
    (
        'باشترە هەمیشە گەرم بیت یان هەمیشە سارد بیت؟',
        'هەمیشە گەرم',
        'هەمیشە سارد',
        'General',
        true
    ),
    (
        'باشترە دڵخۆش بیت بە ژیانی سادە، یان نائاسوودە بیت بە ژیانی لوکس؟',
        'ژیانی سادە و دڵخۆش',
        'ژیانی لوکس و نائاسوودە',
        'Life',
        true
    ),
    (
        'باشترە بتوانیت هەموو زمانەکان قسە بکەیت یان بتوانیت هەموو سازەکان لێبدەیت؟',
        'هەموو زمانەکان',
        'هەموو سازەکان',
        'Talent',
        true
    ),
    (
        'باشترە 10 ساڵ زیاتر بژییت بەڵام بێ پارە بیت، یان 5 ساڵ کەمتر بژییت بەڵام دەوڵەمەند بیت؟',
        '10 ساڵ زیاتر بێ پارە',
        '5 ساڵ کەمتر و دەوڵەمەند',
        'Extreme',
        true
    );

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check total questions inserted
SELECT 
    'Total questions inserted:' AS status,
    COUNT(*) AS count
FROM public.questions;

-- Verify all are approved
SELECT 
    'Approved questions:' AS status,
    COUNT(*) AS count
FROM public.questions
WHERE is_approved = true;

-- Show all inserted questions
SELECT 
    id,
    question_text,
    option_a,
    option_b,
    category,
    is_approved,
    created_at
FROM public.questions
ORDER BY created_at DESC
LIMIT 10;

-- Test RLS: Public can read approved questions
-- This simulates what anonymous users will see
SET ROLE anon;
SELECT 
    'Questions visible to public:' AS status,
    COUNT(*) AS count
FROM public.questions;
RESET ROLE;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

SELECT '✓ 10 Kurdish questions inserted successfully!' AS status;

-- ============================================================================
-- CATEGORIES BREAKDOWN
-- ============================================================================

SELECT 
    category,
    COUNT(*) AS question_count
FROM public.questions
GROUP BY category
ORDER BY question_count DESC;

-- Expected categories:
-- Life: 3 questions
-- General: 2 questions
-- Extreme: 2 questions
-- Technology: 1 question
-- Relationship: 1 question
-- Talent: 1 question
