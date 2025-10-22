import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/supabase_service.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';

// Route names
class Routes {
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String jobOrders = '/job-orders';
  static const String jobOrderDetail = '/job-order-detail';
  static const String createJobOrder = '/create-job-order';
  static const String editJobOrder = '/edit-job-order';
  static const String serviceReports = '/service-reports';
  static const String serviceReportDetail = '/service-report-detail';
  static const String createServiceReport = '/create-service-report';
  static const String editServiceReport = '/edit-service-report';
  static const String inventory = '/inventory';
  static const String inventoryDetail = '/inventory-detail';
  static const String createInventoryItem = '/create-inventory-item';
  static const String editInventoryItem = '/edit-inventory-item';
  static const String estimates = '/estimates';
  static const String estimateDetail = '/estimate-detail';
  static const String createEstimate = '/create-estimate';
  static const String editEstimate = '/edit-estimate';
  static const String invoices = '/invoices';
  static const String invoiceDetail = '/invoice-detail';
  static const String createInvoice = '/create-invoice';
  static const String editInvoice = '/edit-invoice';
  static const String payments = '/payments';
  static const String paymentDetail = '/payment-detail';
  static const String createPayment = '/create-payment';
  static const String editPayment = '/edit-payment';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String users = '/users';
  static const String userDetail = '/user-detail';
  static const String createUser = '/create-user';
  static const String editUser = '/edit-user';
  static const String branches = '/branches';
  static const String branchDetail = '/branch-detail';
  static const String createBranch = '/create-branch';
  static const String editBranch = '/edit-branch';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
}

// GoRouter configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: Routes.splash,
    redirect: (context, state) {
      final isAuthenticated = SupabaseService.client.auth.currentSession != null;
      
      // Check if user is authenticated
      if (!isAuthenticated) {
        return Routes.auth;
      }
      
      // If authenticated and trying to access auth routes, redirect to home
      if (state.uri.toString().startsWith(Routes.auth)) {
        return Routes.home;
      }
      
      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      
      // Authentication routes
      GoRoute(
        path: Routes.auth,
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: Routes.login,
            builder: (context, state) => const AuthScreen(),
          ),
          GoRoute(
            path: Routes.register,
            builder: (context, state) => const AuthScreen(),
          ),
          GoRoute(
            path: Routes.forgotPassword,
            builder: (context, state) => const AuthScreen(),
          ),
        ],
      ),
      
      // Main app routes (protected)
      ShellRoute(
        builder: (context, state, child) {
          // This would be your main app shell with navigation
          return Scaffold(
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Home'),
              ),
            ),
          ),
          GoRoute(
            path: Routes.dashboard,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Dashboard'),
              ),
            ),
          ),
          GoRoute(
            path: Routes.jobOrders,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Job Orders'),
              ),
            ),
            routes: [
              GoRoute(
                path: '/:id',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: Text('Job Order Detail: ${state.pathParameters['id']}'),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.serviceReports,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Service Reports'),
              ),
            ),
            routes: [
              GoRoute(
                path: '/:id',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: Text('Service Report Detail: ${state.pathParameters['id']}'),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.inventory,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Inventory'),
              ),
            ),
            routes: [
              GoRoute(
                path: '/:id',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: Text('Inventory Detail: ${state.pathParameters['id']}'),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.estimates,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Estimates'),
              ),
            ),
            routes: [
              GoRoute(
                path: '/:id',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: Text('Estimate Detail: ${state.pathParameters['id']}'),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.invoices,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Invoices'),
              ),
            ),
            routes: [
              GoRoute(
                path: '/:id',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: Text('Invoice Detail: ${state.pathParameters['id']}'),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.payments,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Payments'),
              ),
            ),
            routes: [
              GoRoute(
                path: '/:id',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: Text('Payment Detail: ${state.pathParameters['id']}'),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Settings'),
              ),
            ),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Profile'),
              ),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Something went wrong!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});