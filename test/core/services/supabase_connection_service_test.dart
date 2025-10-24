import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../lib/core/services/supabase_connection_service.dart';
import '../../../lib/core/services/supabase_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuth extends Mock implements GoTrueClient {}

void main() {
  group('SupabaseConnectionService', () {
    late SupabaseConnectionService connectionService;
    late MockSupabaseClient mockClient;

    setUp(() {
      connectionService = SupabaseConnectionService();
      mockClient = MockSupabaseClient();
      
      // Reset the initialize function for testing
      SupabaseService.resetInitializeFn();
    });

    tearDown(() {
      // Don't dispose in tearDown to avoid timer issues
    });

    test('should start in disconnected state', () {
      expect(connectionService.status, ConnectionStatus.disconnected);
      expect(connectionService.errorMessage, null);
      expect(connectionService.isConnected, false);
    });

    test('should have correct status values', () {
      // Test the enum values
      expect(ConnectionStatus.connected.toString(), 'ConnectionStatus.connected');
      expect(ConnectionStatus.connecting.toString(), 'ConnectionStatus.connecting');
      expect(ConnectionStatus.disconnected.toString(), 'ConnectionStatus.disconnected');
      expect(ConnectionStatus.error.toString(), 'ConnectionStatus.error');
    });

    test('should handle retry connection without initialization', () {
      // Call retry without initialization should not crash
      connectionService.retryConnection();
      
      // Should change to connecting state even without initialization
      expect(connectionService.status, ConnectionStatus.connecting);
    });
  });
}