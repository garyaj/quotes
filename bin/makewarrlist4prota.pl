#!/usr/bin/perl -w
#convert warrlist.lst into records suitable for loading into ProTA
use Class::Date qw(date -DateParse);
use strict;

my @a;
my @b;
my $d;
while(<>) {
	chomp;
	@a = split;
	$b[0] = $a[0];
	$b[1] = 'O';
	$d = date $a[3];
	$b[2] = $d->strftime("%b%y");
	$b[2] =~ s/^./\U$&/;
	$b[2] .= ' '.$a[4].' '.$a[2].'W';
	$b[3] = 'OHLCVI';
	print join ",", @b;
	print "\n";
}
