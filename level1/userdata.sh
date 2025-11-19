#!/bin/bash
set -e

dnf update -y

dnf install -y httpd
systemctl enable httpd
systemctl start httpd

dnf install -y php php-mysqlnd php-fpm php-json php-curl php-gd php-xml php-mbstring php-intl php-opcache
systemctl restart httpd

dnf install -y mariadb105-server
systemctl enable mariadb
systemctl start mariadb

mysql -e "CREATE DATABASE wordpress;"
mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'StrongPassword123!';"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

cd /var/www/html

rm -rf *

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz

cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/wpuser/" wp-config.php
sed -i "s/password_here/StrongPassword123!/" wp-config.php

chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

systemctl restart httpd