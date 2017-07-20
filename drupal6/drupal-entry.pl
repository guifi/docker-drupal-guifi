#!/usr/bin/perl
# This script configures Drupal 6 for first time
#
use warnings;
use strict;

use constant GUIFI_WEB_DIR => "/usr/share/drupal/guifi-web/";

print "Checking configurations...\n";

if !(-e $GUIFI_WEB_DIR."INSTALLED") {
  chdir($GUIFI_WEB_DIR);
  my $output = `drush si --site-name=guifi.net --account-name=$ENV{DRUPAL_ADMIN} \\
   --account-pass=$ENV{DRUPAL_ADMIN_PWD} --db-url=mysqli://$ENV{GUIFI_USER_DB}:$ENV{GUIFI_USER_DB_PWD}\@database/$ENV{GUIFI_DB}`;
  if ($? != 0) {
    # Error
    die "Error in drush si command.\n";
  }

  # We should reduce privileges to avoid possible vulnerabilities
  $output = `chmod o-w /usr/share/drupal/guifi-web/sites/default/settings.php`

  if ($? != 0) {
    # Error
    die "Error in chmod command.\n";
  }


}
