# agendav
Container with Agendav

This is for creating a docker container with Apache2, PHP7.4.28, and AgenDAV.
It is specifically set up for using MySQL as the database backend.

Uses the following build args
SITE_TITLE
- Title shown on login and calendar pages

AGENDAV_DB_NAME
- Name of MySQL Database

AGENDAV_DB_USER
- Name of MySQL Database User

AGENDAV_DB_PASS
- Password for MySQL Database User

AGENDAV_DB_HOST
- Host of MySQL

CSRF_SECRET
- generate a random value for this

CALDAV_BASE_URL
- Path to dav.php on dav server

CALDAV_AUTH_METHOD
- Authentication method required by CalDAV server (basic or digest)

CALDAV_BASE_URL_PUBLIC
- Whether to show public CalDAV urls

DEFAULT_TIMEZONE
- Default timezone

DEFAULT_LANGUAGE
- Default language

DEFAULT_TIME_FORMAT
- Default time format. Options: '12' / '24'

DEFAULT_DATE_FORMAT
- Default date format. Options:
 - ymd: YYYY-mm-dd
 - dmy: dd-mm-YYYY
 - mdy: mm-dd-YYYY

DEFAULT_WEEK_START
- Default first day of week. Options: 0 (Sunday), 1 (Monday)
 
DEFAULT_SHOW_WEEK_NB
- Default for showing the week numbers. Options: true/false
 
DEFAULT_SHOW_NOW_INDICATOR
- Default for showing the "now" indicator, a line on current time. Options: true/false

DEFAULT_LIST_DAYS
- Default number of days covered by the "list" (agenda) view. Allowed values: 7, 14 or 31

DEFAULT_VIEW

DEFAULT_DEFAULT_VIEW
- Default view (month, week, day or list)
