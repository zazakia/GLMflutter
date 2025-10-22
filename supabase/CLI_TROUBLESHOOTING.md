# Supabase CLI Troubleshooting Guide

## Issues We Encountered

1. **Config.toml parsing errors**
2. **Connection timeouts to the remote database**
3. **Authentication/permission issues**

## Solutions to Make the CLI Work

### 1. Fix the Config.toml File

The current config.toml has issues with the format. Here's a corrected version:

```toml
# Supabase Configuration
[project]
ref = "tzmpwqiaqalrdwdslmkx"

[api]
port = 54321
schemas = ["public", "graphql_public"]
extra_search_path = ["public", "extensions"]
max_rows = 1000

[db]
port = 54322
shadow_port = 54320
major_version = 15

[studio]
port = 54323

[storage]
file_size_limit = "50MiB"

[auth]
site_url = "http://localhost:3000"
additional_redirect_urls = ["https://localhost:3000"]
jwt_expiry = 3600

[analytics]
enabled = false

[edge_functions]
```

### 2. Fix Connection Issues

The connection errors are likely due to:

1. **Network connectivity issues**: The CLI is trying to connect to a region that might not be accessible from your location
2. **Firewall/proxy issues**: Your network might be blocking the connection
3. **Incorrect project reference**: The project reference might be incorrect

### 3. Steps to Make CLI Migration Work

#### Step 1: Update the Supabase CLI
```bash
supabase update
```

#### Step 2: Login to Supabase
```bash
supabase login
```

#### Step 3: Link to Your Project
```bash
supabase link --project-ref tzmpwqiaqalrdwdslmkx
```

#### Step 4: Check Status
```bash
supabase status
```

#### Step 5: Push Migrations
```bash
supabase db push
```

### 4. Alternative: Use a Different Region

If connection issues persist, the project might be in a region that's not accessible from your location. Consider:

1. Creating a new project in a different region (closer to your location)
2. Using a VPN to connect to a different region

### 5. Check Project Permissions

Ensure your account has the necessary permissions to access the project:

1. Go to the Supabase Dashboard
2. Check your account settings
3. Verify you have the right permissions for the project

### 6. Use Local Development

If remote connection continues to fail, you can:

1. Start a local Supabase instance:
   ```bash
   supabase start
   ```
2. Apply migrations locally:
   ```bash
   supabase db reset
   ```
3. Export the schema and import it manually to the remote project

### 7. Direct Database Connection

As a last resort, you can connect directly to the database:

1. Get the connection string from the Supabase Dashboard
2. Use a PostgreSQL client (like pgAdmin or DBeaver) to connect
3. Run the migration scripts manually

## Recommended Approach

Given the connection issues we encountered, I recommend:

1. **Use the manual migration approach** with the combined_migration.sql file
2. **Or try creating a new Supabase project** in a different region
3. **Or use a VPN** to connect to a different region if the issue is network-related

## If You Still Want to Use the CLI

If you prefer to use the CLI despite the issues, try these steps:

1. Update your config.toml with the corrected version above
2. Update the Supabase CLI to the latest version
3. Try linking to the project again
4. If connection issues persist, consider creating a new project in a different region