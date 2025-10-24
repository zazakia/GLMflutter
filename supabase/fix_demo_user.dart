import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Script to fix the demo user authentication issue
/// This script will create the demo user and set the password properly
/// using Supabase's admin API
void main() async {
  print('=== Fixing Demo User Authentication ===');
  
  // Read environment variables
  final envFile = File('../.env');
  if (!envFile.existsSync()) {
    print('ERROR: .env file not found!');
    print('Looking for: ${envFile.path}');
    exit(1);
  }
  
  final envContent = await envFile.readAsString();
  final supabaseUrl = _extractEnvVar(envContent, 'SUPABASE_URL');
  final serviceRoleKey = _extractEnvVar(envContent, 'SUPABASE_SERVICE_ROLE_KEY');
  
  if (supabaseUrl.isEmpty || serviceRoleKey.isEmpty) {
    print('ERROR: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not found in .env');
    exit(1);
  }
  
  print('Supabase URL: $supabaseUrl');
  print('Service Role Key: ${serviceRoleKey.substring(0, 20)}...');
  
  try {
    // Step 1: Create the user using admin API
    await _createDemoUser(supabaseUrl, serviceRoleKey);
    
    // Step 2: Execute the SQL script to create user profile
    await _executeUserCreationSQL(supabaseUrl, serviceRoleKey);
    
    print('\n=== SUCCESS: Demo user created successfully! ===');
    print('Email: admin@demo-company.com');
    print('Password: demo123456');
    print('You can now use the 1-Click Admin Login button.');
    
  } catch (e) {
    print('\n=== ERROR: Failed to create demo user ===');
    print('Error: $e');
    exit(1);
  }
}

String _extractEnvVar(String content, String key) {
  final regex = RegExp(r'^' + key + r'\s*=\s*(.+)$', multiLine: true);
  final match = regex.firstMatch(content);
  return match?.group(1)?.trim() ?? '';
}

Future<void> _createDemoUser(String supabaseUrl, String serviceRoleKey) async {
  print('\n--- Step 1: Creating demo user in auth.users ---');
  
  final url = Uri.parse('$supabaseUrl/auth/v1/admin/users');
  final headers = {
    'Authorization': 'Bearer $serviceRoleKey',
    'Content-Type': 'application/json',
    'apikey': serviceRoleKey,
  };
  
  final userData = {
    'email': 'admin@demo-company.com',
    'password': 'demo123456',
    'email_confirm': true,
    'user_metadata': {'name': 'Demo Admin'},
    'app_metadata': {'provider': 'email', 'providers': ['email']},
    'data': {'display_name': 'Demo Admin'}
  };
  
  print('Creating user: admin@demo-company.com');
  
  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(userData),
  );
  
  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    print('✓ User created successfully');
    print('  User ID: ${responseData['id']}');
  } else if (response.statusCode == 422) {
    print('✓ User already exists, updating password...');
    
    // User exists, update password
    final updateUrl = Uri.parse('$supabaseUrl/auth/v1/admin/users/admin@demo-company.com');
    final updateData = {
      'password': 'demo123456',
      'email_confirm': true,
    };
    
    final updateResponse = await http.put(
      updateUrl,
      headers: headers,
      body: jsonEncode(updateData),
    );
    
    if (updateResponse.statusCode == 200) {
      print('✓ Password updated successfully');
    } else {
      throw Exception('Failed to update password: ${updateResponse.body}');
    }
  } else {
    throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
  }
}

Future<void> _executeUserCreationSQL(String supabaseUrl, String serviceRoleKey) async {
  print('\n--- Step 2: Creating user profile and organization records ---');
  
  final url = Uri.parse('$supabaseUrl/rest/v1/rpc/execute_sql');
  final headers = {
    'Authorization': 'Bearer $serviceRoleKey',
    'Content-Type': 'application/json',
    'apikey': serviceRoleKey,
    'Prefer': 'return=minimal',
  };
  
  // SQL to create user profile and organization associations
  final sql = '''
    -- Create user profile
    INSERT INTO user_profiles (
        id,
        org_id,
        branch_id,
        role,
        display_name,
        phone,
        created_at,
        updated_at
    ) VALUES (
        (SELECT id FROM auth.users WHERE email = 'admin@demo-company.com'),
        '00000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'owner',
        'Demo Admin',
        '+639123456789',
        NOW(),
        NOW()
    ) ON CONFLICT (id) DO NOTHING;

    -- Add to organization_users
    INSERT INTO organization_users (
        id,
        org_id,
        user_id,
        role,
        status,
        invited_by,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        '00000000-0000-0000-0000-000000000001',
        (SELECT id FROM auth.users WHERE email = 'admin@demo-company.com'),
        'owner',
        'active',
        (SELECT id FROM auth.users WHERE email = 'admin@demo-company.com'),
        NOW(),
        NOW()
    ) ON CONFLICT (org_id, user_id) DO NOTHING;
  ''';
  
  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode({'sql_query': sql}),
  );
  
  if (response.statusCode == 200) {
    print('✓ User profile and organization records created successfully');
  } else {
    print('⚠ Could not execute SQL via RPC. This is normal if execute_sql function doesn\'t exist.');
    print('  You may need to run the create_demo_user.sql script manually in Supabase SQL Editor.');
  }
}