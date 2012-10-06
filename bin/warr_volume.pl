#!/usr/local/bin/perl -w
#display shares underlying warrants sorted into reverse warrant volume order
my $showem;
if ($ARGV[0] =~ /^-l$/) {
	shift @ARGV;
	$showem = 1;
}
@lines = (<>);
foreach (@lines) {
	@a = split;
	$a[0] =~ s/^(...).*$/$1/;
	$b{$a[0]} += $a[6];
}
while(my($key,$value) = each %b) {
	push @c, [ $value, $key ];
}
my $share;
foreach (sort { $b->[0] <=> $a->[0] } @c ) {
	last if ($_->[0] < 500000);
	print "$_->[1]:$_->[0]\n";
	$share = $_->[1];
	if ($showem) {
		print map { $_->[0] }
					sort { $b->[1] <=> $a->[1] }
					map { [$_, (split)[7] ] }
					grep /^$share/,
					@lines;
	}
}
