import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper class to simulate environment variable loading for tests
class MockDotEnv {
  static Map<String, String> _testEnv = {};

  /// Converts a Map of environment variables to a string format suitable for dotenv.testLoad
  static String _toEnvFile(Map<String, String> envMap) {
    return envMap.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('\n');
  }

  /// Sets up test environment variables with default test values
  static Future<void> setupTestEnv() async {
    _testEnv = {
      'SUPABASE_URL': 'https://test.supabase.co',
      'SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.anon.key',
      'SUPABASE_SERVICE_ROLE_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.service.role.key',
      'ONESIGNAL_APP_ID': 'test-onesignal-app-id',
      'ONESIGNAL_REST_API_KEY': 'test-onesignal-rest-api-key',
      'SENDGRID_API_KEY': 'test-sendgrid-api-key',
      'SENDGRID_FROM': 'test@example.com',
      'SENDGRID_DOMAIN': 'test.sendgrid.com',
      'ENVIRONMENT': 'test',
      'APP_NAME': 'Job Order Management Test',
      'APP_VERSION': '1.0.0',
    };
    
    // Use dotenv.testLoad with in-memory content for deterministic test setup
    dotenv.testLoad(fileInput: _toEnvFile(_testEnv));
  }

  /// Resets environment variables to empty state
  static void resetTestEnv() {
    _testEnv.clear();
    // Reset dotenv to empty state by loading empty content
    dotenv.testLoad(fileInput: '');
  }

  /// Loads custom environment configuration for specific test scenarios
  static void loadCustomEnv(Map<String, String> customEnv) {
    // Merge custom env into _testEnv
    _testEnv.addAll(customEnv);
    
    // Load the merged environment variables using testLoad
    dotenv.testLoad(fileInput: _toEnvFile(_testEnv));
  }

  /// Gets a test environment variable value
  static String? getTestEnv(String key) {
    return _testEnv[key];
  }

  /// Sets a specific test environment variable
  static void setTestEnv(String key, String value) {
    _testEnv[key] = value;
    
    // Reload the environment variables with the updated value using testLoad
    dotenv.testLoad(fileInput: _toEnvFile(_testEnv));
  }
}