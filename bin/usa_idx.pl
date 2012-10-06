#!/sw/bin/perl -w
# Downloads current prices only.
# GAJ:20010802: get ASX/S&P indices from Yahoo
# GAJ:20050126: use different quote server.
# Quotes delayed at least 20 minutes

# Modified to use comma separated yahoo CGI

use LWP::Simple;
use Text::CSV;
use strict;

$|++;

my %stlist = (
	'^DJI' => 'XDOW',
	'^GSPC' => 'XSP',
	'^IXIC' => 'XNQ',
);

my $csv = Text::CSV->new();

#Old
#http://table.finance.yahoo.com/table.csv?a=7&b=14&c=2002&d=10&e=15&f=2002&s=^aord&y=0&g=d&ignore=.csv
#New
#http://finance.yahoo.com/d/quotes.csv?s=MSFT&f=sl1d1t1c1ohgv&e=.csv

my $content;
while (my($usname,$ozname) = each %stlist) {
	my $lname = lc $ozname;
	#print STDERR $lname,"\n";
	my $lusa = lc $usname;
	# Try for 20 times to
	# pass request to the user agent and get a (non-empty) response back
	my $success = 0;
	for (1..20) {
		$content = get("http://finance.yahoo.com/d/quotes.csv?s=$lusa\&f=sl1d1t1c1ohgv\&e=.csv");
		if ($content) {
			$success = 1;
			last;
		}
		sleep 2;
	}
	if (not $success) {
		print STDERR "Can't get $lusa\n";
		next;
	}
	my $status = $csv->parse($content);
	my @a = $csv->fields();
	#{local $,="\n"; print STDERR $a[2]; print STDERR "\n"; }
	$a[2] =~ s%(\d+)/(\d+)%$2/$1%;	#swap month and day
	printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%d\r", $ozname, @a[2,5,6,7,1,8];
}
