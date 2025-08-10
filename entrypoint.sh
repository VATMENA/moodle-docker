#!/bin/bash
set -e

mkdir -p /var/www/moodledata
chown -R www-data:www-data /var/www/html /var/www/moodledata
chmod -R 755 /var/www/html

if [ ! -f /var/www/html/config.php ]; then
  echo "Generating config.php from ENV"

  cat <<EOF > /var/www/html/config.php
<?php
\$CFG = new stdClass();
\$CFG->dbtype    = 'mariadb';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = getenv('DB_HOST');
\$CFG->dbname    = getenv('DB_NAME');
\$CFG->dbuser    = getenv('DB_USER');
\$CFG->dbpass    = getenv('DB_PASS');
\$CFG->prefix    = 'mdl_';
\$CFG->wwwroot   = getenv('WWWROOT');
\$CFG->dataroot  = '/var/www/moodledata';
\$CFG->directorypermissions = 0777;
\$CFG->sslproxy = true;
require_once(__DIR__ . '/lib/setup.php');
EOF

  chown www-data:www-data /var/www/html/config.php
fi

cat /var/www/html/config.php
echo -e "database parameters: ${DB_HOST} ${DB_NAME} ${DB_USER} ${DB_PASS}"
ls /var/www/moodledata


exec apache2-foreground
