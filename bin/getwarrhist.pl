#!/usr/bin/perl -w
#Hopefully a one-off to the backlog of new GICS S&P indices
# GAJ:20010802: get ASX/S&P indices from Yahoo
# Saves huge amount of time and useless HTML padding
# Quotes delayed at least 20 minutes

# Modified to use comma separated yahoo CGI

use LWP::Simple;
use Class::Date qw(now date -DateParse);
use strict;

#my $dt = now;
my $dt = date [2002,12,20,0,0,1];

$|++;

system ("$ENV{HOME}/bin/getwarrlist.sh");
my $pfile = "warrlist.lst";
open(IN, "$ENV{HOME}/bin/$pfile") or die "Can't open $pfile";
my @stlist;
while(<IN>) {
	chomp;
	s/\s.*$//;
	push @stlist, $_;
}
close IN;

#http://table.finance.yahoo.com/table.csv?a=7&b=14&c=2002&d=10&e=15&f=2002&s=^aord&y=0&g=d&ignore=.csv
my $quotes;
my ($a, $b, $c, $d, $e, $f);
my @b;
my $str = 'a='.$dt->_month.'&b='.$dt->day.'&c='.$dt->year.'&d='.$dt->_month.'&e='.$dt->day.'&f='.$dt->year;
my $str2;
my $content;
my @lines;
my $lname;
my $lusa;
my $d2;

foreach my $ozname (@stlist) {
	$lname = lc $ozname;
	print STDERR $lname,"\n";
	$str2 = '&s='.$lname.'.ax&y=0&g=d&ignore=.csv';
	$content = get("http://table.finance.yahoo.com/table.csv?$str$str2");
	@lines = split /\n/, $content;
	foreach (@lines) {
		next if /^Date/; #Get rid of header
		print STDERR $_,"\n";
		($a, $b, $c, $d, $e, $f) = split ',',$_,6;
		@b = split '-', $a;
		$b[2] = ($b[2] > 70 ? 1900+$b[2] : 2000+$b[2]);
		$d2 = date $b[0].'-'.$b[1].'-'.$b[2];
		$a = $d2->strftime("%d/%m/%Y");
		printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%d\r", $ozname, $a, $b, $c, $d, $e, $f;
	}
}
