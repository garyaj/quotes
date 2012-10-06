#!/usr/bin/perl -w
#convert a list of ASX stock codes into records suitable for loading into ProTA
use strict;

my @b;
while(<>) {
	chomp;
	($b[2],$b[0]) = split /,/;
	$b[2] =~ s/"//g;
	$b[1] = 'S';
	$b[3] = 'OHLCV';
	print join "\t", @b;
	print "\n";
}
