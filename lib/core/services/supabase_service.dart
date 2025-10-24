import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _testClient;
  
  /// Injectable initializer function for testing purposes
  static Future<void> Function({required String url, required String anonKey}) initializeFn =
      ({required String url, required String anonKey}) => Supabase.initialize(url: url, anonKey: anonKey);
  
  static Future<void> initialize() async {
    await initializeFn(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  static SupabaseClient get client => _testClient ?? Supabase.instance.client;
  
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
  static String get supabaseServiceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!;
  
  /// Sets a custom SupabaseClient for testing purposes
  static void setTestClient(SupabaseClient client) {
    _testClient = client;
  }
  
  /// Clears the test client (returns to using the real client)
  static void clearTestClient() {
    _testClient = null;
  }
  
  /// Resets the initializeFn to the default implementation (for tests)
  static void resetInitializeFn() {
    initializeFn = ({required String url, required String anonKey}) => Supabase.initialize(url: url, anonKey: anonKey);
  }
}