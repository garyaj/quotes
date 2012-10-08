#!/usr/bin/env perl
# GAJ:20010802: get ASX/S&P indices from Yahoo
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

use 5.010;
use LWP::Simple;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $today = sprintf("%04d%02d%02d", $year+1900, $mon+1, $mday);

$|++;
my $dayfile = "$ENV{HOME}/quotes/allidx_day_$today.txt";

open(OUT, ">$dayfile") or die "Can't open $dayfile";
select OUT;

my %stlist = (
	'^DJI' => 'XDOW',
	'^GSPC' => 'XSP',
	'^IXIC' => 'XNQ',
	'^AORD' => 'XAO',
	'^ATOI' => 'XTO',
	'^ATLI' => 'XTL',
	'^AXJO' => 'XJO',
	'^AXDJ' => 'XDJ',
	'^AXSJ' => 'XSJ',
	'^AXEJ' => 'XEJ',
	'^AXFJ' => 'XFJ',
	'^AXXJ' => 'XXJ',
	'^AXHJ' => 'XHJ',
	'^AXNJ' => 'XNJ',
	'^AXIJ' => 'XIJ',
	'^AXMJ' => 'XMJ',
	'^AXPJ' => 'XPJ',
	'^AXTJ' => 'XTJ',
	'^AXUJ' => 'XUJ',
	'^AXKO' => 'XKO',
	'^AFLI' => 'XFL',
	'^AXMD' => 'XMD',
	'^AXSO' => 'XSO',
);

###Example query to comma seperated yahoo quote CGI
###http://quote.yahoo.com/d/quotes.csv?s=KDHAX&f=sl1pd1cv&e=.csv
my $quotes;
my ($a, $b, $c, $d, $e, $f);
my $str = "/d/quotes.csv\?s=";

$quotes = join '+', keys %stlist;

$str .= "$quotes&f=sd1ohgl9&e=.csv";

my $content = get("http://quote.yahoo.com$str");
my @lines = split /\r?\n/, $content;
foreach (@lines) {
	#Get rid of ' - '
	s/ - /,/g; 
	#Get rid of '"'
	s/\"//g;
	# Split table data by ','
	($a, $b, $c, $d, $e, $f) = split (",");

	if ($f > 0 and $c == 0 and $d == 0 and $e == 0) {
		$c = $d = $e = $f;
	}
	$b =~ s/(\d+)\/(\d+)\/(\d+)/sprintf("%4d%02d%02d",$3,$1,$2)/e;
	printf "%s,%s,%.3f,%.3f,%.3f,%.3f\n", $stlist{$a}, $b, $c, $d, $e, $f;
}

close OUT;
