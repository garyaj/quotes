#!/usr/bin/perl -w
# GAJ:20021102: Yahoo has become very unstable so
# this script combines the snapshot of stocks taken
# 90 minutes apart each evening.
# The simple method is to take the greater of every
# price and/or volume for the same stock. Yahoo
# has been setting more and more of its prices to zero
# for short intervals (lock problems?).

use Class::Date qw(date);
use strict;

my $later = '2';

my $dt = date(time);
my $today = $dt->strftime("%Y%m%d");

$|++;
my $dayfile1 = "$ENV{HOME}/allstks_day_$today.txt";
my $dayfile2 = "$ENV{HOME}/allstks_day2_$today.txt";
my $dayfile3 = "$ENV{HOME}/allstks_day3_$today.txt";

open(IN1, $dayfile1) or die "Can't open $dayfile1";
open(IN2, $dayfile2) or die "Can't open $dayfile2";
open(OUT, ">$dayfile3") or die "Can't open $dayfile3";

my $line1;
my $line2;
my @l1;
my @l2;
$/="\r";
while(not eof IN1 and not eof IN2) {
	$line1 = <IN1>;
	$line2 = <IN2>;
	chomp $line1;
	@l1 = split "\t", $line1;
	chomp $line2;
	@l2 = split "\t", $line2;
	while($l1[0] lt $l2[0] and not eof IN1 and not eof IN2) {
		print OUT $line1,"\r";;
		$line1 = <IN1>;
		chomp $line1;
		@l1 = split "\t", $line1;
	}
	while($l2[0] lt $l1[0] and not eof IN1 and not eof IN2) {
		print OUT $line2,"\r";;
		$line2 = <IN2>;
		chomp $line2;
		@l2 = split "\t", $line2;
	}
	#we get here because $l1[0] eq $l2[0] (same stockcode)
	#so we can attempt to repair the fields in the line
	#simple 'repair' is to take the larger of each price/vol
	for (my $i=2; $i <=6; $i++) {
		if ($l1[$i] < $l2[$i]) {
			$l1[$i] = $l2[$i];
		}
	}
	print OUT join "\t", @l1;
	print OUT "\r";
}

if (not eof IN1) {
	while(<IN1>) {
		print OUT $_;
	}
}

if (not eof IN2) {
	while(<IN2>) {
		print OUT $_;
	}
}

close OUT;
