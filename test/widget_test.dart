import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'helpers/test_helpers.dart';
import 'helpers/mock_dotenv.dart';
import 'helpers/mock_supabase.dart';
import 'package:job_order_management/main.dart';
import 'package:job_order_management/core/services/supabase_service.dart';
import 'package:job_order_management/features/auth/presentation/screens/auth_screen.dart';
import 'package:job_order_management/core/providers/supabase_connection_provider.dart';

void main() {
  group('Job Order Management App Integration Tests', () {
    setUpAll(() {
      // Register fallback values for mocktail if needed
      registerFallbackValue(const RouteSettings());
    });

    setUp(() async {
      // Set up test environment before each test
      MockDotEnv.setupTestEnv();
      await setupMockSupabase();
    });

    tearDown(() {
      // Clean up test environment after each test
      cleanupTestEnv();
    });

    group('App Initialization - Basic Setup', () {
      testWidgets('app initializes without errors', (WidgetTester tester) async {
        // Create JobOrderManagementApp widget and pump it with ProviderScope wrapper
        await pumpApp(tester);
        
        // Verify no exceptions are thrown
        expect(tester.takeException(), isNull);
      });

      testWidgets('app is wrapped in ProviderScope', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify ProviderScope is present in widget tree
        expect(find.byType(ProviderScope), findsOneWidget);
      });

      testWidgets('app uses MaterialApp.router', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify MaterialApp is present
        expect(find.byType(MaterialApp), findsOneWidget);
        
        // Verify it uses router configuration by checking widget properties
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.routerConfig, isNotNull);
        expect(materialApp.routerConfig, isA<GoRouter>());
      });

      testWidgets('app title is correct', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify the MaterialApp title property equals 'Job Order Management'
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.title, equals('Job Order Management'));
      });

      testWidgets('debugShowCheckedModeBanner is false', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify the MaterialApp has debugShowCheckedModeBanner set to false
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.debugShowCheckedModeBanner, isFalse);
      });
    });

    group('Theme Configuration - Light Theme', () {
      testWidgets('light theme is configured', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Access the MaterialApp's theme property
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme, isNotNull);
      });

      testWidgets('light theme uses Material3', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify theme.useMaterial3 is true
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme?.useMaterial3, isTrue);
      });

      testWidgets('light theme has correct seed color', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Generate expected ColorScheme from seed and compare
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        final expectedColorScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        );
        expect(materialApp.theme?.colorScheme, equals(expectedColorScheme));
      });

      testWidgets('light theme brightness is light', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify theme.colorScheme.brightness equals Brightness.light
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme?.colorScheme.brightness, equals(Brightness.light));
      });

      testWidgets('light theme ColorScheme is properly configured', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify the ColorScheme is created from seed with correct parameters
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme?.colorScheme, isNotNull);
        expect(materialApp.theme?.useMaterial3, isTrue);
        expect(materialApp.theme?.colorScheme.brightness, equals(Brightness.light));
        
        // Verify the entire ColorScheme matches expected from seed
        final expectedColorScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        );
        expect(materialApp.theme?.colorScheme, equals(expectedColorScheme));
      });
    });

    group('Theme Configuration - Dark Theme', () {
      testWidgets('dark theme is configured', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Access the MaterialApp's darkTheme property
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.darkTheme, isNotNull);
      });

      testWidgets('dark theme uses Material3', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify darkTheme.useMaterial3 is true
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.darkTheme?.useMaterial3, isTrue);
      });

      testWidgets('dark theme has correct seed color', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Generate expected ColorScheme from seed and compare
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        final expectedColorScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        );
        expect(materialApp.darkTheme?.colorScheme, equals(expectedColorScheme));
      });

      testWidgets('dark theme brightness is dark', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify darkTheme.colorScheme.brightness equals Brightness.dark
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.darkTheme?.colorScheme.brightness, equals(Brightness.dark));
      });

      testWidgets('themeMode is system', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify MaterialApp's themeMode property equals ThemeMode.system
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.themeMode, equals(ThemeMode.system));
      });
    });

    group('Localization Configuration', () {
      testWidgets('localization delegates are configured', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify MaterialApp has localizationsDelegates property set
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.localizationsDelegates, isNotNull);
        expect(materialApp.localizationsDelegates!.isNotEmpty, isTrue);
      });

      testWidgets('GlobalMaterialLocalizations delegate is present', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Check that the delegates list contains GlobalMaterialLocalizations.delegate
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.localizationsDelegates, contains(GlobalMaterialLocalizations.delegate));
      });

      testWidgets('GlobalWidgetsLocalizations delegate is present', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Check that the delegates list contains GlobalWidgetsLocalizations.delegate
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.localizationsDelegates, contains(GlobalWidgetsLocalizations.delegate));
      });

      testWidgets('GlobalCupertinoLocalizations delegate is present', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Check that the delegates list contains GlobalCupertinoLocalizations.delegate
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.localizationsDelegates, contains(GlobalCupertinoLocalizations.delegate));
      });

      testWidgets('supported locales include en_PH', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify supportedLocales contains Locale('en', 'PH')
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.supportedLocales, contains(const Locale('en', 'PH')));
      });
    });

    group('Router Configuration - Basic Properties', () {
      testWidgets('router is configured', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Access MaterialApp's routerConfig property
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.routerConfig, isNotNull);
        expect(materialApp.routerConfig, isA<GoRouter>());
      });

      testWidgets('initial location is root', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify GoRouter's initialLocation equals '/'
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        final router = materialApp.routerConfig as GoRouter;
        // For newer versions of go_router, we check the route configuration
        expect(router.routeInformationProvider.value.location, equals('/'));
      });

      testWidgets('router has redirect function', (WidgetTester tester) async {
        // Pump the app
        await pumpApp(tester);
        
        // Verify the redirect callback is configured by testing behavior
        // Set up unauthenticated state
        setupAuthState(false);
        
        // Try to navigate to /home
        final router = (tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig as GoRouter);
        router.go('/home');
        await tester.pumpAndSettle();
        
        // Verify redirect occurred (stayed on auth screen)
        expect(find.byType(AuthScreen), findsOneWidget);
      });
    });

    group('Router Configuration - Routes', () {
      testWidgets('root route renders AuthScreen', (WidgetTester tester) async {
        // Pump the app with unauthenticated state
        await pumpApp(tester, authenticated: false);
        await tester.pumpAndSettle();
        
        // Verify AuthScreen widget is rendered
        expect(find.byType(AuthScreen), findsOneWidget);
      });

      testWidgets('home route is configured', (WidgetTester tester) async {
        // Set up authenticated state
        setupAuthState(true);
        
        // Pump the app
        await pumpApp(tester);
        await tester.pumpAndSettle();
        
        // Navigate to /home
        final router = (tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig as GoRouter);
        router.go('/home');
        await tester.pumpAndSettle();
        
        // Verify the route exists
        expect(find.text('Home Screen - Coming Soon'), findsOneWidget);
      });

      testWidgets('home route renders placeholder', (WidgetTester tester) async {
        // Set up authenticated state
        setupAuthState(true);
        
        // Pump the app
        await pumpApp(tester);
        await tester.pumpAndSettle();
        
        // Navigate to /home
        final router = (tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig as GoRouter);
        router.go('/home');
        await tester.pumpAndSettle();
        
        // Verify the text 'Home Screen - Coming Soon' is displayed
        expect(find.text('Home Screen - Coming Soon'), findsOneWidget);
      });

      testWidgets('home route uses Scaffold', (WidgetTester tester) async {
        // Set up authenticated state
        setupAuthState(true);
        
        // Pump the app
        await pumpApp(tester);
        await tester.pumpAndSettle();
        
        // Navigate to /home
        final router = (tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig as GoRouter);
        router.go('/home');
        await tester.pumpAndSettle();
        
        // Verify the home route renders a Scaffold widget
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Authentication Redirect Logic - Unauthenticated User', () {
      testWidgets('unauthenticated user stays on root route', (WidgetTester tester) async {
        // Pump the app with unauthenticated state
        await pumpApp(tester, authenticated: false);
        await tester.pumpAndSettle();
        
        // Verify no redirect occurs and AuthScreen is displayed
        expect(find.byType(AuthScreen), findsOneWidget);
        expect(find.text('Home Screen - Coming Soon'), findsNothing);
      });

      testWidgets('unauthenticated user redirected from /home to root', (WidgetTester tester) async {
        // Configure MockGoTrueClient to return null for currentSession
        setupAuthState(false);
        
        // Pump the app
        await pumpApp(tester);
        await tester.pumpAndSettle();
        
        // Attempt to navigate to /home
        final router = (tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig as GoRouter);
        router.go('/home');
        await tester.pumpAndSettle();
        
        // Verify redirect to '/' occurs and AuthScreen is displayed
        expect(find.byType(AuthScreen), findsOneWidget);
        expect(find.text('Home Screen - Coming Soon'), findsNothing);
      });

      testWidgets('redirect logic checks currentSession', (WidgetTester tester) async {
        // Pump the app with unauthenticated state
        await pumpApp(tester, authenticated: false);
        await tester.pumpAndSettle();
        
        // Verify that SupabaseService.client.auth.currentSession is accessed during redirect
        verify(() => SupabaseService.client.auth.currentSession).called(1);
      });

      testWidgets('unauthenticated user cannot access protected routes', (WidgetTester tester) async {
        // Configure MockGoTrueClient to return null for currentSession
        setupAuthState(false);
        
        // Pump the app
        await pumpApp(tester);
        await tester.pumpAndSettle();
        
        // Try navigating to /home
        final router = (tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig as GoRouter);
        router.go('/home');
        await tester.pumpAndSettle();
        
        // Verify user ends up on '/' with AuthScreen
        expect(find.byType(AuthScreen), findsOneWidget);
        expect(find.text('Home Screen - Coming Soon'), findsNothing);
      });
    });

    group('Authentication Redirect Logic - Authenticated User', () {
      testWidgets('authenticated user redirected from root to /home', (WidgetTester tester) async {
        // Pump the app with authenticated state
        await pumpApp(tester, authenticated: true);
        await tester.pumpAndSettle();
        
        // Verify redirect to /home occurs
        expect(find.text('Home Screen - Coming Soon'), findsOneWidget);
        expect(find.byType(AuthScreen), findsNothing);
      });

      testWidgets('authenticated user can access /home', (WidgetTester tester) async {
        // Configure MockGoTrueClient to return a valid MockSession
        setupAuthState(true);
        
        // Pump the app
        await pumpApp(tester);
        await tester.pumpAndSettle();
        
        // Navigate to /home
        final router = (tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig as GoRouter);
        router.go('/home');
        await tester.pumpAndSettle();
        
        // Verify no redirect and 'Home Screen - Coming Soon' text is displayed
        expect(find.text('Home Screen - Coming Soon'), findsOneWidget);
      });

      testWidgets('redirect logic uses currentSession for authentication check', (WidgetTester tester) async {
        // Configure MockGoTrueClient to return a valid MockSession
        setupAuthState(true);
        
        // Pump the app
        await pumpApp(tester);
        await tester.pumpAndSettle();
        
        // Verify the redirect function checks currentSession != null
        verify(() => SupabaseService.client.auth.currentSession).called(1);
      });

      testWidgets('authenticated user bypasses auth screen', (WidgetTester tester) async {
        // Pump the app with authenticated state
        await pumpApp(tester, authenticated: true);
        await tester.pumpAndSettle();
        
        // Verify automatic redirect to /home
        expect(find.text('Home Screen - Coming Soon'), findsOneWidget);
        expect(find.byType(AuthScreen), findsNothing);
      });
    });

    group('Integration - Complete App Flow', () {
      testWidgets('app renders with unauthenticated state', (WidgetTester tester) async {
        // Pump JobOrderManagementApp with unauthenticated state
        await pumpApp(tester, authenticated: false);
        await tester.pumpAndSettle();
        
        // Verify AuthScreen is displayed
        expect(find.byType(AuthScreen), findsOneWidget);
      });

      testWidgets('app renders with authenticated state', (WidgetTester tester) async {
        // Pump JobOrderManagementApp with authenticated state
        await pumpApp(tester, authenticated: true);
        await tester.pumpAndSettle();
        
        // Verify redirect to /home and placeholder text is shown
        expect(find.text('Home Screen - Coming Soon'), findsOneWidget);
      });

      testWidgets('app handles theme changes', (WidgetTester tester) async {
        // Pump app
        await pumpApp(tester);
        
        // Verify both light and dark themes are configured and can be accessed
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme, isNotNull);
        expect(materialApp.darkTheme, isNotNull);
        expect(materialApp.themeMode, equals(ThemeMode.system));
      });

      testWidgets('app maintains state through rebuilds', (WidgetTester tester) async {
        // Pump app with unauthenticated state
        await pumpApp(tester, authenticated: false);
        await tester.pumpAndSettle();
        
        // Verify AuthScreen is displayed
        expect(find.byType(AuthScreen), findsOneWidget);
        
        // Trigger rebuild
        await tester.pumpWidget(
          const ProviderScope(
            child: JobOrderManagementApp(),
          ),
        );
        await tester.pumpAndSettle();
        
        // Verify state is maintained through ProviderScope
        expect(find.byType(AuthScreen), findsOneWidget);
      });
    });

    group('Environment and Supabase Mocking', () {
      testWidgets('MockDotEnv provides test environment variables', (WidgetTester tester) async {
        // Verify MockDotEnv.getTestEnv('SUPABASE_URL') returns test URL
        expect(MockDotEnv.getTestEnv('SUPABASE_URL'), equals('https://test.supabase.co'));
      });

      testWidgets('MockDotEnv provides test Supabase keys', (WidgetTester tester) async {
        // Verify MockDotEnv.getTestEnv('SUPABASE_ANON_KEY') returns test key
        expect(MockDotEnv.getTestEnv('SUPABASE_ANON_KEY'), isNotNull);
        expect(MockDotEnv.getTestEnv('SUPABASE_ANON_KEY')!.startsWith('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'), isTrue);
      });

      testWidgets('SupabaseService uses test client', (WidgetTester tester) async {
        // Verify SupabaseService.client returns the mocked client set by setupMockSupabase()
        expect(SupabaseService.client, isA<MockSupabaseClient>());
      });

      testWidgets('test client auth is mocked', (WidgetTester tester) async {
        // Verify SupabaseService.client.auth returns MockGoTrueClient instance
        expect(SupabaseService.client.auth, isA<MockGoTrueClient>());
      });
    });
  });
}

// Helper functions within the test file

/// Helper function to pump the full app with optional authentication state
Future<void> pumpApp(WidgetTester tester, {bool? authenticated}) async {
  // Set up authentication state only if explicitly specified
  if (authenticated != null) {
    setupAuthState(authenticated);
  }
  
  await tester.pumpWidget(
    const ProviderScope(
      child: JobOrderManagementApp(),
    ),
  );
}

/// Helper function to pump the app with AuthScreen and disable dev mode
Future<void> pumpAppWithAuthScreen(WidgetTester tester, {bool? authenticated}) async {
  // Set up authentication state only if explicitly specified
  if (authenticated != null) {
    setupAuthState(authenticated);
  }
  
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: const AuthScreen(isDevMode: false),
      ),
    ),
  );
}

/// Helper function to configure mock Supabase auth state before pumping app
void setupAuthState(bool authenticated) {
  final mockClient = SupabaseService.client as MockSupabaseClient;
  final mockAuth = mockClient.auth as MockGoTrueClient;
  
  // Reset stubs to avoid conflicts
  reset(mockAuth);
  
  if (authenticated) {
    when(() => mockAuth.currentSession).thenReturn(createMockAuthSession());
    when(() => mockAuth.currentUser).thenReturn(createMockUser());
  } else {
    when(() => mockAuth.currentSession).thenReturn(null);
    when(() => mockAuth.currentUser).thenReturn(null);
  }
}

/// Helper function to verify AuthScreen is displayed
void verifyAuthScreen(WidgetTester tester) {
  expect(find.byType(AuthScreen), findsOneWidget);
}

/// Helper function to verify home placeholder is displayed
void verifyHomeScreen(WidgetTester tester) {
  expect(find.text('Home Screen - Coming Soon'), findsOneWidget);
}

/// Helper function to find and return the MaterialApp widget for property inspection
MaterialApp getMaterialApp(WidgetTester tester) {
  return tester.widget<MaterialApp>(find.byType(MaterialApp));
}
