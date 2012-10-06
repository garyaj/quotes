#!/usr/local/bin/perl -w
use strict;
use WWW::Mechanize;

{ no warnings 'redefine';
  *WWW::Mechanize::redirect_ok = sub { $_[0]->{uri} = $_[1]->uri; 1 };
};

my $agent = WWW::Mechanize->new();
$agent->env_proxy();

die "Usage: $0 code dd/mm/yy" unless (@ARGV == 2);
my $code = shift @ARGV;
my $date = shift @ARGV;
$agent->get('https://www.sanford.com.au/sanford/Public/Home/Login.asp');
$agent->form(1) if $agent->forms and scalar @{$agent->forms};
$agent->form(1);
{ local $^W; $agent->current_form->value('username', 'gashtonjones'); };
{ local $^W; $agent->current_form->value('password', 'rf98nyqe'); };
$agent->submit();
$agent->get('http://www.sanford.com.au/sanford/Members/Research/HistoricalData.asp?section=1');
$agent->form(1) if $agent->forms and scalar @{$agent->forms};
$agent->form(1);
{ local $^W; $agent->current_form->value('ASXCode', $code); };
{ local $^W; $agent->current_form->value('StartDate', $date); };
{ local $^W; $agent->current_form->value('HistDataFormat', 'MetaStock'); };
$agent->submit();
print $agent->content,"\n";
