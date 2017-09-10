#!/usr/bin/perl

# File name: exam.pl
# Purpose: Final Part II
# Author: Teresa Henderson
# Course: IFT 383 Online
# Term: Summer 2017
# Date: 8/9/2017

use strict;
use warnings;
use constant;

# CONSTANTS
my $MAX_QUIZ = 10;
my $MAX_CLASS_ACTS = 135;
my $MAX_HOMEWORK = 150;
my $MAX_LABS = 155;
my $MAX_DISCUSSION = 105;
my $MAX_EXAMS = 180;
my $SUM_OF_TOTAL_MAX = 735;

# Declarations
my @sums;
my %scores;
my $finalScore;
my $finalGrade;
my $cum;

# take input from user do some basic sanity checking
# if invalid values are entered, prompt until a
# correct one is entered, etc
#
# If I were more inclined, this sanity check should be it's
# own function.
print "Enter the Quiz score: ";
my $qscore = <>;
while ($qscore > $MAX_QUIZ) {
 print "Invalid entry, max quiz is $MAX_QUIZ. \n";
 print "Please enter a valid value: ";
 $qscore = <>;
}
chomp $qscore;

print "Enter the Activities score: ";
my $ascore = <>;
while ($ascore > $MAX_CLASS_ACTS) {
 print "Invalid entry, max activities is $MAX_CLASS_ACTS. \n";
 print "Please enter a valid value: ";
 $ascore = <>;
}
chomp $ascore;

print "Enter the Homework score: ";
my $hscore = <>;
while ($hscore > $MAX_HOMEWORK) {
 print "Invalid entry, max homework is $MAX_HOMEWORK. \n";
 print "Please enter a valid value: ";
 $hscore = <>;
}
chomp $hscore;

print "Enter the Labs score: ";
my $lscore = <>;
while ($lscore > $MAX_LABS) {
 print "Invalid entry, max  labs is $MAX_LABS. \n";
 print "Please enter a valid value: ";
 $lscore = <>;
}
chomp $lscore;

print "Enter the Discussion score: ";
my $dscore = <>;
while ($dscore > $MAX_DISCUSSION) {
 print "Invalid entry, max discussion is $MAX_DISCUSSION. \n";
 print "Please enter a valid value: ";
 $dscore = <>;
}
chomp $dscore;

print "Enter the Exams score: ";
my $escore = <>;
while ($escore > $MAX_EXAMS) {
 print "Invalid entry, max exam is $MAX_EXAMS. \n";
 print "Please enter a valid value: ";
 $escore = <>;
}
chomp $escore;


# I enumerated this hash, because otherwise the count was wrong
# not sure why, but it works with arbitrary keys, so w/e
%scores = (
1 => $qscore,
2 => $ascore,
3 => $hscore,
4 => $lscore,
5 => $dscore,
6 => $escore
);

# the bit that does the stuff
&sum(values %scores);
$finalScore = &percent($cum,$SUM_OF_TOTAL_MAX);
print "Final Score is:  $finalScore\n";
$finalGrade = &grade($finalScore);
print "Final Grade is: $finalGrade\n";

# input from %scores hash
sub sum {
 my @sums = @_;
 for my $s (@sums) {
  $cum += $s;
 }
 return $cum;
}

# input $cum and sum of total max
sub percent {
  my ($val1, $val2) = @_;
  my $percent = $val1 * 100/$val2;
  $finalScore = sprintf("%.01f", $percent);
 return $finalScore;
}

# calculates letter grade based on final percentage
sub grade {
 $finalScore = $_[0];

 return $finalGrade = "Invalid" if ($finalScore > 100.0);
 return $finalGrade = "A+" if($finalScore >= 95.0 && $finalScore <= 100.0);
 return $finalGrade = "A" if($finalScore >= 90.0 && $finalScore <= 95.0);
 return $finalGrade = "A-" if($finalScore >= 87.5 && $finalScore <= 90.0);
 return $finalGrade = "B+" if($finalScore >= 85.0 && $finalScore <= 87.5);
 return $finalGrade = "B" if($finalScore >= 82.5 && $finalScore <= 85.0);
 return $finalGrade = "B-" if($finalScore >= 80.0 && $finalScore <= 82.5);
 return $finalGrade = "C+" if($finalScore >= 77.5 && $finalScore <= 80.0);
 return $finalGrade = "C" if($finalScore >= 70.0 && $finalScore <= 77.5);
 return $finalGrade = "D" if($finalScore >= 60.0 && $finalScore <= 70.0);
 return $finalGrade = "F" if($finalScore <= 60.0);
}
