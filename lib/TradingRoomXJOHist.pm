package TradingRoomXJOHist;
use LWP::Simple;
use HTML::TableExtract;
use Date::Parse;
use strict;

#Builds array of fields from TradingRoom XJO warrant history pages
#  0   1    2    3    4    5     6     7     8
#code,date,open,high,low,close,volume,cdf,openinterest

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
	my $te = HTML::TableExtract->new();
	my $doc = get("http://www1.tradingroom.com.au/tpl/investments/X/XJO/tr_cur_price_hist_$code.html");

	$doc =~ s/\&nbsp;/ /g;
	$te->parse($doc);

	$self->{ohlcvi} = [];
	my @a;

	my $line;
	my $flag = 0;
	my $dt;
	my @d;

	foreach my $ts ($te->table_states) {
		if ($ts->depth == 1 and $ts->count == 1) {
			foreach my $row ($ts->rows) {
				next if ($row->[0] =~ /Date/);
				@d = strptime $row->[0];
				$a[0] = uc $code;
				$a[1] = sprintf "%04d-%02d-%02d",$d[5]+1900,$d[4]+1,$d[3];
				$a[2] = $row->[1];
				$a[3] = $row->[2];
				$a[4] = $row->[3];
				$a[5] = $row->[4];
				$a[6] = $row->[5];
				$a[7] = $row->[6];
				$a[8] = 0;
				foreach (@a) {
					s/[,\240\s]//g;
				}
				push @{$self->{ohlcvi}}, [@a];
				@a = ();
			}
		}
	}
}

sub showit {
	my ($self) = @_;
	return @{$self->{ohlcvi}};
}

1;
