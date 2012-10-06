#!/usr/bin/perl -w
use Mail::Box::Manager;
use Class::Date qw(now);
use strict;

#create a sub-directory to put attachments into
use vars qw($ATTACHMENTS);
$ATTACHMENTS = '/var/opt/cccalc';
mkdir $ATTACHMENTS unless (-d $ATTACHMENTS);

my $mgr = Mail::Box::Manager->new
	or die "Can't create Mail::Box::Manager";
my $pop = $mgr->open(type => 'pop3', username => 'cccalc@ashton-jones.com.au',
               password => '54rftx7', server_name => 'mail.ashton-jones.com.au')
	or die "Can't open pop3 cccalc\@ashton-jones.com.au";

my $today = now->strftime("%Y%m%d");
my $subject;
foreach my $message ($pop->messages) {
	$subject =  $message->get('Subject') || '<no subject>';
	if ($subject =~ /^CCC $today/) { #is it a gzipped quote file?
		get_attach($message);
	}
}
$pop->close;
chdir $ATTACHMENTS;
system("ncftpput -V -u ashton-jones\@ashton-jones.com.au -p 7566bb ashton-jones.com.au mainwebsite_html ccc.csv ccc.html cccprem.html cccstock.html");

sub get_attach {
	my ($m) = @_;
	my $attachment;

	if ($m->isMultipart) {
		foreach my $part ($m->parts) {
			$part->head =~ /name=\"(.+)\"/g;
			my $disp     = $part->body->type;
			my $filename = $disp->attribute('filename')
									|| $disp->attribute('name');
			$attachment = "$ATTACHMENTS/$filename";

			print $filename,"\n";
			# ---- Write attachment to file
			open(FH, ">$attachment");
			print FH $part->decoded;
			close(FH);
		}
	}
}
