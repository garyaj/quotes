#!/usr/bin/perl -w
#Hopefully a one-off to the backlog of new GICS S&P indices
# GAJ:20010802: get ASX/S&P indices from Yahoo
# Saves huge amount of time and useless HTML padding
# Quotes delayed at least 20 minutes

# Modified to use comma separated yahoo CGI

use Class::Date qw(date);
use lib "$ENV{HOME}/lib";
use YahooQuotes;
use strict;

#my $dt = now;
my $dt = date [2004,7,13,0,0,1];

$|++;

my $pfile = "allasxcodes.txt";
open(IN, "$ENV{HOME}/bin/$pfile") or die "Can't open $pfile";
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
