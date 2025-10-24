import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock class for SupabaseClient
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock class for GoTrueClient (authentication)
class MockGoTrueClient extends Mock implements GoTrueClient {}

/// Mock class for AuthResponse
class MockAuthResponse extends Mock implements AuthResponse {}

/// Mock class for Session
class MockSession extends Mock implements Session {}

/// Mock class for User
class MockUser extends Mock implements User {}