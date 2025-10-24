import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import 'mock_supabase.dart';
import 'mock_router.dart';
import 'mock_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_order_management/core/services/supabase_service.dart';


/// Comprehensive test helper utilities for widget testing

/// Wraps a widget with ProviderScope and MaterialApp for testing Riverpod-based widgets
Future<TestWidgetsFlutterBinding> pumpTestWidget(
  WidgetTester tester,
  Widget widget, {
  ThemeData? theme,
  Locale? locale,
}) async {
  // Ensure widget bindings are initialized before environment setup
  TestWidgetsFlutterBinding.ensureInitialized();
  MockDotEnv.setupTestEnv();
  
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: theme,
        locale: locale,
        home: widget,
      ),
    ),
  );
  
  return tester.binding;
}

/// Wraps a widget with ProviderScope and MaterialApp.router for testing widgets that require navigation context
Future<TestWidgetsFlutterBinding> pumpTestWidgetWithRouter(
  WidgetTester tester,
  Widget widget, {
  GoRouter? router,
  ThemeData? theme,
  Locale? locale,
}) async {
  // Ensure widget bindings are initialized before environment setup
  TestWidgetsFlutterBinding.ensureInitialized();
  MockDotEnv.setupTestEnv();
  
  final testRouter = router ?? GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => widget,
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        theme: theme,
        locale: locale,
        routerConfig: testRouter,
      ),
    ),
  );
  
  return tester.binding;
}

/// Initializes mock Supabase client and auth with common default behaviors
Future<void> setupMockSupabase() async {
  final mockSupabaseClient = MockSupabaseClient();
  final mockGoTrueClient = MockGoTrueClient();
  final mockAuthResponse = MockAuthResponse();
  
  // Setup default behaviors
  when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  when(() => mockGoTrueClient.currentSession).thenReturn(null);
  when(() => mockGoTrueClient.currentUser).thenReturn(null);
  
  // Setup successful sign in
  when(() => mockGoTrueClient.signInWithPassword(
    email: any(named: 'email'),
    password: any(named: 'password'),
  )).thenAnswer((_) async => mockAuthResponse);
  
  // Setup successful sign up
  when(() => mockGoTrueClient.signUp(
    email: any(named: 'email'),
    password: any(named: 'password'),
  )).thenAnswer((_) async => mockAuthResponse);
  
  // Setup successful sign out
  when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});
  
  // Set the test client in SupabaseService
  SupabaseService.setTestClient(mockSupabaseClient);
}

/// Creates a properly configured mock Session object with test user data
/// Updated for supabase_flutter v2.3.3 with correct Session properties
MockSession createMockAuthSession({
  String accessToken = 'test-access-token',
  String refreshToken = 'test-refresh-token',
  DateTime? expiresAt,
  String? tokenType,
}) {
  final mockSession = MockSession();
  
  // Core Session properties for supabase_flutter v2.3.3
  when(() => mockSession.accessToken).thenReturn(accessToken);
  when(() => mockSession.refreshToken).thenReturn(refreshToken);
  when(() => mockSession.tokenType).thenReturn(tokenType ?? 'bearer');
  
  // Handle expiration - expiresAt is typically an int (milliseconds since epoch)
  final expirationTime = expiresAt?.millisecondsSinceEpoch ??
      DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
  when(() => mockSession.expiresAt).thenReturn(expirationTime);
  
  // Note: user property should be set separately if needed
  // when(() => mockSession.user).thenReturn(mockUser); // Set when creating session with user
  
  return mockSession;
}

/// Creates a mock User object with test data
MockUser createMockUser({
  String id = 'test-user-id',
  String email = 'test@example.com',
  String? phone,
  Map<String, dynamic>? userMetadata,
  Map<String, dynamic>? appMetadata,
}) {
  final mockUser = MockUser();
  
  when(() => mockUser.id).thenReturn(id);
  when(() => mockUser.email).thenReturn(email);
  when(() => mockUser.phone).thenReturn(phone);
  when(() => mockUser.userMetadata).thenReturn(userMetadata ?? {});
  when(() => mockUser.appMetadata).thenReturn(appMetadata ?? {});
  
  return mockUser;
}

/// Helper to verify SnackBar messages in tests
Future<void> expectSnackBar(
  WidgetTester tester,
  String expectedMessage, {
  Finder? finder,
}) async {
  final snackBarFinder = finder ?? find.byType(SnackBar);
  expect(snackBarFinder, findsOneWidget);
  
  final snackBar = tester.widget<SnackBar>(snackBarFinder);
  expect(snackBar.content, isA<Text>());
  
  final textWidget = snackBar.content as Text;
  expect(textWidget.data, expectedMessage);
}

/// Creates a mock GoRouter for testing navigation
MockGoRouter createMockGoRouter() {
  final mockRouter = MockGoRouter();
  
  when(() => mockRouter.go(any())).thenReturn(null);
  when(() => mockRouter.push(any())).thenAnswer((_) async => null);
  when(() => mockRouter.pop()).thenReturn(null);
  when(() => mockRouter.canPop()).thenReturn(true);
  
  return mockRouter;
}

/// Cleans up test environment between tests
void cleanupTestEnv() {
  MockDotEnv.resetTestEnv();
  SupabaseService.clearTestClient();
}

/// Sets up common test environment with mocks
Future<void> setupTestEnvironment() async {
  MockDotEnv.setupTestEnv();
  await setupMockSupabase();
}

/// Sets up test environment with custom environment variables
Future<void> setupTestEnvironmentWithCustomEnv(Map<String, String> customEnv) async {
  MockDotEnv.loadCustomEnv(customEnv);
  await setupMockSupabase();
}