# MySQL Backup to DigitalOcean Spaces

This script automates MySQL database backups and uploads them to DigitalOcean Spaces.

## Features
- Dumps a MySQL database and compresses it.
- Cleans old logs older than 7 days.
- Uploads the backup to DigitalOcean Spaces securely.
- Logs the backup process.

## Prerequisites
- MySQL installed and accessible.
- `mysqldump` command available.
- DigitalOcean Spaces credentials.
- `curl` and `openssl` installed.

## Usage
1. Configure the script by setting:
   - `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, `DB_NAME`
   - `SPACE_NAME`, `REGION`, `DO_ACCESS_KEY`, `DO_SECRET_KEY`
   - `BACKUP_DIR` and `LOG_FILE`
2. Run the script:
   ```bash
   ./backup.sh
   ```
3. Check the log file for backup status.

## Automating Backups with Cron
To schedule automatic backups using cron, follow these steps:

1. Open the crontab editor:
   ```bash
   crontab -e
   ```
2. Add a new cron job to run the script daily at midnight:
   ```bash
   0 0 * * * /path/to/backup.sh >> /path/to/backup_log.log 2>&1
   ```
   Replace `/path/to/backup.sh` with the actual path of your script.

3. Save and exit the crontab editor.

To verify if the cron job is set up correctly, list the scheduled cron jobs:
   ```bash
   crontab -l
   ```

## License
MIT License

