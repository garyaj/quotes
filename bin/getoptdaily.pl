#!/usr/bin/perl -w
use lib "$ENV{HOME}/lib";
use TradingRoomOHLCVI;
use strict;

$|++;
my @t = localtime();
my $today = sprintf("%04d%02d%02d", $t[5]+1900, $t[4]+1 ,$t[3]);

system ("$ENV{HOME}/bin/getoptlist.sh");
my $dayfile = "$ENV{HOME}/allopts_day_$today.txt";
my @a;
my $lastcode;
if (-e $dayfile) {	#If file is already (partly) there, pickup from where we left off.
	open(IN, $dayfile);
	while(<IN>) {
		@a = split;	#split on whitespace
		$lastcode = $a[0] if (length($a[0]) == 5);
	}
	close IN;
}
open(OUT, ">>$dayfile") or die "Can't open $dayfile";
my $pfile = "optlist.lst";
open(IN, "$ENV{HOME}/bin/$pfile") or die "Can't open $pfile";
#If the day file already contains lines, skip forward in the input file
if (length($lastcode) == 5) {
	while (<IN>) {
		chomp;
		s/\s.*$//;
		last if ($_ eq $lastcode);
	}
}
#The next read on the input file will be the first line or the line
#after the one which corresponds to the last line in the output file.
	 
my $tr;
$,="\t";
select OUT;
while (<IN>) {
	chomp;
	s/\s.*$//;
	print STDERR "$_\n";
	$tr = TradingRoomOHLCVI->new($_);
	@a = $tr->showit;
	if ($a[2] or $a[3] or $a[4] or $a[5]) {
		print @a;
		print "\n";
	}
}

close IN;
close OUT;
