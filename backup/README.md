# PostgreSQL Backup and Restore with Ansible

Simple PostgreSQL backup and restore automation using Ansible roles, based on [this blog post](https://stribny.name/posts/ansible-postgresql-backups/).

## Setup

1. Edit `inventory` and add your PostgreSQL servers:

   ```ini
   [postgresql]
   db1.example.com
   db2.example.com
   ```

2. Create `host_vars/db1.example.com.yml` for each host:

   ```yaml
   # Required variables
   user_app: app1user
   app_name: app1
   db_name: app1

   # Optional (defaults in roles/*/defaults/main.yml)
   # backup_base_dir: /var/lib
   ```

## Usage

### Backup Database

```bash
ansible-playbook playbook.yml --tags backup
```

This will:
- Verify required variables are defined
- Create a timestamped backup directory on the server
- Create a compressed SQL dump using `postgresql_db` module
- Verify the backup file was created successfully
- Store backup on the server only

### Restore Database

**Restore from specific backup (by timestamp):**

```bash
ansible-playbook playbook.yml --tags restore --extra-vars "backup_file=2024-11-28-16:30:45"
```

**Restore from latest backup:**

```bash
ansible-playbook playbook.yml --tags restore
```

This will:
- Verify required variables are defined
- Find the latest backup (if not specified)
- Verify the backup file exists
- Restore the database directly from backups stored on the server

## Error Handling

The playbook includes error handling for:
- Missing required variables (user_app, app_name, db_name)
- Failed directory creation
- Failed backup operations
- Missing or empty backup files
- No backups found when restoring
- Failed restore operations

## Configuration Variables

All variables can be overridden in `host_vars/` or via `--extra-vars`:

### Backup Role Variables (in `roles/postgresql_backup/defaults/main.yml`):
- `user_app`: System user that owns backup directory (default: `postgres`)
- `app_name`: Application name for backup path (default: `myapp`)
- `db_name`: Database name to backup (default: `mydb`)
- `backup_base_dir`: Base directory for backups (default: `/var/lib`)

### Restore Role Variables (in `roles/postgresql_restore/defaults/main.yml`):
- `user_app`: System user (default: `postgres`)
- `app_name`: Application name (default: `myapp`)
- `db_name`: Database name to restore (default: `mydb`)
- `backup_base_dir`: Base directory (default: `/var/lib`)
- `backup_file`: Specific backup timestamp to restore (optional, uses latest if not set)

## Backups Location

- **Server**: `{{ backup_base_dir }}/{{ app_name }}/backups/{{ timestamp }}/{{ db_name }}.dump.gz`
- **Default**: `/var/lib/{{ app_name }}/backups/{{ timestamp }}/{{ db_name }}.dump.gz`

## Cron

For automated daily backups:

```bash
0 2 * * * cd /path/to/ansible-backup && ansible-playbook playbook.yml --tags backup
```
