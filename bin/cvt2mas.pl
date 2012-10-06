#!/usr/bin/perl
#Convert stock price files in format for mktdata system into format for MAS
use Date::Manip;
$,=',';

while(<>) {
#force skip of first line
	if (!$seen1) {
		$seen1 = 1;
		next;
	} else {
		chomp;
		next if /^\s*$/;
		@a = split /\t/;
		#remove 'dilution factor'
		pop @a;
		$a[0] = &UnixDate($a[0],"%Y%m%d");
		print @a;
		print "\n";
	}
}
