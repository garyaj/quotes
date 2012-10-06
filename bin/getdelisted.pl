#!/usr/bin/env perl
use strict;
use warnings;

use LWP::Simple;
use HTML::TableExtract;

my $content = get("http://www.asx.com.au/asx/research/CompanyDelisted.jsp");
die "Couldn't get it!" unless defined $content;

my $te = new HTML::TableExtract( headers => ['Company name', 'ASX code', 'Date delisted', 'Reason'] );
$te->parse($content);
my @codes = sort map { $_->[1] } ($te->rows);
$,="\n";
print @codes;
print "\n";
