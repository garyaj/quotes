#!/usr/bin/perl -w
#Display daily stock prices from a DB file:
# Out: $h{date(yyyymmdd)} = [qw(open high low close volume)]
use Fcntl;
use MLDBM qw(DB_File Storable);
use DB_File;
use Carp;
use Date::Manip;
use strict;

my %h;
my $stock;
my $eol = "\n";

if ($ARGV[0] =~ /^-h/) {
	shift @ARGV;
	print "Date    \tOpen\tHigh\tLow\tClose\tVolume\n"; 
}

while (my $dbfile = shift @ARGV) {

	tie %h, 'MLDBM', "$dbfile", O_RDONLY, 0664, $DB_BTREE
		or croak "Cannot access $dbfile database:$!\n";
	$stock = uc($dbfile);

	while (my($k, $v) = each %h) {
		$k =~ s/(....)(..)(..)/$3\/$2\/$1/;
		print "$stock\t$k\t$v->[0]\t$v->[1]\t$v->[2]\t$v->[3]\t$v->[4]$eol";
	}
	untie %h;
}

