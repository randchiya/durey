import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:durey/models/question_model.dart';
import 'package:durey/core/supabase/supabase_config.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// Service for fetching questions from Supabase
class QuestionService {
  final _client = SupabaseConfig.client;
  String? _cachedDeviceId;

  /// Get unique device ID
  Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _cachedDeviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _cachedDeviceId = iosInfo.identifierForVendor ?? 'unknown-ios';
      } else {
        _cachedDeviceId = 'unknown-platform';
      }
      return _cachedDeviceId!;
    } catch (e) {
      _cachedDeviceId = 'fallback-${DateTime.now().millisecondsSinceEpoch}';
      return _cachedDeviceId!;
    }
  }

  /// Fetch one approved question from the database
  Future<QuestionModel?> fetchApprovedQuestion() async {
    try {
      final response = await _client
          .from('questions')
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return QuestionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch random approved question
  Future<QuestionModel?> fetchRandomQuestion() async {
    try {
      final response = await _client
          .from('questions')
          .select()
          .eq('is_approved', true)
          .limit(50);

      if (response.isEmpty) {
        return null;
      }

      // Pick random question from results
      final questions = (response as List)
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      questions.shuffle();
      return questions.first;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch random approved question by category
  Future<QuestionModel?> fetchQuestionByCategory(String category) async {
    try {
      final response = await _client
          .from('questions')
          .select()
          .eq('is_approved', true)
          .eq('category', category)
          .limit(50);

      if (response.isEmpty) {
        return null;
      }

      // Pick random question from results
      final questions = (response as List)
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      questions.shuffle();
      return questions.first;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch all approved questions
  Future<List<QuestionModel>> fetchAllApprovedQuestions() async {
    try {
      final response = await _client
          .from('questions')
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Submit a vote using the RPC function
  Future<Map<String, dynamic>> submitVote({
    required String questionId,
    required String optionSelected,
  }) async {
    try {
      final deviceId = await _getDeviceId();

      final response = await _client.rpc(
        'submit_vote',
        params: {
          'p_question_id': questionId,
          'p_device_id': deviceId,
          'p_option_selected': optionSelected,
          'p_user_id': null,
        },
      );

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'error': 'Database error: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e',
      };
    }
  }

  /// Fetch real vote counts from Supabase using COUNT queries
  Future<Map<String, int>> fetchVoteCounts(String questionId) async {
    try {
      // Count votes for option A
      final optionAResponse = await _client
          .from('votes')
          .select('id')
          .eq('question_id', questionId)
          .eq('option_selected', 'A')
          .count(CountOption.exact);

      // Count votes for option B
      final optionBResponse = await _client
          .from('votes')
          .select('id')
          .eq('question_id', questionId)
          .eq('option_selected', 'B')
          .count(CountOption.exact);

      return {
        'A': optionAResponse.count,
        'B': optionBResponse.count,
      };
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch vote counts: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching vote counts: $e');
    }
  }
}
