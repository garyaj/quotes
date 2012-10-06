#!/usr/local/bin/perl -w
use Class::Date qw(date);
use DBIx::Recordset;
*set = DBIx::Recordset -> Setup ({'!DataSource' => 'dbi:mysql:stockprices',
																	 '!Table'      => 'warrants', });
*set2 = DBIx::Recordset -> Setup ({'!DataSource' => 'dbi:mysql:stockprices',
																	 '!Table'      => 'prices', });

@a = (<>);
chomp @a;
$,="\t";
foreach (@a) {
	@b = split;
	print $b[0];
	$set->Select({'wcode' => $b[0]}) or die "Not found $b[0]:($DBI::errstr)";
	if ($b[0] =~ /^X/) { #index warrants are in points
		$p = sprintf "%0.f", $set[0]{str_price};
		print "\t$p";
	} else {
		print "\t$set[0]{str_price}";
	}
	$d = date $set[0]{exp_date};
	printf " %s%02d",substr($d->monname,0,3),$d->yr;
	print " $set[0]{p_c}";
	print "\t";
	print @b[1..6];
	printf "\t%.2f\n", ($b[5]-$b[2])/$b[2]*100;
}
