#!/usr/bin/perl -w
# YahooQuotes: class to retrieve ASX quotes from Yahoo using CSV server
# getquotes() method expects to be passes an array of stock codes and it
# retrieves quotes in blocks of n(=100) from Yahoo.
# However Yahoo is increasingly putting zeroes randomly into quotes so
# have added a 'fallback' procedure to test for this and use Finance::Quote::ASX to get values for these
# codes only. ASX pages are HTML pages and screen-scraping is more expensive than Yahoo's CSV format.

# CSV server saves huge amount of time and useless HTML padding
# Yahoo quotes are delayed at least 20 minutes

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

package YahooQuotes;
use List::Util qw(min);
use LWP::Simple;
use Finance::Quote;

sub new {
  my ($proto) = @_;
  my $class = ref($proto) || $proto;
  my $self  = {};
  bless ($self, $class);
  $self->init();
  return $self;
}

sub init {
  my ($self) = @_;
  return $self;
}

sub getquotes {
  my ($self, $stlist) = @_;
  my @qarray;
  ###Example query to comma separated yahoo quote CGI
  ###http://quote.yahoo.com/d/quotes.csv?s=KDH.AX&f=sohgl9v&e=.csv
  my $n = 100;
  my @q;
  my $last;
  my $quotes;
  my $str;

  my $asx = Finance::Quote->new("ASX");	#fallback if Yahoo can't deliver
  $asx->require_labels(qw/open high low last volume/);

  for (my $i = 0; $i < $#{$stlist}; $i+=$n) {
    $last = ($i+$n < $#{$stlist}? $i+$n : $#{$stlist}+1);

    $str = "/d/quotes.csv\?s=";

    #Add all quotes to a scalar called quotes which can be used in the
    #query string as well as below in the while loop
    $quotes = join '.ax+', @{$stlist}[$i..$last-1];
    $quotes =~ s/$/.ax/;

    $str .= "$quotes&f=sohgl9v&e=.csv";

    my $res = get("http://quote.yahoo.com$str");
    my @lines = split /\r?\n/, $res;
    foreach (@lines) {
      #Get rid of ' - '
      s/ - /,/g; 
      #Get rid of '"'
      s/\"//g;
      s#N/A#0#g;
      # Split table data by ','
      @q = split (",");

      #print info if $a is one of the quotes desired and volume > 0
      if ($quotes =~ /$q[0]/i) {
        $q[0] =~ s/\.AX$//i;
        if ($q[5] > 0) {
          if (min(@q[1..4]) == 0) {	#one of the fields is zero/missing
            my %info = $asx->fetch("asx",$q[0]);
            $a[0] = $info{$q[0],'open'};
            $a[1] = $info{$q[0],'high'};
            $a[2] = $info{$q[0],'low'};
            $a[3] = $info{$q[0],'last'};
            $a[4] = $info{$q[0],'volume'};

            #only change values in @q if ASX quote is better than the Yahoo one
            if (min(@a) > 0) {	#all data > 0
              @q[1..5] = @a;
            }
          }
          push @qarray, [@q];
        }
      }
    }
  }
  return \@qarray;
}

1;
# vi:ai:et:sw=2 ts=2
