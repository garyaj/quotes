#!/usr/bin/perl -w
use Class::Date qw(date);
use Mail::Sender;
my $dt = date(time);
my $today = sprintf("%04d%02d%02d", $dt->year, $dt->month, $dt->day);
my $idxfile = "$ENV{HOME}/allidx_day_$today.txt";
my $dayfile = "$ENV{HOME}/allstks_day_$today.txt";
my $warrfile = "$ENV{HOME}/allwarrs_day_$today.txt";
my $idxtmp = "/tmp/asx_$today.txt";
system("/home/gary/bin/showm $idxfile > $idxtmp");
system("/home/gary/bin/showm $dayfile >> $idxtmp");
system("/home/gary/bin/showm $warrfile >> $idxtmp");

my $sender = new Mail::Sender;
$sender->MailFile({
 to => 'colin@claviusbase.net, gary@ashton-jones.com.au',
 subject => "ASX data for $today",
 msg => "Indexes, shares and warrants data, no options yet.",
 file => "$idxtmp",
});
