import 'package:durey/core/supabase/supabase_config.dart';
import 'package:durey/models/question_model.dart';
import 'package:durey/models/vote_stats_model.dart';

/// Database service for DuRey game operations
/// Uses Supabase RPC functions for secure database access
class DatabaseService {
  final _client = SupabaseConfig.client;

  // ============================================================================
  // USER OPERATIONS
  // ============================================================================

  /// Register a new user or get existing user by device ID
  Future<Map<String, dynamic>> registerOrGetUser({
    required String deviceId,
    String? country,
    String? appVersion,
  }) async {
    try {
      final response = await _client.rpc(
        'register_or_get_user',
        params: {
          'p_device_id': deviceId,
          'p_country': country,
          'p_app_version': appVersion,
        },
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_stats',
        params: {'p_user_id': userId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  // ============================================================================
  // QUESTION OPERATIONS
  // ============================================================================

  /// Get a random approved question that the device hasn't voted on
  Future<QuestionModel?> getRandomQuestion(String deviceId) async {
    try {
      final response = await _client.rpc(
        'get_random_question',
        params: {'p_device_id': deviceId},
      ) as List<dynamic>;

      if (response.isEmpty) {
        return null; // No more questions available
      }

      return QuestionModel.fromJson(response.first as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get random question: $e');
    }
  }

  /// Get questions by category
  Future<List<QuestionModel>> getQuestionsByCategory({
    required String category,
    required String deviceId,
    int limit = 10,
  }) async {
    try {
      final response = await _client.rpc(
        'get_questions_by_category',
        params: {
          'p_category': category,
          'p_device_id': deviceId,
          'p_limit': limit,
        },
      ) as List<dynamic>;

      return response
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get questions by category: $e');
    }
  }

  /// Get trending questions (most voted in last 24 hours)
  Future<List<VoteStatsModel>> getTrendingQuestions({int limit = 10}) async {
    try {
      final response = await _client.rpc(
        'get_trending_questions',
        params: {'p_limit': limit},
      ) as List<dynamic>;

      return response
          .map((json) => VoteStatsModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get trending questions: $e');
    }
  }

  // ============================================================================
  // VOTE OPERATIONS
  // ============================================================================

  /// Submit a vote for a question
  /// Returns success status and message
  Future<Map<String, dynamic>> submitVote({
    required String questionId,
    required String deviceId,
    required String optionSelected, // 'A' or 'B'
    String? userId,
  }) async {
    try {
      // Validate option
      if (optionSelected != 'A' && optionSelected != 'B') {
        throw Exception('Invalid option selected. Must be A or B');
      }

      final response = await _client.rpc(
        'submit_vote',
        params: {
          'p_question_id': questionId,
          'p_device_id': deviceId,
          'p_option_selected': optionSelected,
          'p_user_id': userId,
        },
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to submit vote: $e');
    }
  }

  /// Get vote statistics for a specific question
  Future<VoteStatsModel> getQuestionStats(String questionId) async {
    try {
      final response = await _client.rpc(
        'get_question_stats',
        params: {'p_question_id': questionId},
      );

      return VoteStatsModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get question stats: $e');
    }
  }

  // ============================================================================
  // SESSION OPERATIONS
  // ============================================================================

  /// Start a new game session
  Future<Map<String, dynamic>> startGameSession(String userId) async {
    try {
      final response = await _client.rpc(
        'start_game_session',
        params: {'p_user_id': userId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to start game session: $e');
    }
  }

  /// End a game session with statistics
  Future<Map<String, dynamic>> endGameSession({
    required String sessionId,
    required int questionsPlayed,
    required int sessionDurationSeconds,
  }) async {
    try {
      final response = await _client.rpc(
        'end_game_session',
        params: {
          'p_session_id': sessionId,
          'p_questions_played': questionsPlayed,
          'p_session_duration_seconds': sessionDurationSeconds,
        },
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to end game session: $e');
    }
  }

  // ============================================================================
  // ADMIN OPERATIONS
  // ============================================================================

  /// Approve a question (admin only)
  Future<Map<String, dynamic>> approveQuestion(String questionId) async {
    try {
      final response = await _client.rpc(
        'approve_question',
        params: {'p_question_id': questionId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to approve question: $e');
    }
  }

  // ============================================================================
  // DIRECT QUERIES (with RLS protection)
  // ============================================================================

  /// Get all approved questions (respects RLS)
  Future<List<QuestionModel>> getAllApprovedQuestions() async {
    try {
      final response = await _client
          .from('questions')
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get approved questions: $e');
    }
  }

  /// Check if device has voted on a question
  Future<bool> hasVoted({
    required String questionId,
    required String deviceId,
  }) async {
    try {
      final response = await _client
          .from('votes')
          .select('id')
          .eq('question_id', questionId)
          .eq('device_id', deviceId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check vote status: $e');
    }
  }

  /// Get user's voting history
  Future<List<Map<String, dynamic>>> getVotingHistory({
    required String deviceId,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('votes')
          .select('*, questions(*)')
          .eq('device_id', deviceId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get voting history: $e');
    }
  }
}
