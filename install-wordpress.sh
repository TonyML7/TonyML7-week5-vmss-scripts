#!/bin/bash
set -e

MYSQL_USER="week5"
MYSQL_PASS="Wachtwoord123!"
MYSQL_HOST="mysql-week5-569382.mysql.database.azure.com"
DB_NAME="wordpressdb"

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y nginx php-fpm php-mysql php-gd php-curl php-xml php-mbstring unzip curl

rm -rf /var/www/html/*
curl -L https://wordpress.org/latest.zip -o /tmp/wp.zip
unzip -q /tmp/wp.zip -d /tmp
cp -r /tmp/wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html

cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" /var/www/html/wp-config.php
sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
sed -i "s/password_here/${MYSQL_PASS}/" /var/www/html/wp-config.php
sed -i "s/localhost/${MYSQL_HOST}/" /var/www/html/wp-config.php

# Nginx PHP configuratie
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }
}
EOF

systemctl enable nginx
systemctl restart nginx
