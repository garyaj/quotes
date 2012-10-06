#!/usr/bin/perl
#From intra-day prices supplied by Trading Room, create a one-line
#summary of Open, High, Low, Close, Volume
while(<>) {
	next if /^\s*$/;	#ignore blank lines
	chomp;
	($stime, $sprice, $svol) = split /\t/;
	if (!$seenheader) {
		$stock = $stime;
		$sdate = $sprice;
		$sdate =~ s%/%%g;
		$seenheader = 1;
		$seenclose = 0;
		$low = 9999999999;
		$high = 0;
		next;
	}
	@b = split /:/, $stime;
	$tvol += $svol;
	if ($b[0] >= 10 and not $seenopen) {
		$sopen = $sprice;
		$seenopen = 1;
	}
	if ($b[0] == 16 and $b[1] > 0 and not $seenclose) {
		$close = $sprice;
		$seenclose = 1;
	}
	if ($seenopen and not $seenclose) {
		$high = $sprice if ($sprice > $high);
		$low = $sprice if ($sprice < $low);
	}
}
print "$sdate,$sopen,$high,$low,$close,$tvol\n";
