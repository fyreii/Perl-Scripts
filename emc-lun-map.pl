#!/usr/bin/perl

#           emc_vio_disk_map.pl
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

use strict;
use warnings;

# To Do List:
#
# 1. Check we're in the right working dir*
# 2. Check we're on a VIO server
# 3. Add date/time stamp to report
# 4. Fix the sorting on the final report
# 5. Add client-based runs to grab data for LUN/PVID
# 6. Mark ASM-owned disks in the final report
# 7. Translate the awk to proper Perl

# Poplulate arrays with stuff
#
my $file;
my $hdisk;
my $label;
my $plun;
my $pvid;
my $pwd = `pwd`;
my $report = "/home/tbean/test-emc-report.csv";
my $vpd;
my $wd = "/home/tbean";

chomp($pwd);
chomp($wd);

print "Our working directory is: $wd\n";
print "Our current directory is: $pwd\n";

print "Filling out arrays...\n";
my @hdisks = `lspv | awk \'{print \$1}\'`;
my @pvids = `lspv | awk \'{print \$2}\'`;

# Open files to mesh together for the initial report
#
print "Opening files for use...\n";
open(ADDRS, '>emcaddrs.txt') || die ("Can't open file for input: $!");
open(DISKS, '>disks.txt') || die ("Can't open file for input: $!");
open(PVIDS, '>pvids.txt') || die ("Can't open file for input: $!");
open(VPDS, '>vpds.txt') || die ("Can't open file for input: $!");
open(PLUNS, '>plun1.txt') || die ("Can't open file for input: $!");

print "Creating Disk, VPD and PVID info files...\n";
foreach $hdisk(@hdisks) {
     print DISKS $hdisk;
    
     # Generate VPD data
     #
     chomp($hdisk);
     my @vpds = `lscfg -vpl $hdisk | grep VPD`;
     foreach $vpd(@vpds) {
       my @fields = split(/\.\.\.\.\.\.\.\.\.\.\.\.\.\.\.\./, $vpd);    
       print VPDS @fields;
     }
    
     # Generate physical LUN data
     #
     chomp($hdisk);    
     my @phys_luns = `lscfg -vpl $hdisk | grep $hdisk`;
     foreach $plun(@phys_luns) {
          print PLUNS $plun;
     } 

}

foreach $pvid(@pvids) {
     print PVIDS $pvid;
}

# Close files after we are done putting stuff into them
#
print "Closing open files...\n";
close(ADDRS);
close(DISKS);
close(PVIDS);
close(VPDS);
close(PLUNS);

# Fixing output from various commands that don't return properly
#
print "Fixing VPD format...\n";
`cat vpds.txt | awk \'{print substr\(\$0,21\)}\' >> vpd_addr.txt`;

print "Fixing Phys LUN format...\n";
`cat plun1.txt | awk -F\- \'{print \$6}' >> plun2.txt`;
`cat plun2.txt | awk \'{print \$1}' >> plun3.txt`;

    
my @searchme = `cat $wd/vpd_addr.txt`;
chomp(@searchme);
my $emc_addr;

open(MATCHED, '>/home/tbean/matched.txt');

print "Running tier matching...\n";
foreach $emc_addr(@searchme) {

# Set the range of addresses to search     - if not in this range
# it's invalid for our infrastructure
#
unless ( hex($emc_addr) >=99 && hex($emc_addr) <= 10301 ) {
     print MATCHED "$emc_addr, not valid\n";
}

# Tier 1 range matches
#
if ( hex($emc_addr) >= 99 && hex($emc_addr) <= 2761 ) {
      print MATCHED "$emc_addr, Tier 1\n";
}

if ( hex($emc_addr) >= 5450 && hex($emc_addr) <= 5455 ) {
     print MATCHED "$emc_addr, Tier 1\n";
}

if ( hex($emc_addr) >= 6040 && hex($emc_addr) <= 6040 ) {
      print MATCHED "$emc_addr, Tier 1\n";
}
    
if ( hex($emc_addr) >= 8923 && hex($emc_addr) <= 10126 ) {
      print MATCHED "$emc_addr, Tier 1\n";
}

# Tier 2 range matches
#
if ( hex($emc_addr) >= 2762 && hex($emc_addr) <= 4457 ) {
      print MATCHED "$emc_addr, Tier 2\n";
}
    
if ( hex($emc_addr) >= 6891 && hex($emc_addr) <= 7050 ) {
      print MATCHED "$emc_addr, Tier 2\n";
}

if ( hex($emc_addr) >= 7651 && hex($emc_addr) <= 8922 ) {
      print MATCHED "$emc_addr, Tier 2\n";
}

if ( hex($emc_addr) >= 10285 && hex($emc_addr) <= 10301 ) {
     print MATCHED "$emc_addr, Tier 2\n";
}

# Tier 3 range matches
#
if ( hex($emc_addr) >= 5456 && hex($emc_addr) <= 6039 ) {
      print MATCHED "$emc_addr, Tier 3\n";
}

# Tier 4 range matches
#
if ( hex($emc_addr) >= 4458 && hex($emc_addr) <= 5449 ) {
      print MATCHED "$emc_addr, Tier 4\n";
}

if ( hex($emc_addr) >= 6041 && hex($emc_addr) <= 6890 ) {
      print MATCHED "$emc_addr, Tier 4\n";
}

if ( hex($emc_addr) >= 7051 && hex($emc_addr) <= 7650 ) {
      print MATCHED "$emc_addr, Tier 4\n";
}
    
} # end of foreach 

close(MATCHED);

# Generate the lsmap data to do the client maps
#
print "Running IOS command: lsmap -all\n";
`/usr/ios/cli/ioscli lsmap -all > vio_lsmap.txt`;

# lsmap -all | grep vhost
# on client - lscfg -l hdisk# -v "V#" in output = client partition id
# Generate client partition list?

print "Generating final report...\n";
open(REPORT, ">$report");
print REPORT "Device, Address, Tier, PVID, EMC LUN\n";
my $gen_file = `paste -d , $wd/disks.txt $wd/matched.txt $wd/pvids.txt $wd/plun3.txt`;
print REPORT $gen_file;
close(REPORT);

# Cleanup data files
#
#print "Cleaning up...\n";

#my @cleanup = qw(emcaddrs.txt disks.txt pvids.txt vpds.txt plun1.txt plun2.txt plun3.txt matched.txt vpd_addr.txt);

#foreach $file(@cleanup) {
#     `rm $file`;
#}
