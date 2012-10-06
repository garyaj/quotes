#!/sw/bin/perl -w
# GAJ:20010613: get all of ASX warrants from Yahoo

use Class::Date qw(date);
use lib "$ENV{HOME}/quotes/lib";
use YahooQuotes;
use strict;

my $dt = date(time);
my $today = sprintf("%04d%02d%02d", $dt->year, $dt->month, $dt->day);

$|++;

my $dayfile = "$ENV{HOME}/quotes/allwarrs_day_$today.txt";
open(OUT, ">$dayfile") or die "Can't open $dayfile";
select OUT;

system ("$ENV{HOME}/quotes/bin/getwarrlist.sh");
my $pfile = "warrlist.lst";
open(IN, "$ENV{HOME}/quotes/bin/$pfile") or die "Can't open $pfile";
my @stlist = map { chomp; s/\s.*$//; $_; } (<IN>);
close IN;

my $yq = YahooQuotes->new();
my $quotes = $yq->getquotes(\@stlist);

foreach my $q (@{$quotes}) {
	print STDERR "$q->[0]:$q->[4]\n";
	printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%d\r",
		$q->[0], $dt->dmy, $q->[1], $q->[2], $q->[3], $q->[4], $q->[5];
}

close OUT;
