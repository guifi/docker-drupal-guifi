#!/usr/bin/perl
# This script configures Drupal 6 for first time
#
use warnings;
use strict;

my $DRUPAL_DIR = "/usr/share/drupal/";
my $GUIFI_WEB_DIR = $DRUPAL_DIR."guifi-web/";
my $GUIFI_DEV_DIR = $DRUPAL_DIR."guifi-dev/";
my $GUIFI_MODULES_DIR = $GUIFI_WEB_DIR."sites/all/modules/";
my $GUIFI_THEMES_DIR = $GUIFI_WEB_DIR."sites/all/themes/";
my $GUIFI_DEV_DB = "guifi66_devel.sql";
my $GUIFI_DEV_DB_GZ = "$GUIFI_DEV_DB.gz";
my $GUIFI_DOMAIN = "http://www.guifi.net/";

sub xdebug_php {
  print "Modify xdebug.ini file...\n";
  my $file = "/etc/php5/apache2/conf.d/20-xdebug.ini";
  open(FILE, "<".$file) || die "File not found";
  my @lines = <FILE>;


  # Add php5-xdebug support
  my $xdebug = "xdebug.remote_enable=1
  xdebug.remote_handler=dbgp
  xdebug.remote_mode=req
  xdebug.remote_connect_back=1
  xdebug.remote_port=$ENV{XDEBUG_PORT}
  xdebug.remote_autostart=1\n";
  push(@lines, $xdebug);

  open(FILE, ">".$file) || die "File not found";
  print FILE @lines;
  close(FILE);
}

sub google_api_replace {
  print "Modifying google API files...\n";

  my $file ="$GUIFI_MODULES_DIR/guifi/guifi_includes.inc.php";

  my $spattern = "libraries=places";
  my $rpattern = $spattern."&3.22&key=AIzaSyD2HdZ9zq_cEyFdTFsZ_aNWI6QkxK4wwYs";

  print "Opening file: $file\n";
  open(FILE, "<".$file) || die "File not found";
  my @lines = <FILE>;
  close(FILE);
  my @newlines;
  foreach(@lines) {
      $_ =~ s/${spattern}/${rpattern}/g;
      push(@newlines,$_);
  }
  

  open(FILE, ">".$file) || die "File not found";
  print FILE @newlines;
  close(FILE);
}

sleep 15; # We should wait for mariadb container being ready

print "Checking configurations...\n";

if (! -e $GUIFI_WEB_DIR."INSTALLED") {
  my $output = `rm -rf ${GUIFI_WEB_DIR}*`;
  if ($? != 0) {
    # Error
    die "Error purging Drupal dir.\n";
  }

  &xdebug_php;
  if ($? != 0) {
    # Error
    die "Error setting xdebug configurations.\n";
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

  $output = `drush en -y captcha views \\
            event fckeditor image`;

  if ($? != 0) {
    # Error
    die "Error installing guifi-drupal dependencies (1).\n";
  }

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

  # We clone actual drupal-guifi git repository
  $output = `git clone https://github.com/guifi/drupal-guifi.git ${GUIFI_MODULES_DIR}guifi`;

  if ($? != 0) {
    # Error
    die "Error in drupal-guifi git clone.\n";
  }

  # Setting Google API Key
  &google_api_replace;


  $output = `cd $GUIFI_WEB_DIR && drush en -y guifi`;

  if ($? != 0) {
     # Error
     die "Error in guifi module installation.\n";
  }

  # We clone actual drupal-budgets git repository
  $output = `git clone https://github.com/guifi/drupal-budgets.git ${GUIFI_MODULES_DIR}budgets`;

  if ($? != 0) {
    # Error
    die "Error in budgets git clone.\n";
  }

    $output = `cd $GUIFI_WEB_DIR && drush en -y budgets`;

  if ($? != 0) {
     # Error
     die "Error in budgets module installation.\n";
  }

  # Import sql guifi dev
  $output = `mysql -u $ENV{GUIFI_USER_DB} -p$ENV{GUIFI_USER_DB_PWD} -h database $ENV{GUIFI_DB}  < /tmp/$GUIFI_DEV_DB;`;
  if ($? != 0) {
     # Error
     die "Error in guifi dev db installation.\n";
  }

  # set files directory
  $output = `cd $GUIFI_WEB_DIR && mkdir -p files tmp && chown -R www-data:www-data ./tmp ./files`;
  if ($? != 0) {
     # Error
     die "Error setting files dir and tmp dirs.\n";
  }

  $output = `mkdir -p $GUIFI_THEMES_DIR`;
  if ($? != 0) {
     # Error
     die "Error in themes dir creation.\n";
  }

  $output = `git clone https://github.com/guifi/drupal-theme_guifinet2011.git ${GUIFI_THEMES_DIR}guifi2011`;
  if ($? != 0) {
     # Error
     die "Error in git cloning theme.\n";
  }

  $output = `cd $GUIFI_WEB_DIR && cp ./sites/all/themes/guifi2011/images/guifi.net_logo.gif ./files/`;
  if ($? != 0) {
     # Error
     die "Error in guifi image copy.\n";
  }

  $output = `cd $GUIFI_WEB_DIR && drush en -y guifi.net2011 && drush vset theme_default guifi.net2011`;
  if ($? != 0) {
     # Error
     die "Error activating theme.\n";
  }

  $output = `cd $GUIFI_WEB_DIR && drush updb -y`;
  if ($? != 0) {
     # Error
     die "Error updating database.\n";
  }

  $output = `cd /tmp && wget https://guifi.net/files/color/guifi.net2011-673770f4.tgz`;
  if ($? != 0) {
     # Error
     die "Error downloading theme cache.\n";
  }

  $output = `cd $GUIFI_WEB_DIR && mkdir -p ./files/color && tar zxf /tmp/guifi.net2011-673770f4.tgz -C ${GUIFI_WEB_DIR}files/color`;
  if ($? != 0) {
     # Error
     die "Error installing theme cache.\n";
  }

  # We change permissions in guifi module
  $output = `chmod -R o+rw ${GUIFI_MODULES_DIR}guifi`;

  if ($? != 0) {
    # Error
    die "Error changing permissions guifi module.\n";
  }

  # We change permissions in budgets module
  $output = `chmod -R o+rw ${GUIFI_MODULES_DIR}budgets`;

  if ($? != 0) {
    # Error
    die "Error changing permissions budgets module.\n";
  }

  # Deleting all /tmp files
  $output = `rm -rf /tmp/*`;
  if ($? != 0) {
     # Error
     die "Error removing all temp files.\n";
  }

  # make INSTALLED file
  $output = `touch ${GUIFI_WEB_DIR}INSTALLED`;
  if ($? != 0) {
     # Error
     die "Error creating INSTALLED file.\n";
  }

  print "Guifi.net dev page successfully installed in Docker image!\n";
}
else {
  print "Already installed.\n";
}
