#!/sw/bin/perl -w
# GAJ:20030608: Move functionality into YahooQuotes.pm module.
# GAJ:20010610: get all of ASX shares in blocks of n(=100) from Yahoo
# Saves huge amount of time and useless HTML padding
# Quotes delayed at least 20 minutes

use Class::Date qw(date);
use lib "$ENV{HOME}/quotes/lib";
use YahooQuotes;
use strict;

my $later = '';
if (defined $ARGV[0] and $ARGV[0] eq '-l') {
	shift @ARGV;
	$later = '2';
}

my $dt = date(time);
my $today = $dt->strftime("%Y%m%d");

$|++;
my $dayfile = "$ENV{HOME}/quotes/allstks_day${later}_$today.txt";

open(OUT, ">$dayfile") or die "Can't open $dayfile";
select OUT;

my $pfile = "allasxcodes.txt";
open(IN, "$ENV{HOME}/quotes/bin/$pfile") or die "Can't open $pfile";
my @stlist = <IN>;
close IN;
chomp @stlist;

my $yq = YahooQuotes->new();
my $quotes = $yq->getquotes(\@stlist);

foreach my $q (@{$quotes}) {
	print STDERR "$q->[0]:$q->[4]\n";
	printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%d\r",
		$q->[0], $dt->dmy, $q->[1], $q->[2], $q->[3], $q->[4], $q->[5];
}

close OUT;
