#!/usr/bin/perl -w
#Input is today's option data,
#Calculate the underlying shares and total the options traded today for that
#share then output the top twenty.
# In: optcode<tab>date<tab>open<tab>high<tab>low<tab>close<tab>volume<tab>open interest
# Out: top 20 shares by option volume
# Exclude any options which don't have OHLC prices
use strict;

my @a;
my $code;
my %vol;
while(<>) {
	chomp;
	@a = split /\t/;
	$code = substr($a[0],0,3);
	if (defined $a[2] and defined $a[3] and defined $a[4] and defined $a[5]) {
		$vol{$code} += $a[6];
	}
}

my @b =  (sort {$b->[0] <=> $a->[0]} map { [$vol{$_}, $_] } keys %vol);
for my $i (0..23) {
	print "$b[$i]->[1]\t$b[$i]->[0]\n";
}

