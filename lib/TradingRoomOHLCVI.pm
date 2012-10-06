package TradingRoomOHLCVI;
use LWP::Simple;
use XML::LibXML;
use Class::Date qw(date -DateParse);
use strict;
#Builds array of fields from TradingRoom daily quote pages
#  0   1    2    3    4    5     6        7
#code,date,open,high,low,close,volume,openinterest

sub new {
	my ($proto, $file) = @_;
	my $class = ref($proto) || $proto;
	my $self  = {};
	bless ($self, $class);
	$self->init($file);
	return $self;
}

sub init {
	my ($self, $code) = @_;
	my $parser = XML::LibXML->new();
	$parser->recover(1);	#Trading Room quote pages have an illegal '</tr>' tag so just ignore it
	warn "Get $code";
	#my $text = get("http://www2.tradingroom.com.au/servlet/QuoteServlet?code=$code");
	my $text = get("http://www.tradingroom.com.au/apps/qt/quote.ac?code=$code");
	warn "Got $code";
	#convert Entities
	$text =~ s/\&/\&amp;/g;

	my $doc = $parser->parse_html_string($text);

	$self->{ohlcvi} = [];
	$self->{ohlcvi}[0] = uc $code;

	my $datestring = $doc->findvalue('//table[@class="quotetimebar"]/tr/td[1]/text()');
	my $dt = date $datestring;
	$self->{ohlcvi}[1] = $dt->dmy;
	my @td_nodes = $doc->findnodes('//td[@class="quotedatacell1"]');
	$self->{ohlcvi}[2] = $td_nodes[3]->findvalue("./text()");	#open
	$self->{ohlcvi}[3] = $td_nodes[4]->findvalue("./text()"); #high
	$self->{ohlcvi}[4] = $td_nodes[10]->findvalue("./text()"); #low
	$self->{ohlcvi}[5] = $td_nodes[0]->findvalue("./text()"); #close
	$self->{ohlcvi}[6] = $td_nodes[5]->findvalue("./text()"); #volume
	#remove spurious whitespace and punctuation
	foreach (@{$self->{ohlcvi}}) {
		s/[\$,\240\s]//g;
	}
	return $self;
}

sub showit {
	my ($self) = @_;
	return @{$self->{ohlcvi}};
}

1;
