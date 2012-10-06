#!/usr/bin/perl -w
my $count;
while(<>) {
	chomp;
	$stk = lc($_);
	#$cmd = '/usr/bin/lwp-download http://charts.comsec.com.au/HistoryData/HistoryData.dll/GetData?Symbol='.$_.'\&TimePeriod=10yr\&.csv '."$stk.txt";
	$cmd = '/usr/bin/lwp-download http://203.26.177.136/investments/tr_cur_price_hist_csv.isam?code='.$_." $stk.txt";
	system($cmd);
	$count++;
	sleep 2 if (!($count%5));
}
