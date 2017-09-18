#!/usr/bin/perl

# Date: 09/14/2017
# Author:  Teresa Henderson
# E-mail: thenderson@webmd.net
#
# Purpose:  Creates new files with new extensions from one subdir to another
#

use strict;
use warnings;
use File::Basename;

my $DD="./stylus/_modules";
my $SD="./scss/_modules";
my $SF="./scss/_modules/_forms";

my @filename=(`find $DD -name "*.styl"`);
my $suffix="sccs";
my $path;

foreach my $f (@filename) { 

my $dir= dirname($f);

if (( $dir =~ /modules$/ )) {
$path = $SD;
} else {
$path = $SF;
}

my $name= basename("$f", ".styl");
chomp $name;
my $newfile = join '.', $name, $suffix;
system("touch $path/$newfile");
}
