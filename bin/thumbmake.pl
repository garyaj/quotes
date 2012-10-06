#!/usr/bin/perl -w
# Thumbnail example

use strict;
use Imager;

die "Usage: thumbmake.pl filename\n" if !-f $ARGV[0];
my $file = shift;

my $format;

my $img = Imager->new();
$img->open(file=>$file) or die $img->errstr();

$file =~ s/\.[^.]*$//;

# Create smaller version
my $thumb = $img->scale(scalefactor=>.2);

# Autostretch individual channels
$thumb->filter(type=>'autolevels');

# try to save in one of these formats
SAVE:

for $format ( qw( png gif jpg tiff ppm ) ) {
	# Check if given format is supported
	if ($Imager::formats{$format}) {
		$file.="_low.$format";
		print "Storing image as: $file\n";
		$thumb->write(file=>$file) or
			die $thumb->errstr;
		last SAVE;
	}
}

