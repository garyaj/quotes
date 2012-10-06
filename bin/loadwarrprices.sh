#!/bin/bash
cd $HOME
d=`date +%Y%m%d`
showm allwarrs_day_$d.txt | perl -pe 's/(..)\/(..)\/(....)/$3-$2-$1/; s/$/\t\t/;' > ./warrprices.lst
#Load into mysql stockprices prices table
echo "load data local infile './warrprices.lst' replace into table prices" | mysql stockprices
