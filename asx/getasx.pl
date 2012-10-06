use HTML::TableExtract;
$te = new HTML::TableExtract(depth => 0, count => 1);

undef $/; #slurp whole file
$html_string = <>;
$te->parse($html_string);

$first = 1;
# Examine all matching tables
foreach $ts ($te->table_states) {
	#print $ts->depth(),':',$ts->count(),"\n";
	foreach $row ($ts->rows) {
		if ($first) {	#ignore headings
			$first = 0;
			next;
		}
		#print join ',', @{$row};
		$row->[1] =~ s/[\(\)]//g;
		print $row->[1],"\tI\t", $row->[0],"\tOHLC\n";
	}
}
