#!/usr/bin/perl
# This script configures Drupal 6 for first time
#
use warnings;
use strict;

my $DRUPAL_DIR = "/usr/share/drupal/";
my $GUIFI_WEB_DIR = $DRUPAL_DIR."guifi-web/";
my $GUIFI_DEV_DIR = $DRUPAL_DIR."guifi-dev/";
my $GUIFI_MODULES_DIR = $GUIFI_WEB_DIR."sites/all/modules/";
my $GUIFI_DEV_DB = "guifi66_devel.sql";
my $GUIFI_DEV_DB_GZ = "$GUIFI_DEV_DB.gz";
my $GUIFI_DOMAIN = "http://www.guifi.net/";



sleep 15; # We should wait for mariadb container being ready

print "Checking configurations...\n";

if (! -e $GUIFI_WEB_DIR."INSTALLED") {
  my $output = `rm -rf ${GUIFI_WEB_DIR}*`;
  if ($? != 0) {
    # Error
    die "Error purging Drupal dir.\n";
  }

  $output = `drush dl -y drupal-6 --destination=$DRUPAL_DIR --drupal-project-rename=guifi-web`;
  print $output;
  if ($? != 0) {
    # Error
    die "Error downloading Drupal dir.\n";
  }

  chdir($GUIFI_WEB_DIR);
  $output = `drush si -y --site-name=guifi.net --account-name=$ENV{DRUPAL_ADMIN} \\
   --account-pass=$ENV{DRUPAL_ADMIN_PWD} --db-url=mysqli://$ENV{GUIFI_USER_DB}:$ENV{GUIFI_USER_DB_PWD}\@database/$ENV{GUIFI_DB}`;
  if ($? != 0) {
    # Error
    die "Error in drush si command.\n";
  }

  # We should reduce privileges to avoid possible vulnerabilities
  $output = `chmod o-w /usr/share/drupal/guifi-web/sites/default/settings.php`;

  if ($? != 0) {
    # Error
    die "Error in chmod command.\n";
  }

  # TODO install all necessary modules to make guifi module working

  $output = `drush dl -y --dev potx webform views \\
            views_slideshow i18n ctools schema \\
            potx l10n_client libraries \\
            languageicons language_sections \\
            diff captcha captcha_pack \\
            event cck fckeditor image votingapi \\
            image_filter fivestar devel `;

  print $output."\n";

  if ($? != 0) {
    # Error
    die "Error downloading guifi-drupal dependencies.\n";
  }
  print "trace1\n";

  $output = `drush en -y captcha views \\
            event fckeditor image`;

  if ($? != 0) {
    # Error
    die "Error installing guifi-drupal dependencies (1).\n";
  }
  print "trace2\n";

  $output = `drush en -y potx webform views \\
            views_slideshow i18n \\
            potx l10n_client \\
            languageicons language_sections \\
            diff schema \\
            event fckeditor image \\
            image_filter fivestar devel votingapi `;

  if ($? != 0) {
    # Error
    die "Error installing guifi-drupal dependencies (2).\n";
  }

  print "trace3\n";

  # We install guifi66 devel mariadb database
  chdir('/tmp');
  $output = `wget $GUIFI_DOMAIN$GUIFI_DEV_DB_GZ`;

  if ($? != 0) {
    # Error
    die "Error in download database dev guifi.\n";
  }

  # gunzip db
  $output = `gunzip $GUIFI_DEV_DB_GZ`;

  if ($? != 0) {
    # Error
    die "Error in gunzip database dev guifi.\n";
  }

  # We clone actual guifi-drupal git repository
  $output = `git clone https://github.com/guifi/drupal-guifi.git ${GUIFI_MODULES_DIR}guifi`;

  if ($? != 0) {
    # Error
    die "Error in git clone.\n";
  }

  $output = `cd $GUIFI_WEB_DIR && drush en -y guifi`;

  if ($? != 0) {
     # Error
     die "Error in guifi module installation.\n";
  }

  # Import sql guifi dev
  $output = `mysql -u $ENV{GUIFI_USER_DB} -p$ENV{GUIFI_USER_DB_PWD} -h database $ENV{GUIFI_DB}  < /tmp/$GUIFI_DEV_DB;`;
  print $output;
  if ($? != 0) {
     # Error
     die "Error in guifi dev db installation.\n";
  }

  # TODO add guifi.net theme

  # make INSTALLED file
  $output = `touch ${GUIFI_WEB_DIR}INSTALLED`;
  print $output;
  if ($? != 0) {
     # Error
     die "Error creating INSTALLED file.\n";
  }

  print "Guifi.net dev page successfully installed in Docker image!\n";
}
else {
  print "Already installed.\n";
}
