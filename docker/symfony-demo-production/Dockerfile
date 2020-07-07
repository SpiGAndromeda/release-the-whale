#
# STAGE 1: composer
#
FROM composer:1.9 AS composer
WORKDIR /app

# install the prestissimo composer plugin to parallelise the downloads
RUN set -ex; \
    composer global require hirak/prestissimo --no-plugins --no-scripts

# copy composer.json and .lock for download and autoloader only
COPY composer.* /app/

# download composer packages and do anything non source-code related
RUN set -ex; \
    composer clear-cache && \
    COMPOSER_MEMORY_LIMIT=-1 composer install \
    --ignore-platform-reqs \
    --no-dev \
    --no-scripts \
    --no-suggest \
    --no-interaction \
    --prefer-dist \
    --no-autoloader

# copy the necessary files for the autoloader creation
COPY src /app/src

# create autoloader
RUN set -ex; \
    composer dump-autoload \
    --no-dev \
    --optimize \
    --classmap-authoritative \
    --apcu

#
# STAGE 2: yarn/npm
#
FROM node:12 AS webpack
WORKDIR /app

# copy package.json and yarn.lock for download only
COPY package.json \
    yarn.lock \
    /app/

# download npm packages based on the lockfile
RUN set -ex; \
    yarn install --frozen-lockfile

# copy the necessary files for webpack compilation
RUN set -ex; \
    mkdir -p public/build
COPY assets /app/assets
COPY config /app/config
COPY webpack.config.js /app/

# wepack production compilation
RUN set -ex; \
    yarn run encore production

#
# STAGE 3: build
#
FROM php:7.4-fpm-alpine AS build
WORKDIR /app

# install grep for symfony console
RUN set -ex; \
    apk add --no-cache --upgrade \
    grep

# symfony-demo file copy
RUN set -ex; \
    mkdir app assets bin src web

COPY composer.json composer.lock package.json yarn.lock ./
COPY assets /app/assets
COPY bin /app/bin
COPY config /app/config
COPY public /app/public
COPY src /app/src
COPY templates /app/templates
COPY translations /app/translations

COPY --from=composer /app/vendor /app/vendor
COPY --from=webpack /app/public/build /app/public/build

# set file permissions
RUN set -ex; \
    chown -R www-data:www-data /app && \
    find /app -type d -print0 | xargs -0 chmod 0775 && \
    find /app -type f -print0 | xargs -0 chmod 0664 && \
    find /app -type d -print0 | xargs -0 chmod g+s && \
    chmod -R +x /app

#
# STAGE 4: production
#
FROM php:7.4-fpm-alpine AS app
WORKDIR /var/www/html

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN set -ex; \
    chmod uga+x /usr/local/bin/install-php-extensions && \
    sync && \
    install-php-extensions \
    apcu \
    intl \
    opcache \
    zip

# apply php configuration files
COPY docker/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# copy the production ready code (with permissions) from the build stage
COPY --from=build /app /var/www/html/

# check the php and extension requirements (ignored in the first stage)
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN set -ex; \
    chmod +x /usr/bin/composer && \
    composer check-platform-reqs

# ---------- end of the app image ----------
# ---------- begin of the web image ----------

FROM nginx:alpine AS web

COPY --from=build /app /var/www/html/
RUN set -ex; \
    rm -Rf docker

COPY docker/nginx.conf /etc/nginx/nginx.conf

COPY --from=build /app /var/www/html