# agendav
Container with AgenDAV

This is for creating a docker container with Apache2, PHP7.4.28, and AgenDAV.
It is specifically set up for using MySQL as the database backend.

Requires /config mapped to a host path.

Initial run will create example.settings.php and example.timezone.ini that will need 
to be renamed to remove the "example." and modified to match desired setup.
