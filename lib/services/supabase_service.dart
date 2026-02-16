import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:durey/core/supabase/supabase_config.dart';

/// Service class for Supabase operations
class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Auth methods
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Database methods - Example
  Future<List<Map<String, dynamic>>> fetchData(String tableName) async {
    final response = await _client.from(tableName).select();
    return response;
  }

  Future<void> insertData(String tableName, Map<String, dynamic> data) async {
    await _client.from(tableName).insert(data);
  }

  Future<void> updateData(
    String tableName,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    await _client.from(tableName).update(data).eq(column, value);
  }

  Future<void> deleteData(
    String tableName,
    String column,
    dynamic value,
  ) async {
    await _client.from(tableName).delete().eq(column, value);
  }
}
