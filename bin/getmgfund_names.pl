#!/usr/local/bin/perl -w
use strict;
use WWW::Mechanize;
use XML::LibXML;
my $agent = WWW::Mechanize->new( autocheck => 1 );

$agent->get('https://www.sanford.com.au/sanford/Public/Home/Login.asp');
$agent->form(1) if $agent->forms and scalar @{$agent->forms};
{ local $^W; $agent->current_form->value('username', 'gashtonjones'); };
{ local $^W; $agent->current_form->value('password', 'rf98nyqe'); };
$agent->submit();
$agent->get('http://www.sanford.com.au/sanford/Members/Trading/MFQuote.asp?section=3');
die "Can't access MFQuote" unless ($agent->uri() =~ /MFQuote/);
$agent->form(1) if $agent->forms and scalar @{$agent->forms};

# parse the data
my $parser = XML::LibXML->new();
$parser->recover(1);	#don't crash if html is not strict
my $doc = $parser->parse_html_string($agent->content);

my @mgrs = $doc->findnodes('//option[@value]');
foreach my $mgr (@mgrs) {
	my $fundmgrid = $mgr->getAttribute('value');
	my $fundmgrname = $mgr->textContent();
	if ($fundmgrid) {
		#print "$fundmgrid:$fundmgrname\n";
		#get all funds for this fund manager
		{ local $^W; $agent->current_form->value('FundMgrID', $fundmgrid); };
		$agent->submit();
		if ($agent->status() eq '200') {	#OK
			#and extract the Fund ID and name
			# parse the data
			$parser = XML::LibXML->new();
			$parser->recover(1);	#don't crash if html is not strict
			$doc = $parser->parse_html_string($agent->content);
			my @funds = $doc->findnodes('//option[@value]');
			foreach my $fund (@funds) {
				my $fundid = $fund->getAttribute('value');
				my $fundname = $fund->textContent();
				if ($fundid) {
					print "$fundid\tM\t$fundname\tC\n";
				}
			}
		}
	}
}

1;

