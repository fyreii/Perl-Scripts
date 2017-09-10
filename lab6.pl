
#!/usr/bin/perl
# File name: lab6.pl
# Purpose: formats results from measurements
# Author: Teresa Henderson
# Course: IFT 383 Online
# Term: Summer 2017
# Date: 8/3/2017
#

use strict;
use warnings;
use constant;

# declare a bunch of variables
# now I remember why I stopped using perl, ha
my $match;
my $row;
my @calc = ();
my @rows = {};
my $row_count = 0;
my $sum = 0;
my $avg = 0;
my $rounded;

# hash for the catergory matching we want in report
# kills two birds with one stone, unlike shell
my %labels= (
 B => "Tamb (C)",
 P => "Tref (C)",
 Q => "Tm (C)",
 R => "Irraidiance (W/m%2)",
 H => "Isc (A)",
 O => "Voc (V)",
 C => "Imp (A)",
 K => "Vmp (V)",
 W => "Pm (W)",
 L => "FF (%)",
);

# static stuff
print "Performance Data: \n";
print "Date: 12-30-2006 \n";

# open file handler
my $filename = 'data.iva';
open(my $fh, $filename);

# read rows from file, remove newline with chomp
while (my $row =<$fh>) {
 chomp $row;
   # look for matching keys in the labels hash
   for $match (keys %labels) {
    # if a match is found remove the first letter
    if ($row =~ $match) {
      $row  =~ s/^[A-Z]//g;
      # split the rest of the numbers on the line into an array
      @calc = split ' ', $row;
      # for each number in each row of calc, sum numbers
      foreach my $c (@calc) {
        $sum += $c;
      }
      # calculate average with 3, the lazy way (sorry, it's been a long week)
      $avg = $sum/3;
      # round the measurements off to 2 decimal places
      $rounded = sprintf("%.02f", $avg);
      $sum = 0;
    } else {
     # in the event a match isn't found, move to the next line
     next;
    }
  }
}

# call the output subroutine
&output;

sub output()
# does what it says on the tin
{
  foreach my $v (values %labels)
  {
    # matches labels to the rounded values
    print "$v $rounded\n";
  }
}
