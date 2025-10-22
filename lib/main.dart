import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/auth/presentation/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
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
          final isAuthenticated = Supabase.instance.client.auth.currentSession != null;
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
                child: Text('Home Screen - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
