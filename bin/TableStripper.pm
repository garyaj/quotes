package TableStripper;
use base HTML::Parser;
sub start {
	my($self, $tagname, $attr, $attrseq, $origtext) = @_;
	$self->{tt_seen}++ if $tagname eq "tt";
	$self->{tt_count}++ if $tagname eq "tt";
	$self->SUPER::start(@_);
}
sub end {
	my($self, $tagname, $origtext) = @_;
	$self->SUPER::end(@_);
	$self->{tt_seen}-- if $tagname eq "tt";
}
sub text {
	my($self, $origtext, $is_cdata) = @_;
	if ($self->{tt_seen}) {
	  if ($self->{tt_count} >= 1 and $self->{tt_count} <= 4
	    or $self->{tt_count} == 10) {
		$main::out_text .= "$origtext|";
	  }	
	}
}

1;
