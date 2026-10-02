FROM php:8.1-fpm
RUN apt-get update; apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev; \
        rm -rf /var/lib/apt/lists/*; \
        docker-php-ext-configure gd --with-freetype --with-jpeg; \
        docker-php-ext-install -j$(nproc) gd zip;

COPY --from=blessing-skin-server:builder /app /var/www/html
COPY --chmod=0755 entrypoint.skin.sh /usr/local/bin/

RUN chown -R www-data:www-data /var/www/html

VOLUME ["/var/www/html/public","/var/www/html/storage", "/var/www/html/plugins"]
ENTRYPOINT ["entrypoint.sh"]
