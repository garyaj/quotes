#!/usr/bin/perl -w
# GAJ:20010610: get all of ASX shares in blocks of n(=100) from Yahoo
# Saves huge amount of time and useless HTML padding
# Quotes delayed at least 20 minutes

# Modified to use comma separated yahoo CGI
# Josh McIver <jmmc at flaglink.com>
# Set to use "st1l9cv" in query string.
# Here is list of known variables that can be passed to CGI
# s  = Symbol			l9 = Last Trade
# d1 = Date of Last Trade	t1 = Time of Last Trade
# c1 = Change			c  = Change - Percent Change
# o  = Open Trade		h  = High Trade
# g  = Low Trade		v  = Volume
# a  = Ask Price		b  = Bid Price
# j  = 52 week low		k  = 52 week high
# n  = Name of company		p  = Previous close
# x  = Name of Stock Exchange

use LWP::Simple;
use Class::Date qw(date);
use strict;

my $dt = date(time);
my $today = sprintf("%04d%02d%02d", $dt->year, $dt->month, $dt->day);

$|++;

my @stlist = <>;
chop @stlist;

###Example query to comma separated yahoo quote CGI
###http://quote.yahoo.com/d/quotes.csv?s=KDHAX&f=sl1pd1cv&e=.csv
my $n = 100;
my $last;
my $quotes;
my $FH;
my $str;
my ($a, $b, $c, $d, $e, $f, $g);
my $content;
my @lines;

for (my $i = 0; $i <= $#stlist; $i+=$n) {
	$last = ($i+$n < $#stlist? $i+$n : $#stlist+1);

	$str = "/d/quotes.csv\?s=";

	#Add all quotes to a scalar called quotes which can be used in the
	#query string as well as below in the while loop
	$quotes = join '.ax+', @stlist[$i..$last-1];
	$quotes =~ s/$/.ax/;

	$str .= "$quotes&f=sd1ohgl9v&e=.csv";

	$content = get("http://quote.yahoo.com$str");
	@lines = split /\r\n/, $content;
	foreach (@lines) {
		#chop off newline
		chomp;
		#Get rid of ' - '
		s/ - /,/g; 
		#Get rid of '"'
		s/\"//g;
		# Split table data by ','
		($a, $b, $c, $d, $e, $f, $g) = split (",");

		#print info if $a is one of the quotes desired and volume > 0
		if ($quotes =~ /$a/i) {
			$a =~ s/\.AX$//i;
			$g =~ s#N/A#0#;
			if ($g > 0) {
				if ($f > 0 and $c == 0 and $d == 0 and $e == 0) {
					$c = $d = $e = $f;
				}
				$b =~ s%(\d+)/(\d+)%$2/$1%;
				printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%d\n", $a, $b, $c, $d, $e, $f, $g;
			}
		}
	}
}
