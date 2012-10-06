#!/usr/bin/perl -w
#Convert data downloaded from Sanford historical into data suitable for
#loading into ProTA on iMac
while(<>) {
	next unless /^[A-Z]{3,6},/;
	s/(\d{4})(\d\d)(\d\d)/$3\/$2\/$1/;
	s/,/\t/g;
	print;
}
