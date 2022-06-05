#!/bin/bash

# If the settings file already exists
if [ -f "/config/settings.php" ];
then

    #init/migrate check DB
    cd /var/www/agendav
    php agendavcli migrations:migrate

    cd /

    if [ -f "/config/timezone.ini" ];
    then

        apache2-foreground
    else
        echo "date.timezone='UTC'" > /config/example.timezone.ini
        echo "Please create /config/timezone.ini"
    fi
# if settings file does NOT exist
else
    # If example file doesnt exist, create it and fix log path
    if ! [ -f "/config/example.settings.php" ];
    then
        cp /var/www/agendav/web/config/default.settings.php /config/example.settings.php
        sed -ri "s|'/../var/log/'|'/var/www/agendav/web/var/log/'|" /config/example.settings.php
    fi

    # prompt in log to create settings
    echo "Please create /config/settings.php"

    # if timezone.ini doesnt exist create example and prompt in log
    if [ -f "/config/timezone.ini" ];
    then
        echo "date.timezone='UTC'" > /config/example.timezone.ini
        echo "Please create /config/timezone.ini"
    fi
fi
