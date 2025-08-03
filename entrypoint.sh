#!/bin/bash
set -e

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
require_once(__DIR__ . '/lib/setup.php');
EOF

  chown www-data:www-data /var/www/html/config.php
fi

exec apache2-foreground

