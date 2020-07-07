# The CLI image is sufficient for testing puroposes
FROM php:7.4-cli-alpine

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN set -ex; \
    chmod uga+x /usr/local/bin/install-php-extensions && \
    sync && \
    install-php-extensions \
    intl \
    xdebug \
    zip

COPY --from=composer:1.9 /usr/bin/composer /usr/bin/composer
RUN set -ex; \
    composer global require hirak/prestissimo

RUN set -ex; \
    apk add --no-cache --update \
    nodejs \
    yarn

WORKDIR /var/www/html