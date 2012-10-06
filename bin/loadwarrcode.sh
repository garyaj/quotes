#!/bin/bash
#Get latest warrants list
cd $HOME/bin
getwarrlist.sh
#Load into mysql stockprices warrants table
echo "load data local infile './warrlist.lst' replace into table warrants" | mysql stockprices
