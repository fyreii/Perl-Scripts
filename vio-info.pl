l#!/usr/bin/perl

# Created: 11-10-2010
# Author:  Teresa Henderson
# Company:  ADT
# Filename: vio_info.pl
# Description:  Gathers virtual adapter data from each HMC /
# and calculates address ranges for the server adapter ID's

use warnings;
use strict;

my @hmcs = qw(hmc list goes here); 
my $date = `date -u +%m%d%Y`;
chomp($date);

open(SCSI,">vscsi.txt");
open(ETH, ">eth.txt");

foreach my $hmc(@hmcs) {
  chomp($hmc);
  my @managed_systems = `ssh -l hscroot $hmc lssyscfg -r sys -F name`;
  foreach my $frame(@managed_systems) {
    chomp($frame);
    my @scsi = `ssh -l hscroot $hmc lshwres -r virtualio --rsubtype scsi -m $frame --level lpar`;
      foreach my $vscsi(@scsi) {
        print SCSI $frame,",",$vscsi;
      }
    my @eth = `ssh -l hscroot $hmc lshwres -r virtualio --rsubtype eth -m $frame --level lpar`;
      foreach my $veth(@eth) {
        print ETH $frame,",",$veth;
      }
  } # end of managed_systems

} # end of hmcs

close(SCSI);
close(ETH);

open(SCSI_RPT,">ADT_vscsi_report_$date.csv");
open(VETH_RPT,">ADT_sea_report_$date.csv");

my @vadapters = `cat vscsi.txt | awk -F, \'{print \$1","\$2","\$7","\$8","\$9","\$10}\'` || die "Cannot open file vscsi.txt: $!\n";
my @seas = `cat eth.txt | awk -F, \'{print \$1","\$2","\$4","\$7","\$8","\$9}\'` || die "Cannot open file eth.txt: $!\n";

#my @matching = grep { /ieee_virtual_eth=0/ } @seas;
#my %remove_sys;
#@remove_sys{@matching} = undef;
#@seas = grep {not exists $remove_sys{$_}} @seas;

print SCSI_RPT "Frame,LPAR,Adapter Type,Client LPAR ID,Client,Client Adapter\n";
print SCSI_RPT @vadapters;
print VETH_RPT "Frame,LPAR,Adapter ID,Trunk,Priority,VLAN\n";
print VETH_RPT @seas;

close(SCSI_RPT);
close(VETH_RPT);

my @cleanup = qw(vscsi.txt eth.txt);
foreach my $file(@cleanup) {
  `rm $file`
} # end of cleanup
