#!/usr/bin/perl

#           AIX_User_Audit.pl
#
#       Copyright 2010 Teresa Henderson <tbean@starkiller>
#      
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#      
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#      
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#
#
# VERSION 1.4.1
#
# Produces a report to be imported into Excel with all host users and last login times;
# also produces a text file with the user names on the server that exist that have never
# been used
#
# These reports are meant to be merged (see run-AIX-Audit.sh), hence they contain no
# header information
#
# Created: 06/02/2008 by Teresa Henderson
#
# Changelog:
#
# 07/07/2010
#
# - Added section to USER that adds in the UID, GID, primary and group list
# - Added additional sed magic to remove shells that start with /bin
#
# 09/29/2008
# - Added hostname output to unused account lists
#
# 08/01/2008
# - Added further data massaging via sed and awk to remove
# extraneous information
# - Added $run_path variable so the script can be moved around
# - Fixed the date and time fields to generate in a nicer format
#
# 07/18/2008
# - Added final root check and usage statement
#
# 07/16/2008
# - Added OS version checking for future expansion
#
# To Do:
#
# - Consolidate the cleanup section to something less fugly
# - Add error checking for file creation problems
# - Add error correction for sudo and lack of access problems

use strict;
use warnings;

# Set a path to run from
#
my $run_path="/home/tbean";

# Check if user is root, if not, display a usage statment
#
my $isroot=`whoami`;

if ($isroot=~"root") {
  print "Running AIX_User_Audit.pl version 1.4.1 ...\n";
  &run_OS_check;
} else {
  &show_Usage;
}

sub run_OS_check {

my $os=`uname`;

if ($os=~"AIX") {
&run_Audit_AIX;
   } else {
die "useraudit.pl ERROR - Currently supported on AIX! Halting execution.\n";
   }

} # end of run_OS_check

sub show_Usage {

die "USAGE:  sudo $run_path/AIX_User_Audit.pl or $run_path/AIX_User_Audit.pl as root.\n";

} # end of show_Usage

sub run_Audit_AIX {

# Set some variables for use that are AIX-specific
#
my @passwd_info=`cat /etc/passwd | awk -F\: \'{print \$3,\$5}\'`;
my @user=`cat /etc/passwd | awk -F\: \'{print \$1}\'`;
my $host=`hostname`;
my $date=`date -u +%m%d%Y`;
my $user;
my $last;
my $time;
my $convtime;
my $hour;
my $min;
my $sec;
my $day;
my $month;
my $year;
my $valid;
my $rusr;


  my @matching = grep { /daemon/ || /bin/ || /sys/ || /adm/ || /uucp/ || /guest/ || /nobody/ || /lpd/ || /lp/ || /invscout/ || /snapp/ || /ipsec/ || /nuucp/ || /sshd/ } @user;

  # Remove any matches from user array
  #
  my %remove_sys;
  @remove_sys{@matching} = undef;
  @user = grep {not exists $remove_sys{$_}} @user;

  chomp($date);
  chomp($host);
  my $unused="$host.$date.unused_accounts.txt";

  open(VALID,">valid_accounts.txt");
  open(UNUSED,">$unused");

  foreach $user(@user) {
  our @lastlog=`lsuser -a time_last_login $user`;
   foreach $last(@lastlog) {
     if ($last =~ /\=/) {
       print VALID $last;
     } else {
       print UNUSED $host,",",$last;
     }
   }
  }

  close(VALID);
  close(UNUSED);

  # Convert the timestamps from lsuser to something we can read
  # 
  open(TDATA,">tdata.txt");

  my @unconv=`cat valid_accounts.txt | awk -F\= \'{print \$2}\'`;
  foreach $time(@unconv) {
    my $convtime = my($sec, $min, $hour, $day, $month, $year) = localtime($time);
    printf TDATA ("%02d%s%02d%s%04d%s%02d%02d%s", $month +1, "\/", $day, "\/", $year + 1900, ",", $hour, $min,"\n");
  }

  close(TDATA);

  # Generate the main report
  #
  open(USER,">user.txt");

  chomp($host);
  my @ruser=`cat valid_accounts.txt | awk \'{print \$1}\'`;
  foreach $rusr(@ruser) {
    chomp($rusr);
    my $epass=`cat /etc/passwd | grep $rusr\:`;
    chomp($epass);
    my $groups=`lsuser -a groups $rusr | awk -F\= \'{print \$2}\' | sed \'s\/\,\/ \/g\'`;
    chomp($groups);
    my $pgrp=`lsuser -a pgrp $rusr | awk -F\= \'{print \$2}\'`;
    chomp($pgrp);
    print USER $host, ",",$epass, "," ,$pgrp, "," ,$groups,"\n";
  }

  close(USER);

  chomp($date);
  chomp($host);
  my $report="1stpass.txt";

  open(REPORT,">$report");

  my $gen_file=`paste -d , user.txt tdata.txt`;
  print REPORT $gen_file;
 
  close(REPORT);

# Remove extra fields we don't want from the report
#
`cat 1stpass.txt | awk -F\: \'{print \$1, \$3, \$4, \$5, \$7}\' > 2ndpass.txt`;

# Sed magic to remove the reference to the user's shell
#
`sed 's\/\\/usr\\/bin\\/\[a-z\]\*\/\/g' 2ndpass.txt > 3rdpass.txt`;

# Remove ref to ksh
#
`sed 's\/\\/bin\\/\[a-z\]*\/\/g' 3rdpass.txt > 4thpass.txt`;

# More awk magic to put in extra fields for Excel's happiness
#
`cat 4thpass.txt | awk '\{print \$1, "," \$2, "," \$3, "," \$4, \$5, \$6, \$7, \$8, \$9, \$10}\' > $host.$date.user_audit.csv`;

# Cleanup debugging files - comment these out if you want to see each step
# of generated data along the way
#

  if (-e "valid_accounts.txt") {
  `rm valid_accounts.txt`;
  }

  if (-e "user.txt") {
`rm user.txt`;
  }

  if (-e "tdata.txt") {
  `rm tdata.txt`;
  }

  if (-e "1stpass.txt") {
  `rm 1stpass.txt`;
  }
 
  if (-e "2ndpass.txt") {
  `rm 2ndpass.txt`;
  }
 
  if (-e "3rdpass.txt") {
  `rm 3rdpass.txt`;
  }
 
  if (-e "4thpass.txt") {
  `rm 4thpass.txt`;
  }

} # end of run_Audit_AIX
