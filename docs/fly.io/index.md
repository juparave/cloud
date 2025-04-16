# Fly.io Notes

[Fly.io](https://fly.io/) is a platform for deploying full-stack applications and databases close to users. It runs apps in Firecracker micro-VMs across various global regions.

This document covers common commands and configurations for managing applications and services on Fly.io.

## Managing Postgres Databases

Fly.io offers managed Postgres clusters.

### Create a Postgres Cluster

Use the `fly postgres create` command:

```bash
fly postgres create --name your-db-name --organization <your-org-slug>
```

*   Replace `<your-org-slug>` with your actual organization slug (find it via `fly orgs list`).
*   You will be prompted to choose an app name (defaults to the cluster name), region, configuration (size/resources), and whether to enable auto-stop.

**Example Output & Explanation:**

```text
? Choose an app name (leave blank to generate one): pgserver
automatically selected personal organization: My organization
# ... (Region and Configuration prompts) ...
? Scale single node pg to zero after one hour? No
Creating postgres cluster in organization personal
# ... (Provisioning details) ...
Postgres cluster pgserver created
  Username:    postgres
  Password:    some-secure-password # <-- IMPORTANT: Save this securely!
  Hostname:    pgserver.internal    # <-- Internal DNS name for app connections
  Flycast:     fdaa:9:9495:0:1::2   # <-- Anycast IPv6 for external connections (if enabled)
  Proxy port:  5432                 # <-- Port for connections via Fly Proxy (standard)
  Postgres port:  5433              # <-- Direct port to the Postgres instance (less common)
  Connection string: postgres://postgres:some-secure-password@pgserver.flycast:5432

Save your credentials in a secure place -- you won't be able to see them again!
```

*   **Security:** Store the generated password securely. It won't be shown again.
*   **Connection:** Use the `.internal` hostname for connections *from other Fly apps* in the same organization. Use the connection string provided (usually via the Flycast address and proxy port) for external tools or apps needing public access (requires configuration).

### List Your Fly Apps (Including Databases)

Databases run as Fly apps. List all apps:

```bash
fly apps list
```

### Connect via CLI

Connect directly to your database using `psql` via the Fly proxy:

```bash
fly pg connect -a your-db-app-name
```
(Replace `your-db-app-name` with the app name chosen during creation, e.g., `pgserver`).

### Connecting from an Application

Applications deployed on Fly.io within the same organization can typically connect using the internal hostname and port 5432. The connection string usually looks like:
`postgres://<user>:<password>@<db-app-name>.internal:5432/<database_name>`

Set this connection string as a secret in your application. See [Managing Secrets](#managing-secrets).

See official docs for more connection examples: [Fly.io Postgres Connections](https://fly.io/docs/postgres/connecting/app-connection-examples/)

## Launching an Application

The `fly launch` command initializes a new application on Fly.io. Run it from your project's root directory.

```bash
fly launch
```

This command typically:
1.  Scans your project to detect the framework/language.
2.  Asks for an app name and organization.
3.  Prompts for region selection.
4.  Asks if you want to set up a Postgres database or Redis instance.
5.  Generates a `fly.toml` configuration file.
6.  Builds your application (often using Docker or buildpacks).
7.  Deploys the application to Fly.io.
8.  Assigns a temporary `.fly.dev` domain.

Reference: [Create a Fly App](https://fly.io/docs/launch/create/)

### Customize Before First Deploy

To configure settings in `fly.toml` *before* the initial deployment, use the `--no-deploy` flag:

```bash
fly launch --no-deploy
```

Then, edit the generated `fly.toml` file.

### Example `fly.toml`

This file defines your application's configuration on Fly.io.

```toml
# fly.toml file generated for sveltewebstore on 2024-01-01T00:00:00-00:00

app = 'sveltewebstore'       # Unique name of the app on Fly.io
primary_region = 'qro'       # Default region for deployment

[build]
  # Optional: Specify build strategy (e.g., builder = "paketobuildpacks/builder-jammy-base")
  # Optional: Specify build arguments

[http_service]
  internal_port = 3000       # The port your application listens on *inside* the VM
  force_https = true         # Redirect HTTP requests to HTTPS
  auto_stop_machines = 'stop' # Stop machines when idle ('stop' or 'off')
  auto_start_machines = true # Start machines automatically on request
  min_machines_running = 0   # Minimum number of machines to keep running (0 allows scale-to-zero)
  processes = ['app']        # Maps to the [processes] section in Dockerfile or Procfile

[[vm]]                         # Defines the VM resources
  memory = '256mb'             # Amount of RAM
  cpu_kind = 'shared'          # CPU type ('shared' or 'performance')
  cpus = 1                     # Number of CPUs
```

### Platform VM Sizes

List available VM sizes and their specifications:

```bash
fly platform vm-sizes
```

## Deploying Updates

After the initial launch, or if you used `fly launch --no-deploy`, deploy your application (or any subsequent code changes) using:

```bash
fly deploy
```

This command reads your `fly.toml`, builds the application based on your project and build configuration, and deploys the new version to Fly.io.

## Common Tasks

### Checking Logs

View real-time logs from your application instances:

```bash
fly logs -a your-app-name
```

### Managing Secrets

Secrets are environment variables injected securely into your application instances.

**Set a secret:**

```bash
fly secrets set MY_SECRET_KEY="its value" -a your-app-name
```
*Note: Setting secrets usually triggers a new deployment.*

**List secrets (keys only):**

```bash
fly secrets list -a your-app-name
```

### Scaling

**Scale VM count (manual):**

```bash
fly scale count 3 -a your-app-name # Scale to 3 instances
fly scale count 1 -a your-app-name # Scale back to 1 instance
```

**Scale VM resources (memory/CPU):**

```bash
fly scale vm shared-cpu-1x --memory 512 -a your-app-name # Scale to 512MB RAM
```
(Use `fly platform vm-sizes` to see available sizes). Scaling VM resources requires a restart of the instances.
