ARG WORDPRESS_TAG
FROM wordpress:${WORDPRESS_TAG}

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git less nano libzip-dev zip; \
    docker-php-ext-install zip; \
    rm -rf /var/lib/apt/lists/*

ARG PUID=1000
ARG PGID=1000
RUN usermod -u ${PUID} www-data && groupmod -g ${PGID} www-data

WORKDIR /var/www/html

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp


