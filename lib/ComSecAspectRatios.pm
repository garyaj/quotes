package ComSecAspectRatios;
use LWP::Simple;
use HTML::TableExtract;
use Date::Parse;
use Class::Date qw(date);
use Carp;
use strict;
#Extracts Peter Spann's 7 fundamental criteria from ComSec's analysis pages
#Code AnnPE ROE EBP PrvDiv Div DivIncr PrvRev Rev RevIncr PrvEPS EPS EPSIncr Gearing IntCover
#CurPE NextEPS2 CalcPEG PEG r_date
#The 7 criteria are:
#	DivIncr (Dividend Increase) > 7%, =(Div-PrvDiv)/PrvDiv
# ROE > 14%
#	RevIncr (Revenue Increase) > 10%, =(Rev-PrvRev)/PrvRev
# EPSIncr (EPS Increase) > 9%, =(EPS-PrvEPS)/PrvEPS
# Gearing < 70%
# IntCover (Interest cover) >= 3
# PE/G (Price Earnings/Growth) < 1,	=CurPE/(sqrt((NextEPS2-EPS)/EPS+1)-1)/100
#Additionally I've included:
# EBP (Earnback period) < 8,	=ln(1+ROE*CurPE)/ln(1+ROE), undervalued if < 8

sub new {
	my ($proto, $file) = @_;
	my $class = ref($proto) || $proto;
	my $self  = {};
	bless ($self, $class);
	$self->init($file);
	return $self;
}

sub init {
	my ($self, $code) = @_;
	$self->{fields} = [ qw( Code AnnPE ROE EBP PrvDiv Div DivIncr PrvRev Rev RevIncr
	                 PrvEPS EPS EPSIncr Gearing IntCover CurPE NextEPS2
									 CalcPEG PEG r_date ) ];

	my $te;
	$te = new HTML::TableExtract();
	#my $doc = get("http://aspect.comsec.com.au/aspect/company/$code-mv.asp");
	#my $doc = get("http://aspect.comsec.com.au/aspect/company/$code-ch.asp");
	my $doc;
	my $line;
	my $flag;
	my $dt;
	my ($CurPE, $NextEPS2, $EPS, $PrvEPS, $ROE, $Div, $PrvDiv, $Rev, $PrvRev);
	my $r_code;
	my @d;
	my @a;
	$self->{spann7} = {};
	@{$self->{spann7}}{@{$self->{fields}}} = ();	#define all the return fields
	$self->{spann7}{Code} = uc $code;

	{
	local $/;
	open(IN,"$ENV{HOME}/fund/aspect/$code-mv.asp") or croak "Can't open $code-mv.asp";
	undef $/; #slurp whole file
	$doc = <IN>;
	close IN;
	}

	$te->parse($doc);
	$flag = 0;

	foreach my $ts ($te->table_states) {
		foreach my $row ($ts->rows) {
			next if ($row->[0] =~ /^\s*$/);	#skip blank rows
			@a = @$row;
			pop @a if ($a[-1] eq '');
			if ($a[0] =~ /Last update:/) {
				$dt = $a[0];
				$dt =~ s/^.*Last update://s;
				@d = strptime $dt;
				$dt = date [$d[5]+1900,$d[4]+1,$d[3]];
				$self->{spann7}{r_date} = $dt->ymd;
			} elsif ($a[0] =~ /^ASX Code (...)/) {
				$r_code = $1;
				if ($r_code !~ /^$code$/i) {
					croak "File not code $code";
				}
			} elsif ($a[0] =~ /^P\/E ratio/) {
				$self->{spann7}{CurPE} = $self->findfld(1, @a);
			} elsif ($a[0] =~ /^P\/E growth ratio/i) {
				$self->{spann7}{PEG} = $self->findfld(1, @a);
			} elsif ($a[0] =~ /^Debt\/Equity ratio/i) {
				$self->{spann7}{Gearing} = $self->findfld(1, @a);
			} elsif ($a[0] =~ /^Interest Cover/i) {
				$self->{spann7}{IntCover} = $self->findfld(1, @a);
			} elsif ($a[0] =~ /^EPS/i) {
				$self->{spann7}{NextEPS2} = $self->findfld(3, @a);
				last;
			}
		}
	}

	$te = new HTML::TableExtract();
	{
		local $/;
		open(IN,"$ENV{HOME}/fund/aspect/$code-ch.asp") or croak "Can't open $code-ch.asp";
		undef $/; #slurp whole file
		$doc = <IN>;
		close IN;
	}

	$te->parse($doc);
	$flag = 0;

	foreach my $ts ($te->table_states) {
		foreach my $row ($ts->rows) {
			next if ($row->[0] =~ /^\s*$/);	#skip blank rows
			@a = @$row;
			pop @a if ($a[-1] eq '');
			if ($a[0] =~ /^ASX Code (...)/) {
				$r_code = $1;
				if ($r_code !~ /^$code$/i) {
					croak "File not code $code";
				}
			} elsif ($a[0] =~ /^Earnings/i) {
				$self->{spann7}{EPS} = $self->findfld(-1, @a);
				$self->{spann7}{PrvEPS} = $self->findfld(-2,@a);
			} elsif ($a[0] =~ /^Dividends/i) {
				$self->{spann7}{Div} = $self->findfld(-1, @a);
				$self->{spann7}{PrvDiv} = $self->findfld(-2, @a);
			} elsif ($a[0] =~ /^Avge annual PE ratio/i) {
				$self->{spann7}{AnnPE} = $self->findfld(-1, @a);
			} elsif ($a[0] =~ /^Revenues/i) {
				$self->{spann7}{Rev} = $self->findfld(-1, @a);
				$self->{spann7}{Rev} =~ s/,//g;
				$self->{spann7}{PrvRev} = $self->findfld(-2, @a);
				$self->{spann7}{PrvRev} =~ s/,//g;
			} elsif ($a[0] =~ /^Return on equity/i) {
				$self->{spann7}{ROE} = $self->findfld(-1, @a);
				$CurPE = $self->{spann7}{CurPE};
				$NextEPS2 = $self->{spann7}{NextEPS2};
				$NextEPS2 ||= 0;
				$EPS = $self->{spann7}{EPS};
				$EPS ||= 0;
				if ($EPS > 0 and $NextEPS2 > 0 and $NextEPS2 > $EPS) {
					$self->{spann7}{CalcPEG} = sprintf "%0.3f",$CurPE/(sqrt(($NextEPS2-$EPS)/$EPS+1)-1)/100;
				} else {
					$self->{spann7}{CalcPEG} = 9999;
				}
				$ROE = $self->{spann7}{ROE}/100.0;
				if ($ROE > 0 and $CurPE > 0) {
					$self->{spann7}{EBP} = sprintf "%0.3f",log(1+$ROE*$CurPE)/log(1+$ROE);
				} else {
					$self->{spann7}{EBP} = 9999;
				}
				$Div = $self->{spann7}{Div};
				$PrvDiv = $self->{spann7}{PrvDiv}+0;
				if ($PrvDiv > 0) {
					$self->{spann7}{DivIncr} = sprintf "%0.3f",($Div-$PrvDiv)/$PrvDiv;
				} else {
					$self->{spann7}{DivIncr} = 0;
				}
				$Rev = $self->{spann7}{Rev};
				$PrvRev = $self->{spann7}{PrvRev};
				$PrvRev ||= 0;
				if ($PrvRev > 0) {
					$self->{spann7}{RevIncr} = sprintf "%0.3f",($Rev-$PrvRev)/$PrvRev;
				} else {
					$self->{spann7}{RevIncr} = 0;
				}
				$EPS = $self->{spann7}{EPS};
				$PrvEPS = $self->{spann7}{PrvEPS};
				if ($PrvEPS > 0) {
					$self->{spann7}{EPSIncr} = sprintf "%0.3f",($EPS-$PrvEPS)/$PrvEPS;
				} else {
					$self->{spann7}{EPSIncr} = 0;
				}
				last;
			}
		}
	}
}

sub showit {
	my ($self) = @_;
	return @{$self->{spann7}}{@{$self->{fields}}};
}

sub zeroit {
	my ($self, $value) = @_;
	if (defined $value) {
		if ($value eq '--') {
			return 0;
		} else {	
			return $value;
		}
	} else {
		return 0;
	}
}


sub findfld {
	my ($self, $idx, @a ) = @_;
	#is $idx within the length of @a?
	if ($idx > 0 or $idx < 0 and -$idx < $#a) {
		if ($a[$idx] =~ /--/) {
			return 0;
		} else {
			$a[$idx] =~ s/,//g;
			if ($a[$idx] =~ /^\s*\$?([\-\d\.,]+)\%\s*$/) {
				$a[$idx] = $1 / 100.00;
			}
			$a[$idx] ||= 0;	#make sure it's numeric
			return $a[$idx];
		}
	} else {
		return 0;
	}
	return 0;
}
1;
