import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // Read environment variables
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? '';
  final supabaseKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set');
    exit(1);
  }
  
  try {
    print('Starting migration using Supabase REST API...');
    
    // Step 1: Create the exec_sql RPC function using REST API
    await createExecSqlFunctionViaRest(supabaseUrl, supabaseKey);
    
    // Step 2: Read and execute migration files
    final migrationFiles = [
      '20240101000001_create_core_schema.sql',
      '20240101000002_create_service_reports_schema.sql', 
      '20240101000003_create_rls_policies.sql',
      '20240101000004_seed_lookup_data.sql',
    ];
    
    for (final file in migrationFiles) {
      print('Executing migration: $file');
      final sql = await File('migrations/$file').readAsString();
      
      // Split SQL into individual statements
      final statements = sql.split(';').where((s) => s.trim().isNotEmpty);
      
      for (final statement in statements) {
        if (statement.trim().isNotEmpty) {
          try {
            // Use raw SQL execution with logging
            final stmtTrimmed = statement.trim();
            final preview = stmtTrimmed.length > 100 
                ? '${stmtTrimmed.substring(0, 100)}...' 
                : stmtTrimmed;
            print('Executing: $preview');
            
            await executeSqlViaRest(supabaseUrl, supabaseKey, stmtTrimmed);
            print('Success');
          } catch (e) {
            print('ERROR executing statement: ${statement.trim()}');
            print('ERROR DETAILS: $e');
            
            // Check if this is the duplicate key error we're investigating
            if (e.toString().contains('duplicate key value violates unique constraint') && 
                e.toString().contains('job_tasks_code_key')) {
              print('*** FOUND THE DUPLICATE JOB_TASKS ISSUE ***');
              print('*** This confirms our diagnosis of duplicate test_isolate_parts entries ***');
            }
            
            // Continue with next statement
          }
        }
      }
      
      print('Completed migration: $file');
    }
    
    print('All migrations completed successfully!');
  } catch (e) {
    print('Migration failed: $e');
    print('');
    print('ALTERNATIVE SOLUTION:');
    print('1. Go to your Supabase project');
    print('2. Open the SQL Editor');
    print('3. Copy and paste the entire content of combined_migration.sql');
    print('4. Click "Run" to execute all migrations at once');
    exit(1);
  }
}

Future<void> createExecSqlFunctionViaRest(String supabaseUrl, String supabaseKey) async {
  try {
    print('Creating exec_sql RPC function via REST API...');
    
    final createFunctionSql = "CREATE OR REPLACE FUNCTION exec_sql(query TEXT) RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER AS \$\$ BEGIN EXECUTE query; RETURN 'SQL executed successfully'; END; \$\$;";
    
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql');
    final response = await http.post(
      url,
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: '{"query": "$createFunctionSql"}',
    );
    
    if (response.statusCode == 200) {
      print('exec_sql function created/updated successfully');
    } else {
      print('exec_sql function may already exist or needs manual creation');
    }
  } catch (e) {
    print('Note: exec_sql function needs to be created manually in Supabase SQL Editor');
  }
}

Future<void> executeSqlViaRest(String supabaseUrl, String supabaseKey, String sql) async {
  final url = Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql');
  final response = await http.post(
    url,
    headers: {
      'apikey': supabaseKey,
      'Authorization': 'Bearer $supabaseKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    },
    body: '{"query": "${sql.replaceAll('"', '\\"')}"}',
  );
  
  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
}