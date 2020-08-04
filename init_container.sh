#!/bin/bash

# set -e

echo "Starting SSH ..."
service ssh start

echo "INFO: creating /var/run/php/php-fpm.sock ..."
test -e /var/run/php/php-fpm.sock && rm -f /var/run/php/php-fpm.sock
mkdir -p /var/run/php
touch /var/run/php/php-fpm.sock

chown -R www-data:www-data /var/run/php/php-fpm.sock
chmod 777 /var/run/php/php-fpm.sock

#test -e /var/log/php-fpm/error.log && rm -f  /var/log/php-fpm/error.log
#mkdir -p /var/log/php-fpm
#touch /var/log/php-fpm/error.log

#chown -R www-data:www-data /var/log/php-fpm
#chmod 777 /var/log/php-fpm/error.log

#Checks to copy wp-content to /home/site/wwwroot if this is a newly created wordpress site.

if [[ ! -d /home/site/wwwroot/wp-content && ! -d /home/site/wwwroot/wp-content/plugins && ! -e /home/site/wwwroot/wp-content/index.php && ! -e /home/site/wwwroot/wp-content/plugins/index.php ]]; then
mv -un /var/www/html/wp-content /home/site/wwwroot/
fi

# Check and add a symlink to wp-content for static content in themes directory

if [[ ! -L /var/www/wwwroot/wp-content ]]; then
rm -fr /var/www/html/wp-content
ln -s /home/site/wwwroot/wp-content /var/www/html/wp-content
chown www-data:www-data /var/www/html/wp-content
fi

echo "Starting nginx"
service nginx start

echo "Starting Redis"
service redis-server start

echo "Starting php-fpm"
/usr/local/bin/docker-php-entrypoint php-fpm