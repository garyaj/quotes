#!/bin/sh
$HOME/quotes/bin/getidxdaily.pl > $HOME/quotes/cronlogix 2>&1
$HOME/quotes/bin/getprotadaily.pl > $HOME/quotes/cronlog 2>&1
$HOME/quotes/bin/getwarrdaily.pl > $HOME/quotes/cronwarr 2>&1
$HOME/quotes/bin/loadwarrcode.sh > $HOME/quotes/cronwcode 2>&1
$HOME/quotes/bin/loadwarrprices.sh > $HOME/quotes/cronwprice 2>&1
