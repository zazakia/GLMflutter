# Supabase Connection Indicator

This directory contains widgets for monitoring and displaying Supabase connection status in your Flutter app.

## Components

### 1. SupabaseConnectionService
A singleton service that monitors the Supabase connection status and provides real-time updates.

**Features:**
- Periodic connection checks (every 30 seconds)
- Automatic retry mechanism with exponential backoff
- Connection status tracking (connected, connecting, disconnected, error)
- Error message handling

### 2. SupabaseConnectionIndicator
A visual widget that displays the current Supabase connection status.

**Usage:**
```dart
// Basic usage
SupabaseConnectionIndicator()

// Compact version (good for small spaces)
SupabaseConnectionIndicator(compact: true)

// Hide label, show only icon
SupabaseConnectionIndicator(showLabel: false)

// Hide retry button
SupabaseConnectionIndicator(showRetryButton: false)
```

**Parameters:**
- `compact`: Show a smaller version (default: false)
- `showLabel`: Show status text label (default: true)
- `showRetryButton`: Show retry button when in error state (default: true)

### 3. SupabaseConnectionStatusWidget
A detailed debugging widget that shows comprehensive connection information.

**Usage:**
```dart
SupabaseConnectionStatusWidget()
```

## Integration

### In Development Mode
The connection indicator is automatically shown in the auth screen when in development mode.

### In Production
You can add the indicator to any screen:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/supabase_connection_indicator.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          // Add connection indicator to app bar
          SupabaseConnectionIndicator(compact: true),
        ],
      ),
      body: Center(
        child: Text('Content'),
      ),
    );
  }
}
```

## Riverpod Providers

The connection indicator uses several Riverpod providers:

- `supabaseConnectionServiceProvider`: Provides the connection service instance
- `connectionStatusProvider`: Stream of connection status updates
- `connectionErrorProvider`: Current error message (if any)
- `isConnectedProvider`: Boolean indicating if connected

You can use these providers directly in your widgets:

```dart
final isConnected = ref.watch(isConnectedProvider);
final connectionStatus = ref.watch(connectionStatusProvider);

if (!isConnected) {
  return Text('No connection');
}
```

## Connection States

- **Connected**: Green indicator with cloud_done icon
- **Connecting**: Orange indicator with cloud_sync icon and loading spinner
- **Disconnected**: Grey indicator with cloud_off icon
- **Error**: Red indicator with error icon and retry button

## Testing

The connection service includes comprehensive tests. Run them with:

```bash
flutter test test/core/services/supabase_connection_service_test.dart
```

## Notes

- The connection indicator only appears in development mode by default
- Connection checks are performed every 30 seconds
- Automatic retry is attempted up to 3 times with exponential backoff
- The service gracefully handles Supabase initialization failures