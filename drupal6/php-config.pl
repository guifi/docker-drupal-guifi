#!/usr/bin/perl
# This scripts configures php.ini to for working with Drupal 6
#
use warnings;
use strict;

my @PHP_INI_FILES = ('/etc/php5/apache2/php.ini','/etc/php5/cli/php.ini');

print "Modifying php.ini files...\n";

my $file;
foreach $file (@PHP_INI_FILES) {
  print "Opening file: $file\n";
  open(FILE, "<".$file) || die "File not found";
  my @lines = <FILE>;
  close(FILE);
  my @newlines;
  foreach(@lines) {
     $_ =~ s/;mbstring.http_output\s=\s/mbstring.http_output = pass\n/g;
     $_ =~ s/;mbstring.http_input\s=\s/mbstring.http_input = pass\n/g;
     push(@newlines,$_);
  }

  open(FILE, ">".$file) || die "File not found";
  print FILE @newlines;
  close(FILE);
}
