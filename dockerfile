FROM php:7.4.28-apache

# Settings Options
ARG SITE_TITLE='Our Calendar'
ARG AGENDAV_DB_NAME='agendav'
ARG AGENDAV_DB_USER='agendavuser'
ARG AGENDAV_DB_PASS='agendav'
ARG AGENDAV_DB_HOST='localhost'
ARG CSRF_SECRET='lkjihgfedcba'
ARG CALDAV_BASE_URL='http://localhost/dav.php'
ARG CALDAV_AUTH_METHOD='digest'
ARG CALDAV_BASE_URL_PUBLIC='http://localhost'
ARG DEFAULT_TIMEZONE='UTC'
ARG DEFAULT_LANGUAGE='en'
ARG DEFAULT_TIME_FORMAT='24'
ARG DEFAULT_DATE_FORMAT='ymd'
ARG DEFAULT_WEEK_START='0'
ARG DEFAULT_SHOW_WEEK_NB='false'
ARG DEFAULT_SHOW_NOW_INDICATOR='true'
ARG DEFAULT_LIST_DAYS='7'
ARG DEFAULT_VIEW='month'


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
RUN echo "date.timezone=$DEFAULT_TIMEZONE" >> $PHP_INI_DIR/conf.d/php-agendav.ini

RUN docker-php-ext-install pdo pdo_mysql
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN a2enmod rewrite

# Copy in starting site definition and enable the site
COPY ./calendar.conf /etc/apache2/sites-available/000-default.conf
#WORKDIR /etc/apache2/sites-available
#RUN a2ensite calendar.conf

# Update settings.php with ARG values
WORKDIR /var/www/agendav/web/config
RUN cp default.settings.php settings.php
RUN sed -ri "s|(^.*'site.title'.*=).*$|\1 '$SITE_TITLE';|" settings.php
RUN sed -ri "s|(^.*'dbname'.*=>).*$|\1 '$AGENDAV_DB_NAME',|" settings.php
RUN sed -ri "s|(^.*'user'.*=>).*$|\1 '$AGENDAV_DB_USER',|" settings.php
RUN sed -ri "s|(^.*'password'.*=>).*$|\1 '$AGENDAV_DB_PASS',|" settings.php
RUN sed -ri "s|(^.*'host'.*=>).*$|\1 '$AGENDAV_DB_HOST',|" settings.php
RUN sed -ri "s|(^.*'csrf.secret'.*=).*$|\1 '$CSRF_SECRET';|" settings.php
RUN sed -ri "s|(^.*'caldav.baseurl'.*=).*$|\1 '$CALDAV_BASE_URL';|" settings.php
RUN sed -ri "s|(^.*'caldav.authmethod'.*=).*$|\1 '$CALDAV_AUTH_METHOD';|" settings.php
RUN sed -ri "s|(^.*'caldav.baseurl.public'.*=).*$|\1 '$CALDAV_BASE_URL_PUBLIC';|" settings.php
RUN sed -ri "s|(^.*'defaults.timezone'.*=).*$|\1 '$DEFAULT_TIMEZONE';|" settings.php
RUN sed -ri "s|(^.*'defaults.language'.*=).*$|\1 '$DEFAULT_LANGUAGE';|" settings.php
RUN sed -ri "s|(^.*'defaults.time_format'.*=).*$|\1 '$DEFAULT_TIME_FORMAT';|" settings.php
RUN sed -ri "s|(^.*'defaults.date_format'.*=).*$|\1 '$DEFAULT_DATE_FORMAT';|" settings.php
RUN sed -ri "s|(^.*'defaults.weekstart'.*=).*$|\1 $DEFAULT_WEEK_START;|" settings.php
RUN sed -ri "s|(^.*'defaults.show_week_nb'.*=).*$|\1 $DEFAULT_SHOW_WEEK_NB;|" settings.php
RUN sed -ri "s|(^.*'defaults.show_now_indicator'.*=).*$|\1 $DEFAULT_SHOW_NOW_INDICATOR;|" settings.php
RUN sed -ri "s|(^.*'defaults.list_days'.*=).*$|\1 $DEFAULT_LIST_DAYS;|" settings.php
RUN sed -ri "s|(^.*'defaults.default_view'.*=).*$|\1 '$DEFAULT_VIEW';|" settings.php

# Setup Agendav
WORKDIR /var/www/agendav/web
RUN composer install

WORKDIR /var/www/agendav
RUN php agendavcli migrations:migrate

# Modify Client.php file to fix 500 error when using Baikal with digest
RUN sed -i "s/CURLAUTH_DIGEST/CURLAUTH_ANY/" /var/www/agendav/web/vendor/guzzlehttp/guzzle/src/Client.php
