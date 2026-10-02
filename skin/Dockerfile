FROM composer:2.2 as vendor

WORKDIR /app

COPY ./blessing-skin-server/ ./

RUN composer install \
    --prefer-dist \
    --no-dev \
    --no-suggest \
    --no-progress \
    --no-autoloader \
    --no-scripts \
    --no-interaction \
    --ignore-platform-reqs

FROM node:22-alpine as frontend

WORKDIR /app

COPY ./blessing-skin-server/ ./
RUN yarn install --frozen-lockfile

RUN yarn build && \
    cp resources/assets/src/images/bg.webp public/app/ && \
    cp resources/assets/src/images/favicon.ico public/app/ && \
    # Strip unused files
    rm -rf *.config.js *.config.ts tsconfig.* \
      package.json yarn.lock node_modules/ \
      resources/assets/ resources/lang resources/misc resources/misc/backgrounds/ \
      tools/

FROM composer:2.2 as builder

WORKDIR /app

COPY ./blessing-skin-server ./

COPY --from=vendor /app ./
COPY --from=frontend /app/public ./public
COPY --from=frontend /app/resources/views/assets ./resources/views/assets

RUN composer dump-autoload -o --no-dev -n && \
    rm -rf *.config.js *.config.ts tsconfig.* \
      package.json yarn.lock node_modules/ \
      resources/assets/ resources/misc resources/misc/backgrounds/ \
      tools/ && \
    mv .env.example .env && \
    php artisan key:generate && \
    mv .env storage/ && \
    ln -s storage/.env .env && \
    touch storage/database.db && \
    mkdir storage/plugins && \
    sed 's/PLUGINS_DIR=null/PLUGINS_DIR=\/var\/www\/html\/storage\/plugins/' -i storage/.env && \
    sed 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/' -i storage/.env && \
    sed 's/DB_DATABASE=blessingskin/DB_DATABASE=\/var\/www\/html\/storage\/database\.db/' -i storage/.env


FROM php:8.2-fpm

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions pdo_mysql pdo_pgsql gd zip redis intl imagick

COPY --from=builder /app /var/www/html
COPY --chmod=0755 entrypoint.sh /usr/local/bin/

RUN chown -R www-data:www-data /var/www/html

VOLUME ["/var/www/html/public","/var/www/html/storage"]
ENTRYPOINT ["entrypoint.sh"]
