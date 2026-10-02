#!/bin/sh

if [ -f .env ] && ! grep -q "^APP_KEY=." .env; then
    php artisan key:generate
fi

php artisan queue:work & php-fpm
