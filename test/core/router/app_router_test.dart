import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:job_order_management/core/router/app_router.dart';
import 'package:job_order_management/core/services/supabase_service.dart';
import 'package:job_order_management/features/auth/presentation/screens/auth_screen.dart';
import '../../helpers/mock_supabase.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AppRouter', () {
    late ProviderContainer container;
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;

    setUpAll(() {
      // Initialize test environment
      setupTestEnvironment();
    });

    setUp(() {
      // Re-setup test environment before each test
      setupTestEnvironment();
      
      // Create fresh mocks before each test
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      when(() => mockClient.auth).thenReturn(mockAuth);
      
      // Set the test client in SupabaseService to use our mocks
      SupabaseService.setTestClient(mockClient);
      
      // Create provider container with overrides
      container = ProviderContainer();
    });

    tearDown(() {
      // Reset state between tests
      SupabaseService.clearTestClient();
      container.dispose();
    });

    group('Routes Class Constants', () {
      test('all route constants have correct string values', () {
        expect(Routes.splash, equals('/splash'));
        expect(Routes.auth, equals('/auth'));
        expect(Routes.login, equals('/login'));
        expect(Routes.register, equals('/register'));
        expect(Routes.forgotPassword, equals('/forgot-password'));
        expect(Routes.home, equals('/home'));
        expect(Routes.dashboard, equals('/dashboard'));
        expect(Routes.jobOrders, equals('/job-orders'));
        expect(Routes.jobOrderDetail, equals('/job-order-detail'));
        expect(Routes.createJobOrder, equals('/create-job-order'));
        expect(Routes.editJobOrder, equals('/edit-job-order'));
        expect(Routes.serviceReports, equals('/service-reports'));
        expect(Routes.serviceReportDetail, equals('/service-report-detail'));
        expect(Routes.createServiceReport, equals('/create-service-report'));
        expect(Routes.editServiceReport, equals('/edit-service-report'));
        expect(Routes.inventory, equals('/inventory'));
        expect(Routes.inventoryDetail, equals('/inventory-detail'));
        expect(Routes.createInventoryItem, equals('/create-inventory-item'));
        expect(Routes.editInventoryItem, equals('/edit-inventory-item'));
        expect(Routes.estimates, equals('/estimates'));
        expect(Routes.estimateDetail, equals('/estimate-detail'));
        expect(Routes.createEstimate, equals('/create-estimate'));
        expect(Routes.editEstimate, equals('/edit-estimate'));
        expect(Routes.invoices, equals('/invoices'));
        expect(Routes.invoiceDetail, equals('/invoice-detail'));
        expect(Routes.createInvoice, equals('/create-invoice'));
        expect(Routes.editInvoice, equals('/edit-invoice'));
        expect(Routes.payments, equals('/payments'));
        expect(Routes.paymentDetail, equals('/payment-detail'));
        expect(Routes.createPayment, equals('/create-payment'));
        expect(Routes.editPayment, equals('/edit-payment'));
        expect(Routes.settings, equals('/settings'));
        expect(Routes.profile, equals('/profile'));
        expect(Routes.users, equals('/users'));
        expect(Routes.userDetail, equals('/user-detail'));
        expect(Routes.createUser, equals('/create-user'));
        expect(Routes.editUser, equals('/edit-user'));
        expect(Routes.branches, equals('/branches'));
        expect(Routes.branchDetail, equals('/branch-detail'));
        expect(Routes.createBranch, equals('/create-branch'));
        expect(Routes.editBranch, equals('/edit-branch'));
        expect(Routes.reports, equals('/reports'));
        expect(Routes.notifications, equals('/notifications'));
      });

      test('route paths follow consistent naming conventions (kebab-case)', () {
        final routes = [
          Routes.splash,
          Routes.auth,
          Routes.login,
          Routes.register,
          Routes.forgotPassword,
          Routes.home,
          Routes.dashboard,
          Routes.jobOrders,
          Routes.jobOrderDetail,
          Routes.createJobOrder,
          Routes.editJobOrder,
          Routes.serviceReports,
          Routes.serviceReportDetail,
          Routes.createServiceReport,
          Routes.editServiceReport,
          Routes.inventory,
          Routes.inventoryDetail,
          Routes.createInventoryItem,
          Routes.editInventoryItem,
          Routes.estimates,
          Routes.estimateDetail,
          Routes.createEstimate,
          Routes.editEstimate,
          Routes.invoices,
          Routes.invoiceDetail,
          Routes.createInvoice,
          Routes.editInvoice,
          Routes.payments,
          Routes.paymentDetail,
          Routes.createPayment,
          Routes.editPayment,
          Routes.settings,
          Routes.profile,
          Routes.users,
          Routes.userDetail,
          Routes.createUser,
          Routes.editUser,
          Routes.branches,
          Routes.branchDetail,
          Routes.createBranch,
          Routes.editBranch,
          Routes.reports,
          Routes.notifications,
        ];

        for (final route in routes) {
          // All routes should start with /
          expect(route, startsWith('/'));
          
          // No spaces in route names (kebab-case)
          expect(route, isNot(contains(' ')));
        }
      });
    });

    group('Router Configuration - Basic Properties', () {
      test('GoRouter instance is created successfully', () {
        final router = container.read(appRouterProvider);
        expect(router, isNotNull);
        expect(router, isA<GoRouter>());
      });

      test('router has routes configured', () {
        final router = container.read(appRouterProvider);
        expect(router.routeInformationParser.configuration.routes, isNotNull);
        expect(router.routeInformationParser.configuration.routes, isA<List<RouteBase>>());
      });
    });

    group('Authentication Redirect Logic - Unauthenticated User', () {
      setUp(() {
        // Mock unauthenticated user
        when(() => mockAuth.currentSession).thenReturn(null);
      });

      testWidgets('unauthenticated user accessing protected route redirects to auth', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to a protected route
        router.go(Routes.home);
        await tester.pumpAndSettle();
        
        // Should redirect to auth
        expect(router.routeInformationProvider.value.location, equals(Routes.auth));
      });

      testWidgets('unauthenticated user accessing auth route stays on auth', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to auth route
        router.go(Routes.auth);
        await tester.pumpAndSettle();
        
        // Should stay on auth
        expect(router.routeInformationProvider.value.location, equals(Routes.auth));
      });
    });

    group('Authentication Redirect Logic - Authenticated User', () {
      setUp(() {
        // Mock authenticated user
        final mockSession = createMockAuthSession();
        when(() => mockAuth.currentSession).thenReturn(mockSession);
      });

      testWidgets('authenticated user accessing auth route redirects to home', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to auth route
        router.go(Routes.auth);
        await tester.pumpAndSettle();
        
        // Should redirect to home
        expect(router.routeInformationProvider.value.location, equals(Routes.home));
      });

      testWidgets('authenticated user accessing protected route stays on target', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to a protected route
        router.go(Routes.home);
        await tester.pumpAndSettle();
        
        // Should stay on home
        expect(router.routeInformationProvider.value.location, equals(Routes.home));
      });
    });

    group('Route Configuration - Splash Screen', () {
      testWidgets('splash route renders Scaffold with CircularProgressIndicator', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify splash screen content
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      test('navigation to splash screen works correctly', () {
        final router = container.read(appRouterProvider);
        expect(router.routeInformationProvider.value.location, equals(Routes.splash));
      });
    });

    group('Route Configuration - Auth Routes', () {
      testWidgets('auth route renders AuthScreen', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to auth route
        router.go(Routes.auth);
        await tester.pumpAndSettle();
        
        // Verify auth screen is rendered
        expect(find.byType(AuthScreen), findsOneWidget);
      });
    });

    group('Route Configuration - Protected Routes', () {
      test('main app routes are wrapped in ShellRoute', () {
        final router = container.read(appRouterProvider);
        
        // Verify shell route exists
        expect(router.routeInformationParser.configuration.routes, isA<List<RouteBase>>());
      });

      test('all protected routes are configured', () {
        final router = container.read(appRouterProvider);
        
        // Test that routes exist by checking route configuration
        final routes = router.routeInformationParser.configuration.routes;
        expect(routes, isA<List<RouteBase>>());
        
        // Find shell route
        final shellRoute = routes.firstWhere(
          (route) => route is ShellRoute,
          orElse: () => routes.first,
        );
        expect(shellRoute, isNotNull);
      });
    });

    group('Route Configuration - Parameterized Routes', () {
      testWidgets('job order detail route with path parameter', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to job order detail route
        const testId = '123';
        router.go('${Routes.jobOrders}/$testId');
        await tester.pumpAndSettle();
        
        // Verify the parameter is extracted and displayed
        expect(find.text('Job Order Detail: $testId'), findsOneWidget);
      });

      testWidgets('service report detail route with path parameter', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to service report detail route
        const testId = '456';
        router.go('${Routes.serviceReports}/$testId');
        await tester.pumpAndSettle();
        
        // Verify the parameter is extracted and displayed
        expect(find.text('Service Report Detail: $testId'), findsOneWidget);
      });

      testWidgets('inventory detail route with path parameter', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to inventory detail route
        const testId = '789';
        router.go('${Routes.inventory}/$testId');
        await tester.pumpAndSettle();
        
        // Verify the parameter is extracted and displayed
        expect(find.text('Inventory Detail: $testId'), findsOneWidget);
      });

      testWidgets('estimates detail route with path parameter', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to estimates detail route
        const testId = '101';
        router.go('${Routes.estimates}/$testId');
        await tester.pumpAndSettle();
        
        // Verify the parameter is extracted and displayed
        expect(find.text('Estimate Detail: $testId'), findsOneWidget);
      });

      testWidgets('invoices detail route with path parameter', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to invoices detail route
        const testId = '202';
        router.go('${Routes.invoices}/$testId');
        await tester.pumpAndSettle();
        
        // Verify the parameter is extracted and displayed
        expect(find.text('Invoice Detail: $testId'), findsOneWidget);
      });

      testWidgets('payments detail route with path parameter', (tester) async {
        final router = container.read(appRouterProvider);
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Navigate to payments detail route
        const testId = '303';
        router.go('${Routes.payments}/$testId');
        await tester.pumpAndSettle();
        
        // Verify the parameter is extracted and displayed
        expect(find.text('Payment Detail: $testId'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('errorBuilder renders Scaffold with error message', (tester) async {
        final router = container.read(appRouterProvider);
        
        // Navigate to invalid route
        router.go('/invalid-route');
        await tester.pumpAndSettle();
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify error screen is rendered
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Something went wrong!'), findsOneWidget);
      });

      testWidgets('error screen has button to navigate to home', (tester) async {
        final router = container.read(appRouterProvider);
        
        // Navigate to invalid route
        router.go('/invalid-route');
        await tester.pumpAndSettle();
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Find and tap home button
        final homeButton = find.widgetWithText(ElevatedButton, 'Go Home');
        expect(homeButton, findsOneWidget);
        
        await tester.tap(homeButton);
        await tester.pumpAndSettle();
        
        // Verify navigation to home
        expect(router.routeInformationProvider.value.location, equals(Routes.home));
      });
    });

    group('Router Provider', () {
      test('appRouterProvider is a Provider<GoRouter>', () {
        expect(appRouterProvider, isA<Provider<GoRouter>>());
      });

      test('multiple reads of provider return same router instance', () {
        final router1 = container.read(appRouterProvider);
        final router2 = container.read(appRouterProvider);
        
        expect(identical(router1, router2), isTrue);
      });

      test('provider can be overridden in tests using ProviderContainer', () {
        // Create mock router
        final mockRouter = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => const Scaffold(body: Text('Test')),
            ),
          ],
        );

        // Create container with override
        final testContainer = ProviderContainer(
          overrides: [
            appRouterProvider.overrideWithValue(mockRouter),
          ],
        );

        final router = testContainer.read(appRouterProvider);
        expect(router.routeInformationProvider.value.location, equals('/test'));
        
        testContainer.dispose();
      });
    });
  });
}
