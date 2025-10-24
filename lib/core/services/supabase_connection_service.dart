import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
  error,
}

class SupabaseConnectionService extends ChangeNotifier {
  static final SupabaseConnectionService _instance = SupabaseConnectionService._internal();
  factory SupabaseConnectionService() => _instance;
  SupabaseConnectionService._internal();

  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _errorMessage;
  Timer? _connectionCheckTimer;
  int _retryCount = 0;
  bool _isDisposed = false;
  static const int _maxRetries = 3;
  static const Duration _checkInterval = Duration(seconds: 30);

  ConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _status == ConnectionStatus.connected;

  void initialize() {
    _status = ConnectionStatus.connecting;
    _errorMessage = null;
    notifyListeners();
    
    // Start periodic connection checks
    _startConnectionCheck();
    
    // Initial connection check
    _checkConnection();
  }

  void _startConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
    _connectionCheckTimer = Timer.periodic(_checkInterval, (_) {
      if (!_isDisposed) {
        _checkConnection();
      }
    });
  }

  Future<void> _checkConnection() async {
    try {
      // Simple health check by trying to get the current session
      final client = SupabaseService.client;
      
      // Try a simple query to test connectivity - check if we can access auth
      await client.auth.currentSession;
      
      // Alternative: try a simple select from a system table
      // await client.from('_realtime').select('count').limit(1);
      
      _updateStatus(ConnectionStatus.connected);
      _retryCount = 0;
    } catch (e) {
      debugPrint('Supabase connection check failed: $e');
      
      if (_status != ConnectionStatus.error) {
        _retryCount++;
        
        if (_retryCount >= _maxRetries) {
          _updateStatus(ConnectionStatus.error, e.toString());
        } else {
          _updateStatus(ConnectionStatus.connecting);
          // Retry after a short delay
          Future.delayed(Duration(seconds: 2 * _retryCount), () {
            _checkConnection();
          });
        }
      }
    }
  }

  void _updateStatus(ConnectionStatus status, [String? error]) {
    if (_status != status || _errorMessage != error) {
      _status = status;
      _errorMessage = error;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  Future<void> retryConnection() async {
    _retryCount = 0;
    _updateStatus(ConnectionStatus.connecting);
    await _checkConnection();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
    super.dispose();
  }
}

// Health check function that needs to be created in Supabase
// This SQL should be run in Supabase SQL editor:
/*
CREATE OR REPLACE FUNCTION health_check()
RETURNS TABLE(status text)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 'ok' as status;
$$;
*/