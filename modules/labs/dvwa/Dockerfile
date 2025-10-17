FROM php:8.2-apache

# Installer extensions nécessaires
RUN apt-get update && apt-get install -y \
    git mariadb-client curl libgd-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql gd \
    && rm -rf /var/lib/apt/lists/*


# Cloner DVWA directement dans /var/www/html
RUN rm -rf /var/www/html/* \
    && git clone https://github.com/digininja/DVWA.git /var/www/html \
    && cp /var/www/html/config/config.inc.php.dist /var/www/html/config/config.inc.php

# Activer mod_rewrite
RUN a2enmod rewrite

RUN chmod -R 777 /var/www/html/hackable/uploads /var/www/html/config

