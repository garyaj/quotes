#!/bin/bash
#Get latest options list
cd $HOME/bin
/usr/bin/wget -O OptList.csv http://www.asx.com.au/programs/OptList.csv

#Convert latest options into tab-delimited records for loading into mysql
/usr/local/bin/perl $HOME/optsim/optlist2mysql.pl OptList.csv > optlist.lst
