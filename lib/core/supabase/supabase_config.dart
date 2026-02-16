import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization
class SupabaseConfig {
  // Production Supabase credentials
  static const String supabaseUrl = 'https://pdalugdvgbapoeznxabd.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBkYWx1Z2R2Z2JhcG9lem54YWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwNjkxNjEsImV4cCI6MjA4NjY0NTE2MX0.1VvYrj5Dse5yr2CUZETPLiFjOkcj1Ky_Echp2MJ5xIU';

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
}
