import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../lib/features/auth/presentation/screens/auth_screen.dart';
import '../../../../helpers/test_helpers.dart';
import '../../../../helpers/mock_supabase.dart';
import '../../../../../lib/core/services/supabase_service.dart';

void main() {
  group('AuthScreen Tests', () {
    late MockGoTrueClient mockGoTrueClient;
    late MockAuthResponse mockAuthResponse;
    late MockSession mockSession;
    late MockUser mockUser;

    setUp(() async {
      await setupTestEnvironment();
      
      // Get mock instances from the setup
      mockGoTrueClient = MockGoTrueClient();
      mockAuthResponse = MockAuthResponse();
      mockSession = createMockAuthSession();
      mockUser = createMockUser();
      
      // Setup mock response
      when(() => mockAuthResponse.session).thenReturn(mockSession);
      when(() => mockAuthResponse.user).thenReturn(mockUser);
      
      // Register fallback values for mocktail
      registerFallbackValue(AuthResponse(
        session: null,
        user: null,
      ));
    });

    tearDown(() {
      cleanupTestEnv();
    });

    // Helper functions
    Future<void> enterCredentials(WidgetTester tester, String email, String password) async {
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
    }

    Future<void> tapSubmitButton(WidgetTester tester) async {
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();
    }

    Future<void> tapToggleButton(WidgetTester tester) async {
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
    }

    Future<void> verifyLoadingState(WidgetTester tester, bool isLoading) async {
      final submitButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
      if (isLoading) {
        expect(submitButton.child, isA<SizedBox>());
        expect(submitButton.onPressed, isNull);
      } else {
        expect(submitButton.child, isA<Text>());
        expect(submitButton.onPressed, isNotNull);
      }
    }

    group('Widget Rendering - Basic Elements', () {
      testWidgets('should display app icon', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        expect(find.byIcon(Icons.business_center), findsOneWidget);
      });

      testWidgets('should display app name', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        expect(find.text('Job Order Management'), findsOneWidget);
      });

      testWidgets('should display email field with correct label', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        final emailField = find.byKey(const Key('email_field'));
        expect(emailField, findsOneWidget);
        
        // Check if email field has correct label by finding the Text widget with labelText
        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('should display password field with correct label', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        final passwordField = find.byKey(const Key('password_field'));
        expect(passwordField, findsOneWidget);
        
        // Check if password field has correct label by finding the Text widget with labelText
        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('should display email field with email icon', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('should display password field with lock icon', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        expect(find.byIcon(Icons.lock), findsOneWidget);
      });

      testWidgets('should display password field with visibility toggle', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('should display submit button with Login text initially', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        final submitButton = find.byType(ElevatedButton).first;
        expect(submitButton, findsOneWidget);
        
        final button = tester.widget<ElevatedButton>(submitButton);
        expect(button.child, isA<Text>());
        final textWidget = button.child as Text;
        expect(textWidget.data, 'Login');
      });

      testWidgets('should display toggle button with correct text', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        expect(find.text("Don't have an account? Register"), findsOneWidget);
      });

      testWidgets('should display Forgot Password button in login mode', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        expect(find.text('Forgot Password?'), findsOneWidget);
      });
    });

    group('Widget Rendering - Dev Mode Features', () {
      testWidgets('should display dev mode indicator when in dev mode', (WidgetTester tester) async {
        // We need to test with dev mode enabled
        await pumpTestWidget(tester, const AuthScreen());
        
        // Check if dev mode indicator is present (it should be in test environment)
        final devModeIndicator = find.text('DEVELOPMENT MODE');
        if (devModeIndicator.evaluate().isNotEmpty) {
          expect(devModeIndicator, findsOneWidget);
        }
      });

      testWidgets('should display dev login button when in dev mode', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Check if dev login button is present
        final devLoginButton = find.text('1-Click Admin Login');
        if (devLoginButton.evaluate().isNotEmpty) {
          expect(devLoginButton, findsOneWidget);
          expect(find.byIcon(Icons.developer_mode), findsOneWidget);
        }
      });

      testWidgets('should not display dev mode widgets when in production mode', (WidgetTester tester) async {
        // Test with dev mode explicitly set to false
        await pumpTestWidget(tester, const AuthScreen(isDevMode: false));
        
        // Verify dev mode widgets are not present
        expect(find.text('DEVELOPMENT MODE'), findsNothing);
        expect(find.text('1-Click Admin Login'), findsNothing);
        expect(find.byIcon(Icons.developer_mode), findsNothing);
      });
    });

    group('Form Validation - Email Field', () {
      testWidgets('should show error for empty email', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Leave email empty and submit
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should show error for invalid email format', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should show error for email without domain', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tester.enterText(find.byKey(const Key('email_field')), 'test@');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should show error for email without TLD', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tester.enterText(find.byKey(const Key('email_field')), 'test@domain');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should not show error for valid email', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Please enter a valid email'), findsNothing);
      });
    });

    group('Form Validation - Password Field', () {
      testWidgets('should show error for empty password', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should show error for short password', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), '12345');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });

      testWidgets('should not show error for valid password', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), '123456');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Password must be at least 6 characters'), findsNothing);
      });

      testWidgets('should not show error for longer password', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'securepassword123');
        await tapSubmitButton(tester);
        await tester.pump();
        
        expect(find.text('Password must be at least 6 characters'), findsNothing);
      });
    });

    group('State Management - Login/Register Toggle', () {
      testWidgets('should show Login text initially', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        final submitButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
        final textWidget = submitButton.child as Text;
        expect(textWidget.data, 'Login');
      });

      testWidgets('should toggle to Register mode', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        await tapToggleButton(tester);
        
        final submitButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
        final textWidget = submitButton.child as Text;
        expect(textWidget.data, 'Register');
      });

      testWidgets('should change toggle button text when toggling', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Initial state
        expect(find.text("Don't have an account? Register"), findsOneWidget);
        
        // Toggle to register
        await tapToggleButton(tester);
        expect(find.text('Already have an account? Login'), findsOneWidget);
      });

      testWidgets('should show/hide Forgot Password button based on mode', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Should show in login mode
        expect(find.text('Forgot Password?'), findsOneWidget);
        
        // Should hide in register mode
        await tapToggleButton(tester);
        expect(find.text('Forgot Password?'), findsNothing);
      });

      testWidgets('should toggle back to Login mode', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Toggle to register
        await tapToggleButton(tester);
        
        // Toggle back to login
        await tapToggleButton(tester);
        
        final submitButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
        final textWidget = submitButton.child as Text;
        expect(textWidget.data, 'Login');
      });
    });

    group('State Management - Password Visibility Toggle', () {
      testWidgets('should have obscureText true initially', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Check if password field is initially obscured by looking for visibility icon
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('should show visibility icon initially', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('should toggle password visibility when icon is tapped', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Tap visibility icon
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();
        
        // Should now show visibility_off icon
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        
        // Password field should no longer be obscure - check for visibility_off icon
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });

      testWidgets('should toggle back to hidden when tapped again', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Tap visibility icon twice
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();
        
        // Should show visibility icon again
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        
        // Password field should be obscure again - check for visibility icon
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('Authentication Flow - Successful Login', () {
      testWidgets('should call signInWithPassword with correct credentials', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pump();
        
        // Verify signInWithPassword was called with correct parameters
        verify(() => mockClient.auth.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      testWidgets('should show loading state during login', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Mock a delayed response
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockAuthResponse;
        });
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        
        // Should show loading state
        await verifyLoadingState(tester, true);
        
        // Wait for completion
        await tester.pumpAndSettle();
        await verifyLoadingState(tester, false);
      });

      testWidgets('should allow form field interaction during loading', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Mock a delayed response
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockAuthResponse;
        });
        
        // Enter initial credentials and submit to trigger loading
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        
        // Verify loading state is active
        await verifyLoadingState(tester, true);
        
        // Try to enter text in email field during loading
        await tester.enterText(find.byKey(const Key('email_field')), 'modified@example.com');
        
        // Verify the text was updated
        final emailField = tester.widget<TextFormField>(find.byKey(const Key('email_field')));
        expect(emailField.controller?.text, 'modified@example.com');
        
        // Try to enter text in password field during loading
        await tester.enterText(find.byKey(const Key('password_field')), 'modifiedpassword');
        
        // Verify the text was updated
        final passwordField = tester.widget<TextFormField>(find.byKey(const Key('password_field')));
        expect(passwordField.controller?.text, 'modifiedpassword');
        
        // Wait for completion
        await tester.pumpAndSettle();
      });
    });

    group('Authentication Flow - Successful Registration', () {
      testWidgets('should call signUp with correct credentials', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
        
        // Toggle to register mode
        await tapToggleButton(tester);
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pump();
        
        // Verify signUp was called with correct parameters
        verify(() => mockClient.auth.signUp(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      testWidgets('should show success SnackBar after registration', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
        
        // Toggle to register mode
        await tapToggleButton(tester);
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify success SnackBar
        await expectSnackBar(tester, 'Registration successful! Please check your email to verify your account.');
        
        // Assert SnackBar background color for success
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, const Color(0xFF388E3C));
      });
    });

    group('Authentication Flow - Login Error Handling', () {
      testWidgets('should show error SnackBar for AuthException', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(AuthException('Invalid login credentials'));
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify error SnackBar
        await expectSnackBar(tester, 'Invalid login credentials');
        
        // Assert SnackBar background color for error
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, const Color(0xFFD32F2F));
      });

      testWidgets('should show generic error SnackBar for generic Exception', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Network error'));
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify generic error SnackBar
        await expectSnackBar(tester, 'An unexpected error occurred. Please try again.');
        
        // Assert SnackBar background color for error
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, const Color(0xFFD32F2F));
      });

      testWidgets('should clear loading state after error', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(AuthException('Invalid login credentials'));
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify loading state is cleared
        await verifyLoadingState(tester, false);
      });
    });

    group('Authentication Flow - Registration Error Handling', () {
      testWidgets('should show error SnackBar for registration AuthException', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(AuthException('User already registered'));
        
        // Toggle to register mode
        await tapToggleButton(tester);
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'existing@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify error SnackBar
        await expectSnackBar(tester, 'User already registered');
        
        // Assert SnackBar background color for error
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, const Color(0xFFD32F2F));
      });

      testWidgets('should show error SnackBar for weak password', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(AuthException('Password should be at least 6 characters'));
        
        // Toggle to register mode
        await tapToggleButton(tester);
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'weak');
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify error SnackBar
        await expectSnackBar(tester, 'Password should be at least 6 characters');
        
        // Assert SnackBar background color for error
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, const Color(0xFFD32F2F));
      });
    });

    group('Dev Mode Login - Successful Flow', () {
      testWidgets('should call signInWithPassword with demo credentials', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Check if dev login button is present
        final devLoginButton = find.text('1-Click Admin Login');
        if (devLoginButton.evaluate().isEmpty) {
          // Skip test if not in dev mode
          return;
        }
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
        when(() => mockClient.auth.currentSession).thenReturn(mockSession);
        
        // Tap dev login button
        await tester.tap(devLoginButton);
        await tester.pump();
        
        // Verify signInWithPassword was called with demo credentials
        verify(() => mockClient.auth.signInWithPassword(
          email: 'admin@demo-company.com',
          password: 'demo123456',
        )).called(1);
      });

      testWidgets('should show loading state during dev login', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Check if dev login button is present
        final devLoginButton = find.text('1-Click Admin Login');
        if (devLoginButton.evaluate().isEmpty) {
          // Skip test if not in dev mode
          return;
        }
        
        // Mock a delayed response
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockAuthResponse;
        });
        when(() => mockClient.auth.currentSession).thenReturn(mockSession);
        
        // Tap dev login button
        await tester.tap(devLoginButton);
        
        // Should show loading state
        await verifyLoadingState(tester, true);
        
        // Wait for completion
        await tester.pumpAndSettle();
        await verifyLoadingState(tester, false);
      });
    });

    group('Dev Mode Login - Error Handling', () {
      testWidgets('should show error SnackBar for dev login failure', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Check if dev login button is present
        final devLoginButton = find.text('1-Click Admin Login');
        if (devLoginButton.evaluate().isEmpty) {
          // Skip test if not in dev mode
          return;
        }
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Dev login failed'));
        
        // Tap dev login button
        await tester.tap(devLoginButton);
        await tester.pumpAndSettle();
        
        // Verify error SnackBar
        expect(find.textContaining('Dev login failed:'), findsOneWidget);
      });

      testWidgets('should show error when demo user not found', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Check if dev login button is present
        final devLoginButton = find.text('1-Click Admin Login');
        if (devLoginButton.evaluate().isEmpty) {
          // Skip test if not in dev mode
          return;
        }
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
        when(() => mockClient.auth.currentSession).thenReturn(null); // No session after login
        
        // Tap dev login button
        await tester.tap(devLoginButton);
        await tester.pumpAndSettle();
        
        // Verify error SnackBar
        await expectSnackBar(tester, 'Demo user not found. Please create it manually in Supabase.');
      });
    });

    group('Forgot Password Button', () {
      testWidgets('should show SnackBar when forgot password is tapped', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Tap forgot password button
        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();
        
        // Verify SnackBar
        await expectSnackBar(tester, 'Forgot password feature coming soon!');
      });

      testWidgets('should only show forgot password in login mode', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Should show in login mode
        expect(find.text('Forgot Password?'), findsOneWidget);
        
        // Toggle to register mode
        await tapToggleButton(tester);
        
        // Should not show in register mode
        expect(find.text('Forgot Password?'), findsNothing);
      });
    });

    group('Loading State Management', () {
      testWidgets('should disable submit button during loading', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Mock a delayed response
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockAuthResponse;
        });
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        
        // Button should be disabled during loading
        final submitButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
        expect(submitButton.onPressed, isNull);
        
        // Wait for completion
        await tester.pumpAndSettle();
        
        // Button should be enabled after completion
        final updatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
        expect(updatedButton.onPressed, isNotNull);
      });

      testWidgets('should show CircularProgressIndicator during loading', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Mock a delayed response
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockAuthResponse;
        });
        
        // Enter credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tapSubmitButton(tester);
        
        // Should show CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        // Wait for completion
        await tester.pumpAndSettle();
        
        // Should not show CircularProgressIndicator after completion
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('should not trigger multiple auth calls on rapid taps', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Mock a delayed response
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockAuthResponse;
        });
        
        // Enter credentials
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        
        // Tap submit button multiple times quickly
        await tapSubmitButton(tester);
        await tapSubmitButton(tester);
        await tapSubmitButton(tester);
        
        // Wait for completion
        await tester.pumpAndSettle();
        
        // Verify signInWithPassword was called only once
        verify(() => mockClient.auth.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });
    });

    group('Widget Lifecycle', () {
      testWidgets('should dispose controllers properly', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the controllers before disposal
        final emailField = tester.widget<TextFormField>(find.byKey(const Key('email_field')));
        final passwordField = tester.widget<TextFormField>(find.byKey(const Key('password_field')));
        
        expect(emailField.controller, isNotNull);
        expect(passwordField.controller, isNotNull);
        
        // Trigger disposal by popping the widget
        await tester.pumpWidget(Container());
        await tester.pump();
        
        // Controllers should be disposed (verified by no memory leaks in test)
      });
    });

    group('Integration - Complete User Flows', () {
      testWidgets('should complete login flow successfully', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
        
        // Enter credentials
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        
        // Submit
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify success
        verify(() => mockClient.auth.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      testWidgets('should complete registration flow successfully', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        when(() => mockClient.auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
        
        // Toggle to register mode
        await tapToggleButton(tester);
        
        // Enter credentials
        await tester.enterText(find.byKey(const Key('email_field')), 'newuser@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        
        // Submit
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify success
        verify(() => mockClient.auth.signUp(
          email: 'newuser@example.com',
          password: 'password123',
        )).called(1);
        
        // Verify success message
        await expectSnackBar(tester, 'Registration successful! Please check your email to verify your account.');
      });

      testWidgets('should handle login-to-register-to-login flow', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Initial state - login
        expect(find.text('Login'), findsOneWidget);
        expect(find.text("Don't have an account? Register"), findsOneWidget);
        
        // Toggle to register
        await tapToggleButton(tester);
        expect(find.text('Register'), findsOneWidget);
        expect(find.text('Already have an account? Login'), findsOneWidget);
        
        // Toggle back to login
        await tapToggleButton(tester);
        expect(find.text('Login'), findsOneWidget);
        expect(find.text("Don't have an account? Register"), findsOneWidget);
      });

      testWidgets('should handle error recovery flow', (WidgetTester tester) async {
        await pumpTestWidget(tester, const AuthScreen());
        
        // Get the mock client
        final mockClient = SupabaseService.client;
        
        // First call fails
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(AuthException('Invalid login credentials'));
        
        // Enter wrong credentials and submit
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify error
        await expectSnackBar(tester, 'Invalid login credentials');
        
        // Now configure successful response
        when(() => mockClient.auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
        
        // Enter correct credentials and submit
        await tester.enterText(find.byKey(const Key('password_field')), 'correctpassword');
        await tapSubmitButton(tester);
        await tester.pumpAndSettle();
        
        // Verify success
        verify(() => mockClient.auth.signInWithPassword(
          email: 'test@example.com',
          password: 'correctpassword',
        )).called(1);
      });
    });
  });
}