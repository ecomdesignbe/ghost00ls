# Dockerfile DVWA - Compatible ARM64 (Raspberry Pi 5)
FROM php:8.2-apache

ARG TARGETPLATFORM=linux/arm64

RUN apt-get update && apt-get install -y \
    git \
    mariadb-client \
    curl \
    libgd-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli pdo pdo_mysql gd

RUN rm -rf /var/www/html/* \
    && git clone --depth 1 https://github.com/digininja/DVWA.git /var/www/html \
    && cp /var/www/html/config/config.inc.php.dist /var/www/html/config/config.inc.php

RUN a2enmod rewrite

RUN chmod -R 777 /var/www/html/hackable/uploads \
    && chmod -R 777 /var/www/html/config \
    && chown -R www-data:www-data /var/www/html

# Copier php.ini custom
COPY config/custom-php.ini /usr/local/etc/php/conf.d/zz-custom.ini

EXPOSE 80

CMD ["apache2-foreground"]
