#!/bin/sh

chown -R www-data:www-data /var/www/html

if [ -f .env ] && ! grep -q "^APP_KEY=." .env; then
    php artisan key:generate
fi

php artisan queue:work & php-fpm
