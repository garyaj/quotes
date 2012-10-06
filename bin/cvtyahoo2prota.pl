#!/usr/bin/perl -w
#Convert data downloaded from Yahoo historical index data into data suitable for
#loading into ProTA on iMac
use Class::Date qw(date -DateParse);
use strict;
my @a;
my @b;
my $dt;
my $b;
my $code;
if ($ARGV[0] eq '-s') {
	shift @ARGV;
	$code = shift @ARGV;
} else {
	die "Usage: $0 -s code infile";
}

while(<>) {
	chomp;
	@a = split /,/;
	@b = split /\-/, $a[0];
	if ($b[2] < 50) {
		$b[2] += 2000;
	} else {
		$b[2] += 1900;
	}
	$b = join '-', @b;
	$dt = date $b;
	$a[0] = $dt->strftime("%d/%m/%Y");
	print "$code\t", join("\t", @a), "\n";
}
