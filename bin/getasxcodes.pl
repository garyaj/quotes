#!/usr/bin/perl -w
#Retrieve ASX's latest file of listed companies and their stock codes
#and output a list of stockcodes for use with 

#Get latest options list
#cd $HOME/bin
#/usr/bin/wget -O Warrants.csv http://www.asx.com.au/programs/Warrants.csv
#Convert latest warrants into tab-delimited records
#/usr/bin/perl $HOME/optsim/warrlist2mysql.pl Warrants.csv > warrlist.lst

package main;
use LWP::Simple;
use Text::CSV;
use Carp;
use strict;

$|++; #immediate output

my $doc;
my $file = get("http://www.asx.com.au/asx/research/ASXListedCompanies.csv")
	or die "Can't retrieve ASXListedCompanies.csv";
my $csv = Text::CSV->new();
my $stock;
my @lines = split /\r?\n/, $file;
my $status;
my @columns;
foreach my $line (@lines) {
	next if ($line =~ /^ASX listed companies/);	#skip header line
	next if ($line =~ /^Company name/);	#skip header line
	next unless ($line =~ /\S/);	#skip blank lines
	$status = $csv->parse($line);
	@columns = $csv->fields();
	print "$columns[1]\n";
}
