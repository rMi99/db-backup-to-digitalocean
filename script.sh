#!/bin/bash

DB_USER="root"
DB_PASSWORD=""
DB_HOST=""
DB_PORT="3306"
DB_NAME="db_"
BACKUP_DIR="/<>">
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql.gz"

# DigitalOcean Spaces details
SPACE_NAME="backup"
REGION="sgp1"
ENDPOINT="${SPACE_NAME}.${REGION}.digitaloceanspaces.com"
DO_ACCESS_KEY=""
DO_SECRET_KEY=""

# Log file location
LOG_FILE="/<path>/backup_log.log"

# Clean logs older than 7 days
find "$BACKUP_DIR" -type f -name "backup_log.txt" -mtime +7 -exec rm -f {} \;

# Create log entry with timestamp
echo "$(date +"%Y-%m-%d %H:%M:%S") - Starting backup process..." >> "$LOG_FILE"

# Dump the database and compress it
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" \
  --single-transaction --quick --lock-tables=false "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ $? -ne 0 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Database dump failed!" >> "$LOG_FILE"
    exit 1
fi

# Upload to DigitalOcean Spaces
DATE=$(date -R)
RESOURCE="/${SPACE_NAME}/$(basename "$BACKUP_FILE")"
CONTENT_TYPE="application/x-gzip"
STRING_TO_SIGN="PUT\n\n${CONTENT_TYPE}\n${DATE}\n${RESOURCE}"
SIGNATURE=$(echo -en "$STRING_TO_SIGN" | openssl sha1 -hmac "$DO_SECRET_KEY" -binary | base64)

curl -X PUT -T "$BACKUP_FILE" \
  -H "Host: $ENDPOINT" \
  -H "Date: $DATE" \
  -H "Content-Type: $CONTENT_TYPE" \
  -H "Authorization: AWS ${DO_ACCESS_KEY}:${SIGNATURE}" \
  "https://$ENDPOINT/$(basename "$BACKUP_FILE")"

if [ $? -ne 0 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Upload to DigitalOcean Spaces failed!" >> "$LOG_FILE"
    exit 1
fi

echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup and upload to DigitalOcean Spaces completed successfully!" >> "$LOG_FILE"
