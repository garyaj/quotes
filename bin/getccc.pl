#!/usr/bin/perl -w
#Download the daily ccc.html file sent to user cccalc@ashton-jones.com.au
#Then FTP it back to the ashton-jones.com.au homepage.
#This script ought to be installed on ashton-jones.com.au machine.
#This current version is so the process can start working quickly.

use Mail::Box::Manager;
use Net::FTP;
use strict;

#create a sub-directory to put attachments into
use vars qw($ATTACHMENTS);
$ATTACHMENTS = '/var/opt/cccalc';
mkdir $ATTACHMENTS unless (-d $ATTACHMENTS);

my $mgr = Mail::Box::Manager->new
	or die "Can't create Mail::Box::Manager";
my $pop = $mgr->open(type => 'pop3', username => 'cccalc#ashton-jones.com.au',
               password => '54rftx7', server_name => 'mail.ashton-jones.com.au')
	or die "Can't open pop3 cccalc#ashton-jones.com.au";

my $ftp = Net::FTP->new("ashton-jones.com.au", Debug => 0);
$ftp->login('ashton-jones#ashton-jones.com.au','dlttgud1');
$ftp->cwd("mainwebsite_html");

my $subject;
my $filedate;
foreach my $message ($pop->messages) {
	$subject =  $message->get('Subject') || '<no subject>';
	if ($subject =~ /^(?:CCC|Covered calls for) (2\d{7})/) { #is it cccalc file?
		$filedate = $1;
		get_latest_cccalc($filedate, $message);
		ftp_put($ftp,$filedate);
	}
}
$pop->close;
$ftp->quit;

sub ftp_put {
	my ($ftp,$filedate) = @_;
	for my $file (qw( ccc.csv ccc.html cccprem.html cccstock.html )) {
		my $res = $ftp->put("$ATTACHMENTS/$file.$filedate", $file);	
		warn "File $file not ftp'd" if ($res ne $file);
	}
}


sub get_latest_cccalc {
	my ($filedate, $m) = @_;
	my $attachment = "$ATTACHMENTS/ccc.csv.$filedate";
	return if (-f $attachment); #already downloaded files for this filedate?

	if ($m->isMultipart) {
		foreach my $part ($m->parts) {
			if ($part->body->size > 100) {
				$part->head =~ /name=\"(.+)\"/g;
				my $disp     = $part->body->type;
				my $filename = $disp->attribute('filename')
										|| $disp->attribute('name');

				print "$filename.$filedate\n";
				# ---- Write attachment to file
				open(FH, ">$ATTACHMENTS/$filename.$filedate");
				print FH $part->decoded;
				close(FH);
			}
		}
	}
}
