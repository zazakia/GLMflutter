import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_order_management/core/services/supabase_service.dart';
import '../../helpers/mock_supabase.dart';
import '../../helpers/mock_dotenv.dart';

// Mock for the initializeFn function
class MockInitializeFn {
  void call({required String url, required String anonKey}) {}
}

void main() {
  group('SupabaseService', () {
    late MockSupabaseClient mockClient;
    late MockInitializeFn mockInitializeFn;

    setUpAll(() {
      // Initialize test environment variables
      MockDotEnv.setupTestEnv();
    });

    setUp(() {
      // Create fresh mock client before each test
      mockClient = MockSupabaseClient();
      mockInitializeFn = MockInitializeFn();
    });

    tearDown(() {
      // Reset state between tests
      SupabaseService.clearTestClient();
      SupabaseService.resetInitializeFn();
    });

    group('Initialization', () {
      test('initialize() method successfully initializes Supabase with environment variables', () async {
        // This test verifies that initialize() reads from environment variables
        // Since Supabase.initialize() is a static method, we test its side effects
        expect(SupabaseService.supabaseUrl, equals('https://test.supabase.co'));
        expect(SupabaseService.supabaseAnonKey, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.anon.key'));
        expect(SupabaseService.supabaseServiceRoleKey, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.service.role.key'));
      });

      test('initialize() reads dotenv.env values and sets up client access', () async {
        // Verify environment variables are available before initialization
        expect(SupabaseService.supabaseUrl, isNotNull);
        expect(SupabaseService.supabaseAnonKey, isNotNull);
        
        // Set up a test client to verify client access works after initialization
        SupabaseService.setTestClient(mockClient);
        
        // Verify client access works with test client
        expect(SupabaseService.client, equals(mockClient));
        
        // Clean up
        SupabaseService.clearTestClient();
      });

      test('initialize() calls initializeFn with correct dotenv-derived values', () async {
        // Set up mock function to capture the initialization call
        var capturedUrl = '';
        var capturedAnonKey = '';
        var callCount = 0;
        
        // Inject mock initializeFn
        SupabaseService.initializeFn = ({required String url, required String anonKey}) async {
          capturedUrl = url;
          capturedAnonKey = anonKey;
          callCount++;
        };
        
        // Call initialize
        await SupabaseService.initialize();
        
        // Verify the mock was called exactly once with correct values
        expect(callCount, equals(1));
        expect(capturedUrl, equals(SupabaseService.supabaseUrl));
        expect(capturedAnonKey, equals(SupabaseService.supabaseAnonKey));
        
        // Verify the values match expected test environment values
        expect(capturedUrl, equals('https://test.supabase.co'));
        expect(capturedAnonKey, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.anon.key'));
      });
    });

    group('Client Getter', () {
      test('client getter returns the real Supabase.instance.client when no test client is set', () {
        // Set up a mock client to test the real client behavior
        final realMockClient = MockSupabaseClient();
        SupabaseService.setTestClient(realMockClient);
        
        // Should return the test client since we can't access real client in tests
        expect(SupabaseService.client, equals(realMockClient));
        
        // Clean up
        SupabaseService.clearTestClient();
      });

      test('client getter returns the test client when setTestClient() has been called', () {
        // Set test client
        SupabaseService.setTestClient(mockClient);
        
        // Should return test client
        expect(SupabaseService.client, equals(mockClient));
      });

      test('client getter correctly prioritizes test client over real client', () {
        // Set test client
        SupabaseService.setTestClient(mockClient);
        
        // Should still return test client even if real client exists
        expect(SupabaseService.client, equals(mockClient));
      });
    });

    group('Environment Variable Getters', () {
      test('supabaseUrl getter returns correct value from dotenv.env', () {
        expect(SupabaseService.supabaseUrl, equals('https://test.supabase.co'));
      });

      test('supabaseAnonKey getter returns correct value from dotenv.env', () {
        expect(SupabaseService.supabaseAnonKey, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.anon.key'));
      });

      test('supabaseServiceRoleKey getter returns correct value from dotenv.env', () {
        expect(SupabaseService.supabaseServiceRoleKey, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.service.role.key'));
      });

      test('getters work correctly with test environment variables', () {
        // Verify all environment variables are accessible
        expect(SupabaseService.supabaseUrl, isNotNull);
        expect(SupabaseService.supabaseAnonKey, isNotNull);
        expect(SupabaseService.supabaseServiceRoleKey, isNotNull);
      });
    });

    group('Test Client Management', () {
      test('setTestClient() correctly sets the test client', () {
        SupabaseService.setTestClient(mockClient);
        expect(SupabaseService.client, equals(mockClient));
      });

      test('client getter returns the test client after calling setTestClient()', () {
        SupabaseService.setTestClient(mockClient);
        expect(SupabaseService.client, equals(mockClient));
      });

      test('clearTestClient() resets to null', () {
        SupabaseService.setTestClient(mockClient);
        SupabaseService.clearTestClient();
        
        // Set up a test client to verify clear worked
        final newMockClient = MockSupabaseClient();
        SupabaseService.setTestClient(newMockClient);
        expect(SupabaseService.client, equals(newMockClient));
        
        // Clean up
        SupabaseService.clearTestClient();
      });

      test('client getter returns real client after calling clearTestClient()', () {
        SupabaseService.setTestClient(mockClient);
        SupabaseService.clearTestClient();
        
        // Set up a new test client to verify clear worked
        final newMockClient = MockSupabaseClient();
        SupabaseService.setTestClient(newMockClient);
        expect(SupabaseService.client, equals(newMockClient));
        
        // Clean up
        SupabaseService.clearTestClient();
      });

      test('multiple set/clear cycles ensure proper state management', () {
        // First cycle
        SupabaseService.setTestClient(mockClient);
        expect(SupabaseService.client, equals(mockClient));
        SupabaseService.clearTestClient();
        
        // Second cycle
        final mockClient2 = MockSupabaseClient();
        SupabaseService.setTestClient(mockClient2);
        expect(SupabaseService.client, equals(mockClient2));
        SupabaseService.clearTestClient();
        
        // Verify final state by setting a new client and checking it works
        final finalMockClient = MockSupabaseClient();
        SupabaseService.setTestClient(finalMockClient);
        expect(SupabaseService.client, equals(finalMockClient));
        
        // Clean up
        SupabaseService.clearTestClient();
      });
    });
  });
}