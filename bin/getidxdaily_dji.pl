#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  getidxdaily_dji.pl
#
#        USAGE:  ./getidxdaily_dji.pl  
#
#  DESCRIPTION:  Extract US index data from Yahoo Finance pages.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gary Ashton-Jones (GAJ), gary@ashton-jones.com.au
#      COMPANY:  Ashton-Jones Consulting
#      VERSION:  1.0
#      CREATED:  09/03/2011 22:44:03
#     REVISION:  24/05/2012 17:23:00 GAJ Updated Scrappy.
#===============================================================================

use 5.010;

use Scrappy;
use Date::Parse;
my $year = (localtime(time))[5] + 1900;
my $yearstring = " $year 00:00:01";
#printf "%02d/%02d/%04d\n", $day, $month+1, $year+1900;
my ($open, $date, $high, $low, $close);
my $url;
my %stlist = (
	'DJI' => 'XDOW',
	'GSPC' => 'XSP',
	'IXIC' => 'XNQ',
);
for my $code (keys %stlist) {
  $url = "http://finance.yahoo.com/q/bc?s=%5E$code+Basic+Chart&t=1d";
  ($open, $high, $low, $close) = (0,0,0,0);
  my $scraper = Scrappy->new;
  if ($scraper->get($url)->page_loaded) {
    $scraper->select('span.time_rtq_ticker span')->each(
      sub {
        ($close = shift->{text}) =~ s/,//g;
      }
    );
    $scraper->select('span.time_rtq span span')->each(
      sub {
        my $daymon = shift->{text};
        my ($ss,$mm,$hh,$day,$month,$year) = strptime("$daymon$yearstring");
        $date = sprintf "%4d%02d%02d", $year+1900, $month+1, $day;
      }
    );
    $scraper->select('table#table1 tr td.yfnc_tabledata1')->each(
      sub {
        my $tag = shift;
        $open = $tag->{text};
        if ($open =~ /N\/A/) {
          $open = 0;
        } else {
          $open =~ s/,//g;
        }
      }
    );
    $scraper->select('table#table2 tr td.yfnc_tabledata1 span span')->each(
      sub {
        my $tag = shift;
        if ($tag->{id} =~ /^yfs_g00_/) {
          $low = $tag->{text};
          if ($low =~ /N\/A/) {
            $low = 0;
          } else {
            $low =~ s/,//g;
          }
        } elsif ($tag->{id} =~ /^yfs_h00_/) {
          $high = $tag->{text};
          if ($high =~ /N\/A/) {
            $high = 0;
          } else {
            $high =~ s/,//g;
          }
        }
      }
    );
  }
  printf "%s,%s,%.3f,%.3f,%.3f,%.3f,0\n",
    $stlist{$code}, $date, $open, $high, $low, $close;
}

# vi:ai:et:sw=2 ts=2

