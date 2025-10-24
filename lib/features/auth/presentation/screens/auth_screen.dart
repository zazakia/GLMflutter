import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/supabase_connection_indicator.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.isDevMode});

  final bool? isDevMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool get _isDevMode => widget.isDevMode ?? const bool.fromEnvironment('dart.vm.product') == false;

  static const String appName = 'Job Order Management';
  static const Color successColor = Color(0xFF388E3C);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color primaryColor = Color(0xFF1976D2);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Login
        await SupabaseService.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Register
        await SupabaseService.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Show registration success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please check your email to verify your account.'),
              backgroundColor: successColor,
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _devLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // DEBUG: Log Supabase configuration
      debugPrint('=== DEBUG: Supabase Configuration ===');
      debugPrint('URL: ${SupabaseService.supabaseUrl}');
      debugPrint('Anon Key: ${SupabaseService.supabaseAnonKey.substring(0, 10)}...');
      debugPrint('Client initialized: ${SupabaseService.client != null}');
      
      // DEBUG: Check if user exists before attempting login
      debugPrint('=== DEBUG: Attempting Demo Login ===');
      debugPrint('Email: admin@demo-company.com');
      debugPrint('Password: demo123456');
      
      // Try to sign in with demo credentials
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: 'admin@demo-company.com',
        password: 'demo123456',
      );
      
      debugPrint('=== DEBUG: Login Response ===');
      debugPrint('Session: ${response.session != null}');
      debugPrint('User: ${response.user?.email}');
      debugPrint('Error: ${response.user?.isAnonymous == true ? 'Anonymous user' : 'Authenticated user'}');
      
      // If that fails, we'll show an error message
      if (SupabaseService.client.auth.currentSession == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demo user not found. Please create it manually in Supabase.'),
              backgroundColor: errorColor,
            ),
          );
        }
      }
    } on AuthException catch (e) {
      debugPrint('=== DEBUG: AuthException ===');
      debugPrint('Error Code: ${e.statusCode}');
      debugPrint('Error Message: ${e.message}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auth Error (${e.statusCode}): ${e.message}'),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('=== DEBUG: General Exception ===');
      debugPrint('Error: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dev login failed: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or App Name
                  const Icon(
                    Icons.business_center,
                    size: 80,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appName,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Development mode indicator
                  if (_isDevMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        'DEVELOPMENT MODE',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  
                  if (_isDevMode) const SizedBox(height: 16),
                  
                  // Supabase Connection Indicator (only in development mode)
                  if (_isDevMode)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: SupabaseConnectionIndicator(
                        compact: true,
                        showRetryButton: true,
                      ),
                    ),
                  
                  // Email Field
                  TextFormField(
                    key: const Key('email_field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFormField(
                    key: const Key('password_field'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isLogin ? 'Login' : 'Register'),
                  ),
                  
                  // Dev Login Button (only in development mode)
                  if (_isDevMode) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _devLogin,
                      icon: const Icon(Icons.developer_mode),
                      label: const Text('1-Click Admin Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Toggle between Login and Register
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Don\'t have an account? Register'
                          : 'Already have an account? Login',
                    ),
                  ),
                  
                  // Forgot Password (only for login)
                  if (_isLogin)
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Forgot password feature coming soon!'),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}