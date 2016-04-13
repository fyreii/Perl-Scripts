#!/usr/bin/perl
#
#           aix_audit_nightly.pl
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
# Created: 03/10/2009 by thenders x2991
# Last Modified: 11/04/2009 by thenders x2991
#
# Converts audit reports to a readable format and archives them to deathstar.
#
# Fixme Items:
#
#

use strict;
use warnings;

# Set a path to run from...
my $run_path="/usr/local/sc";

# Check if user is root, if not, display a usage statment
#
my $isroot=`whoami`;

if ($isroot=~"root") {
&run_Arg_check
} else {
&show_Usage;
}

sub run_Arg_check {

# Check for arguments passed and OS
#
my $os=`uname`;

if ($os=~"AIX") {
   &run_Audit_archive;
   } else {         
   die "EXITING SCRIPT - Only supported on AIX!\n";
   }
    
} # end of run_Arg_check

# Display a usage message
#
sub show_Usage {

die "USAGE:  sudo $run_path/aix_audit_nightly.pl";

} # end of show_Usage
    
# Move any old archives from trail to a date file, check that auditing is running, grab its process ID
#
sub run_Audit_archive {

# Set variables we need
#
my $wd="/audit";
my $host=`hostname`;
my $auditon=`audit query |grep "auditing on"`;
my $auditpid=`audit query |grep process`;
chomp($host);

# Check that /cabsa audit mount point exists
#
if (! -e "/cabsa/$host/audit") {
     die "Hostname audit directory in /cabsa not found!\n";
}

# Set the date and timestamp mechanism...
#
my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
my $year = 1900 + $yearOffset;
my $mnthoffset = $month + 1;
my $theTime = "$hour:$minute:$second";
my $theDate = "$mnthoffset$dayOfMonth$year";

chomp($theTime);
chomp($theDate);

`cd $wd`; # move to working directory

if ($auditon =~ "auditing on") {
  print "Auditing is currently running - $auditpid\n";
  print "Shutting down auditing for log rotation...\n";
  `audit off`; # turn off auditing so we can move files around
}

if (-e "$wd/trailOneLevelBack") {
  print "Detected archive file exists, generating archive report...\n";
  `auditpr -v < $wd/trailOneLevelBack >> /cabsa/$host/audit/audit-archived-$host-$theDate.txt`; # make the old trail file a readable text file
  `rm $wd/trailOneLevelBack`; # remove the non-parsed trail file
  print "Compressing archived report...\n";
  `gzip /cabsa/$host/audit/audit-archived-$host-$theDate.txt`;
}

# Convert the existing trail data into a readable format, then reset it
#
print "Generating daily audit report for host $host at $theTime...\n";
`auditpr -v < $wd/trail >> /cabsa/$host/audit/audit-daily-$host-$theDate.txt`;
print "Rolling over trail files...\n";
`rm $wd/trail`; # remove the old trail file
`touch $wd/trail`; # touch a new file
`chmod 640 $wd/trail`; # chmod it to match the old file
print "Auditing turned on...\n";
`audit on`; # turn on auditing
print "Compressing daily report...\n";
`gzip /cabsa/$host/audit/audit-daily-$host-$theDate.txt`;
print "Audit daily reporting finished!\n";
    
} # end of run_Audit_archive


