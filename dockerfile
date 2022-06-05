FROM php:7.4.28-apache

EXPOSE 80

ENV DEFAULT_TIMEZONE="UTC"

# Pull down agendav 2.4 release, uncompress, move to final location
RUN mkdir /tempish
ADD https://github.com/agendav/agendav/releases/download/2.4.0/agendav-2.4.0.tar.gz /tempish/agendav-2.4.0.tar.gz
WORKDIR /tempish
RUN tar -xvf agendav-2.4.0.tar.gz
RUN mv agendav-2.4.0 /var/www/agendav
RUN chown -R www-data:www-data /var/www/agendav
# Cleanup files
WORKDIR /
RUN rm /tempish/agendav-2.4.0.tar.gz
RUN rmdir tempish

# Install additionally needed mods
RUN apt update
RUN apt -y install libmcrypt-dev zip
RUN pecl install mcrypt

# Add php ini file that enables mcrypt, and sets default timezone
RUN echo "extension=mcrypt.so" >> $PHP_INI_DIR/conf.d/php-agendav.ini

RUN docker-php-ext-install pdo pdo_mysql
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN a2enmod rewrite

# Copy in starting site definition and enable the site
COPY ./calendar.conf /etc/apache2/sites-available/000-default.conf

# Setup Agendav
WORKDIR /var/www/agendav/web
RUN composer install

# Modify Client.php file to fix 500 error when using Baikal with digest
RUN sed -i "s/CURLAUTH_DIGEST/CURLAUTH_ANY/" /var/www/agendav/web/vendor/guzzlehttp/guzzle/src/Client.php

RUN mkdir /config
RUN ln -s /config/settings.php /var/www/agendav/web/config/settings.php
RUN ln -s /config/timezone.ini $PHP_INI_DIR/conf.d/timezone.ini

VOLUME /config

# Copy in startupScript to do the initial install work that sets
# the settings file values to the env vars, and fixes one of the
# installed support files.
COPY ./startupScript.sh /startupScript.sh
RUN chmod 500 /startupScript.sh
ENTRYPOINT /startupScript.sh
