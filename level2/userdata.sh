#!/bin/bash
dnf update -y
dnf install -y httpd php php-mysqlnd wget unzip

systemctl enable --now httpd

cd /var/www/html
wget https://wordpress.org/latest.zip
unzip latest.zip
cp -r wordpress/* .
rm -rf wordpress latest.zip

chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/${db_user}/" wp-config.php
sed -i "s/password_here/${db_pass}/" wp-config.php
sed -i "s/localhost/${db_host}/" wp-config.php

systemctl restart httpd

