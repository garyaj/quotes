#!/usr/bin/perl
#Get a stock quote from TradingRoom quote page
#Use as many CPAN modules as possible to minimise hassle of screen-scraping page(s).
use strict;
use warnings;

use Class::Date qw(now);

#using WWW::Mechanize to simplify later interactions with the quote page,
#e.g. login/password for 'live' quotes
use WWW::Mechanize;
my $browser = WWW::Mechanize->new();

my $code = shift @ARGV
	or die "Usage: $0 code";
$code = uc $code;
# tell it to get the main page
$browser->get("http://www.tradingroom.com.au/apps/qt/quote.ac?code=$code");

# create a new parser
use XML::LibXML;
my $parser = XML::LibXML->new();

my $xp = $parser->parse_html_string($browser->{res}->content);

#There are 20 <td class = "quotedatacell1"> tags in a TradingRoom quote
#(Very kind of the designers to uniquely identify real data fields).

#Could use 'quotedatahead1' tags to line up names of data fields with their values.
#This might prevent problems if TR designers decide to move any of the fields. But
#my guess is that they would be more likely to change the class names so I prefer
#just to use the node number.
#my @names = $xp->findnodes('//th[@class = "quotedatahead1"]');
my @nodes = $xp->findnodes('//td[@class = "quotedatacell1"]');
my $string;
#Node no.: name
#	 3	= Open
#	 4	= High
#	10	= Low
#  0	= Close
#	 5	= Volume
my @ohlcv = ($code, now->strftime("%d/%m/%Y"));
foreach my $i (3,4,10,0,5) {
	$string = $nodes[$i]->textContent();
	$string =~ s/\s//g;
	$string =~ s/\$//g;
	$string =~ s/,//g;
	push @ohlcv, $string;
}
$string = join "\t", @ohlcv;
print $string;
print "\n";
