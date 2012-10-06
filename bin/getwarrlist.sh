#!/bin/bash
#Get latest options list
cd $HOME/quotes/bin
/usr/bin/wget -O Warrants.csv http://www.asx.com.au/programs/Warrants.csv

#Convert latest warrants into tab-delimited records
/sw/bin/perl $HOME/quotes/bin/warrlist2mysql.pl Warrants.csv > warrlist.lst
