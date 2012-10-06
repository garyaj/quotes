#!/usr/bin/perl -w
#Hopefully a one-off to the backlog of new GICS S&P indices
# GAJ:20010802: get ASX/S&P indices from Yahoo
# Saves huge amount of time and useless HTML padding
# Quotes delayed at least 20 minutes

# Modified to use comma separated yahoo CGI

use LWP::Simple;
use Date::Parse;
use DateTime;
use strict;

my $indate = shift @ARGV;
die "Usage: $0 yyyy/mm/dd" unless $indate =~ m%(\d{4})/(\d{1,2})/(\d{1,2})%;
my $dt = DateTime->new(
	year   => $1,
	month  => $2,
	day    => $3,
	hour   => 0,
	minute => 0,
	second => 1,
	time_zone => 'Australia/Sydney',
);

$|++;

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

#http://table.finance.yahoo.com/table.csv?a=7&b=14&c=2002&d=10&e=15&f=2002&s=^aord&y=0&g=d&ignore=.csv
my $quotes;
my @a;
my @b;
my $str = 'a='.$dt->month_0.'&b='.$dt->day.'&c='.$dt->year.'&d='.$dt->month_0.'&e='.$dt->day.'&f='.$dt->year;
my $str2;
my @lines;
my $lname;
my $lusa;
my @d1;
my $d2;
my $time;
my $req;
my $res;
my $content;
my $success;

while (my($usname,$ozname) = each %stlist) {
	$lname = lc $ozname;
	print STDERR $lname,"\n";
	$lusa = lc $usname;
	#open(OUT, ">$lname.txt") or die "Can't open $lname";
	#select OUT;
	$str2 = '&s='.$lusa.'&y=0&g=d&ignore=.csv';
	# Try for 20 times to
	# pass request to the user agent and get a (non-empty) response back
	$success = 0;
	for (1..20) {
		$content = get("http://table.finance.yahoo.com/table.csv?$str$str2");
		@lines = split /\n/, $content;
		if (@lines > 1) {
			$success = 1;
			last;
		}
		sleep 2;
	}
	if (not $success) {
		print STDERR "Can't get $lusa\n";
		next;
	}
	foreach (@lines) {
		next if /^Date/; #Get rid of header
		next if /^<!--/; #Get rid of advert
		print STDERR $_,"\n";
		@a = split ',';
		@b = split '-', $a[0];
		$b[2] = ($b[2] > 70 ? 1900+$b[2] : 2000+$b[2]);
		$time = str2time("$b[0]-$b[1]-$b[2]", $dt->offset);
		$d2 = DateTime->from_epoch( epoch => $time, time_zone => 'Australia/Sydney' );
		$a[0] = $d2->strftime("%d/%m/%Y");
		printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%d\r", $ozname, @a;
	}
	#close OUT;
}
