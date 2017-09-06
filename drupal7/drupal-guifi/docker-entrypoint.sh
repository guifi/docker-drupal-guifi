#!/usr/bin/env bash
#cd /usr/share/drupal/guifi-web
#drush si -y --site-name=guifi.net --db-url=mysqli://guifi:guifi@database/guifidev --account-name=admin --account-pass=drupal
# Configuration script in Perl
perl /drupal-entry.pl
/usr/sbin/apache2ctl -D FOREGROUND
