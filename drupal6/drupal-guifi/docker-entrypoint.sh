#!/usr/bin/env bash

# Configuration script in Perl
perl /drupal-entry.pl

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

# Running apache daemon
/usr/sbin/apache2ctl -D FOREGROUND
