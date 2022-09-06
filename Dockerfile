FROM php:7.4-fpm
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            zip \
            unzip \
            git \
            curl \
            libmemcached-dev \
            libz-dev \
            libpq-dev \
            libwebp-dev \
            libjpeg-dev \
            libpng-dev \
            libfreetype6-dev \
            libssl-dev \
            libmcrypt-dev \
            libonig-dev; \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install bcmath;

RUN set -eux; \
    # Install the PHP pdo_mysql extention  https://github.com/docker-library/php/issues/926
    docker-php-ext-install pdo_mysql; \
    # Install the PHP pdo_pgsql extention
    docker-php-ext-install pdo_pgsql; \
    # Install the PHP gd library
    docker-php-ext-configure gd \
            --prefix=/usr \
            --with-webp \
            --with-jpeg \
            --with-freetype; \
    docker-php-ext-install gd; \
    php -r 'var_dump(gd_info());'

WORKDIR /var/www

RUN rm -rf /var/www/html
RUN ln -s public html

RUN curl -sS https://getcomposer.org/installer | \
php -- --install-dir=/usr/bin/ --filename=composer

COPY . /var/www

RUN chmod -R 777 /var/www/storage

EXPOSE 9000
EXPOSE 6001/tcp

ENTRYPOINT [ "php-fpm" ]
