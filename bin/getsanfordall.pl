#!/usr/local/bin/perl -w
use strict;
use WWW::Mechanize;
use URI::URL;

{ no warnings 'redefine';
  *WWW::Mechanize::redirect_ok = sub { $_[0]->{uri} = $_[1]->uri; 1 };
};

my $agent = WWW::Mechanize->new();
$agent->env_proxy();

die "Usage: $0 dd/mm/yy [dd/mm/yy...]" unless (@ARGV >= 1);

  $agent->get('https://www.sanford.com.au/sanford/Public/Home/Login.asp');
  $agent->form(1) if $agent->forms and scalar @{$agent->forms};
  $agent->form(1);
  { local $^W; $agent->current_form->value('username', 'gashtonjones'); };
  $agent->form(1);
  { local $^W; $agent->current_form->value('password', 'rf98nyqe'); };
  { local $^W; $agent->current_form->value('StartIn', 'Markets'); };
  $agent->form(1);
  $agent->submit();
for my $date (@ARGV) {
  $agent->get('http://www.sanford.com.au/sanford/Members/Research/HistoricalData.asp?section=1');
  $agent->form(1) if $agent->forms and scalar @{$agent->forms};
  $agent->form(2);
  { local $^W; $agent->current_form->value('HistDataDate', $date); };
  $agent->form(2);
  { local $^W; $agent->current_form->value('HistDataFormat', 'MetaStock'); };
  $agent->submit();
  print $agent->content,"\n";
}
