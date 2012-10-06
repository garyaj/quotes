#!/bin/bash
#Get latest options list
cd $HOME/bin
getoptlist.sh
#Load into mysql stockprices options table
echo "load data local infile './optlist.lst' replace into table options" | /usr/bin/mysql stockprices
