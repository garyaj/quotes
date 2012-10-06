#!/sw/bin/perl -w
#Convert warrants.csv file for loading into MySQL warrants table
#Only extract equity warrants 

use strict;

use Text::CSV;

my $csv = Text::CSV->new;

my @w;
my @c;
my $flag = 0;
my @fields;
my $count;
my $column;
my $line;

while(<>) {
	next unless (/^[A-X]{3}W.*,(?:Equity|Index) (Put|Call)/i);	#only look at Equity Puts and Calls
	@c = ();
	$c[2] = $1;
	$c[2] =~ s/^(.).*/$1/;;	#only want first letter of Put|Call
	s/\s+//g;	#remove all spaces
	if ($csv->parse($_)) {
		@w = $csv->fields;
		#CODE,TYPE,EXERCISE,EXPIRY,RATIO,EX STYLE,ISSUER,REGISTRY,LISTED,ISSUED (M),NOTES
		#ALLWMA,Equity Call,1.00,25/09/2003,3.0,American,MACQUARIE,COR,03/06/2003,15,
		#AGLWPA,$13.00,28/06/01,E,BNP Paribas Equities (Australia) Ltd,4 W = 1 S
		#AGLWPA,$13.00,28/06/01,E,BNPParibasEquities(Australia)Ltd,4W=1S
		$c[0] = $w[0];
		($c[1] = $w[0]) =~ s/^(...).*/$1/;
		$c[3] = $w[3];
		($c[4] = $w[2]) =~ s/[\$,]//;
		($c[5] = $w[5]) =~ s/^(.).*/$1/;
		$c[6] = $w[4];
		print join "\t", @c;
		print "\n";
	}
}
