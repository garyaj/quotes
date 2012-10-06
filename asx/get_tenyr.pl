#!/usr/bin/perl -w
my $count;
while(<>) {
	chomp;
	$stk = lc($_);
	$cmd = '/usr/bin/lwp-download http://charts.comsec.com.au/HistoryData/HistoryData.dll/GetData?Symbol='.$_.'\&TimePeriod=10yr\&.csv '."$stk.txt";
	system($cmd);
	system("perl -i -ne 'if (2..eof) {s/\012/\r/g; print;}' $stk.txt");
	$count++;
	sleep 2 if (!($count%5));
}
