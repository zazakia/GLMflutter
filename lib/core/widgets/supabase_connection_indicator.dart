import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supabase_connection_provider.dart';
import '../services/supabase_connection_service.dart';

class SupabaseConnectionIndicator extends ConsumerWidget {
  const SupabaseConnectionIndicator({
    super.key,
    this.showLabel = true,
    this.showRetryButton = true,
    this.compact = false,
  });

  final bool showLabel;
  final bool showRetryButton;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final errorMessage = ref.watch(connectionErrorProvider);
    final connectionService = ref.watch(supabaseConnectionServiceProvider);

    return connectionStatus.when(
      data: (status) {
        return _buildIndicator(context, status, errorMessage, connectionService);
      },
      loading: () {
        return _buildIndicator(context, ConnectionStatus.connecting, null, connectionService);
      },
      error: (_, __) {
        return _buildIndicator(context, ConnectionStatus.error, 'Connection error', connectionService);
      },
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    ConnectionStatus status,
    String? errorMessage,
    SupabaseConnectionService connectionService,
  ) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final label = _getStatusLabel(status);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: color,
            ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (status == ConnectionStatus.connecting) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            ),
          ],
          if (status == ConnectionStatus.error && showRetryButton) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () => connectionService.retryConnection(),
              child: Icon(
                Icons.refresh,
                size: 16,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.cloud_done;
      case ConnectionStatus.connecting:
        return Icons.cloud_sync;
      case ConnectionStatus.disconnected:
        return Icons.cloud_off;
      case ConnectionStatus.error:
        return Icons.error;
    }
  }

  String _getStatusLabel(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.error:
        return 'Connection Error';
    }
  }
}

// A more detailed connection status widget for debugging
class SupabaseConnectionStatusWidget extends ConsumerWidget {
  const SupabaseConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final errorMessage = ref.watch(connectionErrorProvider);
    final isConnected = ref.watch(isConnectedProvider);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Supabase Connection Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            connectionStatus.when(
              data: (status) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow('Status', status.toString()),
                    _buildStatusRow('Is Connected', isConnected.toString()),
                    if (errorMessage != null)
                      _buildStatusRow('Error', errorMessage, isError: true),
                  ],
                );
              },
              loading: () => const Text('Loading connection status...'),
              error: (error, stack) => _buildStatusRow(
                'Error',
                error.toString(),
                isError: true,
              ),
            ),
            const SizedBox(height: 12),
            const SupabaseConnectionIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : null,
                fontFamily: isError ? 'monospace' : null,
                fontSize: isError ? 12 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}