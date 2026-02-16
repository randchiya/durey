import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:durey/services/supabase_service.dart';
import 'package:durey/core/supabase/supabase_config.dart';

/// Provider for SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange.map(
    (data) => data.session?.user,
  );
});

/// Provider for auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(currentUserProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (error, stackTrace) => false,
  );
});
