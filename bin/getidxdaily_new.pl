#!/usr/bin/perl -w
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

use LWP::Simple;
use Class::Date qw(date);
use strict;

my $dt = date(time);
if ($ARGV[0] =~ /^-s/) {
	shift @ARGV;	#remove -s
	$dt = shift @ARGV;
	die "Usage: $0 [-s yyyymmdd]" unless ($dt =~ /^\d{8}/);
	$dt = date [substr($dt,0,4),substr($dt,4,2),substr($dt,6,2),0,0,0];
}
my %mname;
my $i;
foreach(qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)) {
	$mname{$_} = ++$i;
}

my $today = sprintf("%04d%02d%02d", $dt->year, $dt->month, $dt->day);
$|++;
my $dayfile = "$ENV{HOME}/allidx_day_$today.txt";

open(OUT, ">$dayfile") or die "Can't open $dayfile";
select OUT;

my %stlist = (
	'^DJI' => 'XDJ',
	'^GSPC' => 'XSP',
	'^IXIC' => 'XNQ',
	'^AORD' => 'XAO',
	'^AAMI' => 'XAM',
	'^AAII' => 'XAI',
	'^AARI' => 'XAR',
	'^AATI' => 'XAT',
	'^ABII' => 'XBF',
	'^ABMI' => 'XBM',
	'^ACII' => 'XCE',
	'^ADCI' => 'XDC',
	'^ADII' => 'XDI',
	'^ADRI' => 'XDR',
	'^AENI' => 'XEG',
	'^AXEY' => 'XEY',
	'^AFHI' => 'XFH',
	'^AFLI' => 'XFL',
	'^AGII' => 'XGO',
	'^AXHB' => 'XHB',
	'^AFSI' => 'XIF',
	'^AIII' => 'XIN',
	'^AXIU' => 'XIU',
	'^AXJI' => 'XJI',
	'^AXJO' => 'XJO',
	'^AXJP' => 'XJP',
	'^AXJR' => 'XJR',
	'^AXKI' => 'XKI',
	'^AXKO' => 'XKO',
	'^AXKP' => 'XKP',
	'^AXKR' => 'XKR',
	'^AXMD' => 'XMD',
	'^AMEI' => 'XME',
	'^AXMI' => 'XMI',
	'^AXMR' => 'XMR',
	'^AXMT' => 'XMT',
	'^AOMI' => 'XOM',
	'^APPI' => 'XPP',
	'^APTI' => 'XPT',
	'^ARII' => 'XRE',
	'^AXTE' => 'XTE',
	'^AXTI' => 'XTI',
	'^ATLI' => 'XTL',
	'^ATOI' => 'XTO',
	'^ATII' => 'XTP',
	'^AXTR' => 'XTR',
	'^ATUI' => 'XTU',
);

#http://table.finance.yahoo.com/table.csv?a=3&b=5&c=2002&d=3&e=5&f=2002&s=^aord&y=0&g=d
my $quotes;
my ($qdate, $open, $high, $low, $close, $volume);

my $content;
my @lines;
my $opts = sprintf("a=%d&b=%d&c=%d&d=%d&e=%d&f=%d&y=0&g=d",
                   $dt->day,$dt->month,$dt->year,$dt->day,$dt->month,$dt->year); 
my $string;
my $codel;
my @b;
foreach my $code (keys %stlist) {
	$codel = lc($code);
	$string = $opts."&s=$codel";
	$content = get("http://table.finance.yahoo.com/table.csv?$string");
	print STDERR "$stlist{$code}:";
	@lines = split /\n/, $content;
	#Get rid of Heading line
	if (@lines > 1) {
		shift @lines;
		# Split table data by ','
		($qdate, $open, $high, $low, $close, $volume) = split /,/, $lines[0];

		if ($close > 0 and $open == 0 and $high == 0 and $low == 0) {
			$open = $high = $low = $close;
		}
		@b = split /\-/, $qdate;
		$qdate = sprintf "%02d/%02d/%04d", $b[0], $mname{$b[1]}, $b[2]+2000;
		printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\r", $stlist{$code}, $qdate, $open, $high, $low, $close;
		print STDERR "$close";
	} else {
		print STDERR "N/A";
	}
	print STDERR "\n";
}

close OUT;
