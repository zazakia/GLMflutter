import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/auth/presentation/screens/auth_screen.dart';
import 'core/services/supabase_service.dart';
import 'core/widgets/supabase_connection_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // DEBUG: Log environment variables
  debugPrint('=== DEBUG: Environment Variables ===');
  debugPrint('SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}');
  debugPrint('SUPABASE_ANON_KEY: ${dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 10)}...');
  debugPrint('Environment loaded: ${dotenv.env['ENVIRONMENT']}');
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    debugPrint('=== DEBUG: Supabase Initialization Successful ===');
  } catch (e) {
    debugPrint('=== DEBUG: Supabase Initialization Failed ===');
    debugPrint('Error: $e');
    debugPrint('Error Type: ${e.runtimeType}');
  }
  
  runApp(
    const ProviderScope(
      child: JobOrderManagementApp(),
    ),
  );
}

class JobOrderManagementApp extends ConsumerWidget {
  const JobOrderManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Job Order Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'PH'), // English (Philippines)
      ],
      routerConfig: GoRouter(
        initialLocation: '/',
        redirect: (context, state) {
          final isAuthenticated = SupabaseService.client.auth.currentSession != null;
          final isAuthRoute = state.uri.toString() == '/';
          
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
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Home Screen - Coming Soon'),
                    SizedBox(height: 20),
                    SupabaseConnectionStatusWidget(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
