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
chdir "/home/gary/Downloads/geniustrader-0.01/data/etos"
	or die "Can't chdir to directory";
opendir(DIR, ".") or die "Can't open directory";
my @files = readdir(DIR);
close DIR;
shift @files; shift @files;	#remove . and ..
my $v;
my @t = localtime();
my $k = sprintf("%04d%02d%02d", $t[5]+1900, $t[4]+1, $t[3]);
if (scalar @ARGV == 1) {
	$k = shift @ARGV;
}
my @vol;
my $dbfile;
foreach $dbfile (@files) {
	tie %h, 'MLDBM', "$dbfile", O_RDONLY, 0664, $DB_BTREE
		or croak "Cannot access $dbfile database:$!\n";

	$v = $h{$k};
	push @vol, [$v->[4], $dbfile];
	untie %h;
}
my @b =  (sort {$b->[0] <=> $a->[0]} @vol);
for my $i (0..23) {
	print "$b[$i]->[1]\t$b[$i]->[0]\n";
}

