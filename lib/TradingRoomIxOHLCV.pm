package TradingRoomIxOHLCV;

use lib "$ENV{HOME}/lib";
use LWP::Simple;
use HTML::TableExtract;

use strict;
#Builds array of fields from TradingRoom daily index quote pages
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
	#my $te = new HTML::TableExtract(depth => 0, count => 1);
	my $te = new HTML::TableExtract(headers => [qw( First High Low Last)]);
	my $doc = get("http://www1.tradingroom.com.au/tpl/markets/tr_cur_ind_details.isam?idx=$code");

	$te->parse($doc);

	$self->{ohlcvi} = [];

	foreach my $ts ($te->table_states) {
		my @rows = $ts->rows;
		@{$self->{ohlcvi}} = @{$rows[0]}[0..3];
		foreach (@{$self->{ohlcvi}}) {
			s/[,\240\s]//g;
		}
		last;
	}
}

sub showit {
	my ($self) = @_;
	return @{$self->{ohlcvi}};
}

1;
