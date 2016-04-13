#!/usr/bin/perl -w

# mkuser.pl
#
# Created: 11/16/2007 by tbean x2991
# Last Modified: 10/09/2009 by tbean x2991
#
# This script prompts for information to create
# a new user according to the Enterprise UNIX
# standards
#

use strict;

# Check to make sure the running user is root

my $isroot = `whoami`;

if ($isroot =~ "root") {
  &createUser;
} else {
  die "mkuser.pl: ERROR - Insufficient privileges, you must be root!\n";
}

# This subroutine is the "main" portion of the
# program.

sub createUser {

# Ask user to enter user related information

my $user = &promptUser("Enter the new username");
my $uid = &promptUser("Enter the user's UID");
my $homedir = &promptUser("Enter the desired home directory", "/home/$user");
my $group = &promptUser("Enter the user's group");
my $gecos = &promptUser("Enter a description of the user");

print "You entered: $user, $homedir, $group, $gecos\n";

# Give the option to backout of the script if
# the user typoed a value, since the prompts
# aren't very forgiving

my $check_val = &promptUser("Are these values correct? ", "yes");

  if ($check_val =~ "no") {
  print "mkuser.pl: EXIT - Please re-run the script!\n";
  return 1;
  }

# Determine OS type so we run the right command

my $ostype = `uname`;
chomp($ostype);
my $usrcmd;

  if ($ostype =~ "AIX") {
  $usrcmd = "mkuser id=$uid groups=$group home=$homedir gecos=$gecos $user";
  system "$usrcmd";
  }

  if ($ostype =~ "Linux") {
  $usrcmd = "useradd -u $uid -g $group -m -c '$gecos' $user";
  system "$usrcmd";
  }

  if ($ostype =~ "HPUX") {
  $usrcmd = "useradd -u $uid -g $group -m -c '$gecos' $user";
  system "$usrcmd";
  }

# Set the new user's password

system "passwd $user";
 
}

# The promptUser subroutine creates the prompts
# used in the menus throughout the script

sub promptUser {

  my($promptString,$defaultValue) = @_;

  if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after print
   $_ = <STDIN>;         # get the input from STDIN

   chomp;

if ($defaultValue) {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}
