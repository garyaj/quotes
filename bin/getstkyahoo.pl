#!/usr/bin/perl -w
#Given an ASX code, the script retrieves a CSV-formatted quote
#from Yahoo
#and then displays the stockname from the appropriate field

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
use strict;

$|++; #immediate output

my $doc;
my $file;
my $stock = shift @ARGV;

###Example query to comma seperated yahoo quote CGI
###http://quote.yahoo.com/d/quotes.csv?s=KDHAX&f=sl1pd1cv&e=.csv
my $str = '/d/quotes.csv\?s='.$stock.'&f=snohgl1l9d1t1pvjk&e=.csv';
my $content = get("http://quote.yahoo.com$str");
print "$content";
