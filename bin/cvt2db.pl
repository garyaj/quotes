#!/usr/bin/perl -w
#Read daily stock prices and output them to a DB file:
# In: date(dd-Mon-yyyy)<tab>open<tab>high<tab>low<tab>close<tab>volume<tab>dilution
# Out: $h{date(yyyymmdd)} = [qw(open high low close volume)]
use Fcntl;
use MLDBM qw(DB_File Storable);
use DB_File;
use Carp;
use Date::Manip;
use strict;

my %h;
my $txtdir = shift @ARGV;
my $infile = shift @ARGV;
my $dbfile = $infile;
$infile = "$ENV{HOME}/mktdata/data/txtfiles/$txtdir/$infile.txt";
open(IN, "<$infile")
	or die "Cannot open input file $infile: $!";

tie %h, 'MLDBM', "$dbfile", O_RDWR|O_CREAT, 0664, $DB_BTREE
	or croak "Cannot access $dbfile database:$!\n";

my @a;
my $first = 1;
my($k,$open,$high,$low,$close,$volume,$dilute);
while(<IN>) {
	#skip headings line
	if ($first) {
		$first = 0;
		next;
	}

	chomp;
	@a = split /\t/;
	$k = &UnixDate($a[0], "%Y%m%d");
	$h{$k} = [@a[1..5]];
	#print &UnixDate($a[0], "%Y%m%d");
	#print "\n";
}

#while (my($k, $v) = each %h) {
#	print "$k=($v->[0] $v->[1] $v->[2] $v->[3] $v->[4])\n";
#}

