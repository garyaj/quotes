#!/sw/bin/perl -w
use strict;
use WWW::Mechanize;
use XML::LibXML;
use Class::Date qw(date);
my $mths = {
	Jan => '01',
	Feb => '02',
	Mar => '03',
	Apr => '04',
	May => '05',
	Jun => '06',
	Jul => '07',
	Aug => '08',
	Sep => '09',
	Oct => '10',
	Nov => '11',
	Dec => '12',
};

my $dt = date(time);
my $close;
my $today = sprintf("%04d%02d%02d", $dt->year, $dt->month, $dt->day);
my $dayfile = "$ENV{HOME}/quotes/allmgf_day_$today.txt";

open(OUT, ">$dayfile") or die "Can't open $dayfile";
select OUT;

my $agent = WWW::Mechanize->new( autocheck => 1 );

$agent->get('https://www.sanford.com.au/sanford/Public/Home/Login.asp');
if ($agent->forms and scalar @{$agent->forms}) {
	$agent->form_number(1);
	$agent->field('username', 'gashtonjones');
	$agent->field('password', 'rf98nyqe');
	$agent->submit();
} else {
	die "Can't login to Sanford";
}
$agent->get('http://www.sanford.com.au/sanford/Members/Trading/MFQuote.asp?section=3');
die "Can't access MFQuote" unless ($agent->uri() =~ /MFQuote/);

# parse the data
my $parser = XML::LibXML->new();
$parser->recover(1);	#don't crash if html is not strict
my $doc = $parser->parse_html_string($agent->content);

my @mgrs = $doc->findnodes('//option[@value]');
foreach my $mgr (@mgrs) {
	my $fundmgrid = $mgr->getAttribute('value');
	my $fundmgrname = $mgr->textContent();
	if ($fundmgrid) {
		warn "$fundmgrid:$fundmgrname\n";
		#get all funds for this fund manager
		$agent->get("http://www.sanford.com.au/sanford/Members/Trading/MFQuote.asp?FundMgrID=$fundmgrid");
		if ($agent->status() ne '200') {	#OK
			warn "Can't access mgr $fundmgrid";
			next;
		}
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
				warn "$fundid:$fundname\n";
				1;
				$agent->get("http://www.sanford.com.au/sanford/Members/Trading/MFQuote.asp?FundID=$fundid");
				if ($agent->status() ne '200') {
					warn "Can't find $fundid";
					next;
				}
				$parser = XML::LibXML->new();
				$parser->recover(1);	#don't crash if html is not strict
				$doc = $parser->parse_html_string($agent->content);

				#my @tables = $doc->findnodes('//table');
				#my $table = $tables[48];
				#Get <td> tags 181,185 and 186	(fragile as eggs!!)
				#Too fragile, Sanford broke it!
				#So how about looping thru nodes until we find 'APIR Code'
				#then count forward from there?
				my @tds = $doc->findnodes('//td');
				for (my $i=0; $i < $#tds; $i++) {
					my $text = $tds[$i]->textContent();
					if ($text eq $fundid) {
						#found start of table
						$close = $tds[$i+4]->textContent();
						$close =~ s/\$//;
						warn "id:$fundid close:$close\n";
						last unless ($close > 0);
						$dt = $tds[$i+5]->textContent();
						last if ($dt eq 'n/a');
						my @d = split '/',$dt;
						$d[1] = $mths->{$d[1]};
						$dt = join '/',$d[0],$d[1],$d[2];
						print "$fundid\t$dt\t$close\r";
						last;	#break out of for-loop
					}
				}
			}
		}
	}
}
close OUT;
