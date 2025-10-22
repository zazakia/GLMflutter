# Flutter Setup Guide for Job Order Management System

This guide follows the official Supabase Flutter quickstart and provides step-by-step instructions for setting up the Flutter app.

## Prerequisites

1. Flutter SDK (version 3.0 or higher)
2. Dart SDK (version 2.17 or higher)
3. An IDE (VS Code, Android Studio, or IntelliJ)
4. A Supabase project (already created with reference `tzmpwqiaqalrdwdslmkx`)

## 1. Project Setup

### Install Dependencies

Ensure your `pubspec.yaml` includes the following dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.10.0
  flutter_riverpod: ^3.0.3
  go_router: ^16.2.5
  flutter_dotenv: ^5.1.1
  image_picker: ^1.2.0
  mobile_scanner: ^7.1.2
  printing: ^5.14.2
  pdf: ^3.11.3
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.1.1
```

Run `flutter pub get` to install the dependencies.

### Environment Configuration

1. Create a `.env` file in the root of your project:

```env
# Supabase Configuration
SUPABASE_URL=https://tzmpwqiaqalrdwdslmkx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# App Configuration
FLUTTER_APP_NAME=Job Order Management
```

2. Add the `.env` file to your `.gitignore`:

```.gitignore
.env
.env.*
```

3. Initialize Flutter DotEnv in your `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const ProviderScope(child: JobOrderManagementApp()));
}
```

## 2. Supabase Service

Create a Supabase service to manage the Supabase client:

```dart
// lib/core/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }
}
```

## 3. Authentication

### Auth Repository

Create an authentication repository to handle authentication logic:

```dart
// lib/features/auth/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChanges();
  
  User? get currentUser => _supabase.auth.currentUser;
  
  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }
  
  Future<AuthResponse> signUpWithEmail(String email, String password) {
    return _supabase.auth.signUp(email: email, password: password);
  }
  
  Future<void> signOut() {
    return _supabase.auth.signOut();
  }
  
  Future<void> resetPassword(String email) {
    return _supabase.auth.resetPasswordForEmail(email);
  }
}
```

### Auth State Provider

Create a Riverpod provider to manage authentication state:

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authUserProvider = Provider<User?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});
```

## 4. Navigation

### App Router

Set up GoRouter for navigation:

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = Supabase.instance.client.auth.currentSession != null;
      final isAuthRoute = state.location == '/';
      
      if (!isAuthenticated && !isAuthRoute) {
        return '/';
      }
      
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
```

## 5. Database Operations

### Database Service

Create a service for database operations:

```dart
// lib/core/services/database_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Generic CRUD operations
  Future<List<Map<String, dynamic>>> fetch(String table, {
    List<String> columns = const ['*'],
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
  }) async {
    var query = _supabase.from(table).select(columns.join(', '));
    
    if (filters != null) {
      for (var entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }
    
    if (orderBy != null) {
      query = query.order(orderBy);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return await query;
  }
  
  Future<Map<String, dynamic>> fetchById(String table, String id) async {
    return await _supabase.from(table).select().eq('id', id).single();
  }
  
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    return await _supabase.from(table).insert(data).select().single();
  }
  
  Future<Map<String, dynamic>> update(String table, String id, Map<String, dynamic> data) async {
    return await _supabase.from(table).update(data).eq('id', id).select().single();
  }
  
  Future<void> delete(String table, String id) async {
    await _supabase.from(table).delete().eq('id', id);
  }
}
```

## 6. Testing

### Unit Tests

Create unit tests for your services and repositories:

```dart
// test/features/auth/data/repositories/auth_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_order_management/features/auth/data/repositories/auth_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  group('AuthRepository', () {
    late AuthRepository authRepository;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    
    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      authRepository = AuthRepository();
      
      // TODO: Setup mocks
    });
    
    test('should sign in with email and password', () async {
      // TODO: Implement test
    });
    
    test('should sign up with email and password', () async {
      // TODO: Implement test
    });
    
    test('should sign out', () async {
      // TODO: Implement test
    });
  });
}
```

## 7. Best Practices

### Error Handling

Implement proper error handling throughout your app:

```dart
try {
  final result = await authRepository.signInWithEmail(email, password);
  // Handle success
} on AuthException catch (e) {
  // Handle auth errors
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
} catch (e) {
  // Handle other errors
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('An unexpected error occurred')),
  );
}
```

### Loading States

Show loading indicators during async operations:

```dart
ElevatedButton(
  onPressed: _isLoading ? null : _submit,
  child: _isLoading
      ? const CircularProgressIndicator()
      : const Text('Sign In'),
)
```

### Form Validation

Validate user input before submitting:

```dart
TextFormField(
  controller: _emailController,
  decoration: const InputDecoration(labelText: 'Email'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  },
)
```

## 8. Next Steps

1. Complete the database migration following the steps in `supabase/MANUAL_MIGRATION_STEPS.md`
2. Run the Flutter app and test the authentication flow
3. Implement the remaining features according to your todo list
4. Add proper error handling and loading states
5. Write unit and integration tests

## Resources

- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Flutter Documentation](https://flutter.dev/docs)
- [GoRouter Documentation](https://gorouter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)