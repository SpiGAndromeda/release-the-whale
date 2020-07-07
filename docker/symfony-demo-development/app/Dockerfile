# I will use the NGINX + PHP-FPM configuration for this talk.
# I like the alpine images because they are minimalistic and there are a lot of support tools.
FROM php:7.4-fpm-alpine

# 1. We need some PHP modules!
# The mlocati/docker-php-extension-installer (https://github.com/mlocati/docker-php-extension-installer) package
# is excellent for this job. It installs the required build (these are removed automatically) and runtime dependencies
# and then compiles the modules.

# The COPY command allows to retrieve files from foreign images.
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Unfortunatly, I never found a tool to get a distinct list of PHP modules from composer.lock.
# Required (without suggests): pdo, phar, pdo_sqlite, tokenizer, intl, mbstring, ctype, dom, libxml, zip, xml, iconv, json
# Reduced to not pre-installed (list in the docker-php-extension-installer README): intl, zip + apcu, xdebug
# set -ex is used to force the output of the current command at building time
RUN set -ex; \
    chmod uga+x /usr/local/bin/install-php-extensions && \
    sync && \
    install-php-extensions \
    apcu \
    intl \
    xdebug \
    zip

# 2. Composer, do your magic! (we install it now, the magic comes later)
# The hirak/prestissimo composer package allows parallel downloads of packages which increaes the installation speed.
# Since composer 1.10 a lot of deprecrations are thrown.
COPY --from=composer:1.9 /usr/bin/composer /usr/bin/composer
RUN set -ex; \
    composer global require hirak/prestissimo

# 3. NPM/Yarn will allow us using webpack (or maybe you want to use gulp?).
# You may require a certain Node version!
RUN set -ex; \
    apk add --no-cache --update \
    nodejs \
    nodejs-npm \
    yarn
# If you need gulp:
#RUN set -ex; \
#    npm install -g gulp

# 4. Keep it protected - private repositories
# That type of SSH configuration should be familiar to you.
#RUN set -ex; \
#    apk add --no-cache --update \
#    git \
#    openssh-client
#RUN set -ex; \
#    mkdir -p /root/.ssh && \
#    chmod 700 /root/.ssh

# Decision to made: commit your deployment (read-only) key to the repository or put it into .gitignore.
#COPY ./gitlab/id_rsa /root/.ssh/id_rsa
#COPY ./gitlab/id_rsa.pub /root/.ssh/id_rsa.pub
#COPY ./gitlab/config /root/.ssh/config
#RUN set -ex; \
#    chmod 600 /root/.ssh/config && \
#    chmod 400 /root/.ssh/id_rsa*

WORKDIR /var/www/html