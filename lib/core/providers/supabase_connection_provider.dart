import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_connection_service.dart';

// Provider for the SupabaseConnectionService instance
final supabaseConnectionServiceProvider = Provider<SupabaseConnectionService>((ref) {
  final service = SupabaseConnectionService();
  
  // Initialize the service when the provider is first created
  service.initialize();
  
  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// Provider for the current connection status
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(supabaseConnectionServiceProvider);
  
  // Create a stream that emits the current status whenever it changes
  final controller = StreamController<ConnectionStatus>();
  
  // Listen to changes in the connection service
  void listener() {
    controller.add(service.status);
  }
  
  service.addListener(listener);
  
  // Add initial status
  controller.add(service.status);
  
  // Clean up when the stream is disposed
  ref.onDispose(() {
    service.removeListener(listener);
    controller.close();
  });
  
  return controller.stream;
});

// Provider for connection error message
final connectionErrorProvider = Provider<String?>((ref) {
  final service = ref.watch(supabaseConnectionServiceProvider);
  return service.errorMessage;
});

// Provider for connection state (connected/disconnected)
final isConnectedProvider = Provider<bool>((ref) {
  final service = ref.watch(supabaseConnectionServiceProvider);
  return service.isConnected;
});