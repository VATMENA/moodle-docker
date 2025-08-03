#!/bin/bash

# Wait until config.php exists
echo "[CRON] Waiting for config.php to be created by moodle container..."

while [ ! -f /var/www/html/config.php ]; do
  echo "[CRON] config.php not found – waiting..."
  sleep 5
done

echo "[CRON] config.php found. Starting Moodle cron loop..."

# Run cron.php in a loop every 60 seconds
while true; do
    echo "[CRON] Running Moodle cron.php at $(date)"
    su -s /bin/bash www-data -c "php /var/www/html/admin/cli/cron.php"
    sleep 60
done

