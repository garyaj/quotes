use 5.010;
use DBI;
my $dbh = DBI->connect ("dbi:CSV:","","", {
  f_dir => "/Users/gary/quotes/asx",
});
$dbh->{csv_tables}{etfs} = {
  eol         => "\n",
  sep_char    => ",",
  quote_char  => undef,
  escape_char => undef,
  file        => "ASXETFs.csv",
  col_names   => [qw( name type benchmark asxcode iresscode bloombergcode mer listingdate)],
};
my $sth = $dbh->prepare("SELECT * FROM etfs");
$sth->execute;
while ( my @row = $sth->fetchrow_array ) {
  say $row[3];
}
# vi:ai:et:sw=2 ts=2
