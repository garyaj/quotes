#!/usr/bin/perl -w
use lib "$ENV{HOME}/lib";
use TradingRoomOHLCVI;
use DBI;

my %mon = (Jan => 1,
				Feb => 2,
				Mar => 3,
				Apr => 4,
				May => 5,
				Jun => 6,
				Jul => 7,
				Aug => 8,
				Sep => 9,
				Oct => 10,
				Nov => 11,
				Dec => 12,
);
my @t = localtime();
my $today = sprintf("%04d%02d%02d", $t[5]+1900, $t[4]+1 ,$t[3]);
my $stoday = sprintf("%02d/%02d/%04d", $t[3], $t[4]+1 ,$t[5]+1900);

$|++;

my $dayfile = "$ENV{HOME}/allstks_day_$today.txt";
open(OUT, ">$dayfile") or die "Can't open $dayfile";
select OUT;

my $pfile = "allasxcodes.txt";
open(IN, "$ENV{HOME}/bin/$pfile") or die "Can't open $pfile";
$,="\t";
my @a;
my @b;
while (<IN>) {
	chomp;
	$tr = TradingRoomOHLCVI->new($_);
	@a = $tr->showit;
	@b = split /-/, $a[1];
	$a[1] = sprintf("%02d/%02d/%04d", $b[0], $mon{$b[1]}, $b[2]);
	if ($a[2] or $a[3] or $a[4] or $a[5]) {
		print @a;
		print "\r";
	}
}
close IN;
close OUT;
