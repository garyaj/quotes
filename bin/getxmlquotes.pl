#!/usr/bin/perl -w
use Mail::Box::Manager;
use strict;

#create a sub-directory to put attachments into
use vars qw($ATTACHMENTS);
$ATTACHMENTS = '/var/opt/xmlquotes';
mkdir $ATTACHMENTS unless (-d $ATTACHMENTS);

my $mgr = Mail::Box::Manager->new
	or die "Can't create Mail::Box::Manager";
my $pop = $mgr->open(type => 'pop3', username => 'xml-quotes@ashton-jones.com.au',
               password => '54rftx7', server_name => 'mail.ashton-jones.com.au')
	or die "Can't open pop3 xml-quotes\@ashton-jones.com.au";

my $subject;
my $filename;
foreach my $message ($pop->messages) {
	$subject =  $message->get('Subject') || '<no subject>';
	if ($subject =~ /^File (2\d{7}\.xml\.gz)/) { #is it a gzipped quote file?
		$filename = $1;
		get_latest_quotes($filename, $message);
	}
}
$pop->close;

sub get_latest_quotes {
	my ($file, $m) = @_;
	my $attachment = "$ATTACHMENTS/$file";
	return if (-f $attachment); #already downloaded this file?

	if ($m->isMultipart) {
		foreach my $part ($m->parts) {
			if ($part->body->size > 16384) {
				$part->head =~ /name=\"(.+)\"/g;
				my $disp     = $part->body->type;
				my $filename = $disp->attribute('filename')
										|| $disp->attribute('name');
				die "Filename mismatch: $file and $filename" unless ($file eq $filename);

				print $filename,"\n";
				# ---- Write attachment to file
				open(FH, ">$attachment");
				print FH $part->decoded;
				close(FH);
			}
		}
	}
}
