#!/bin/bash
#Add today's prices to history file
for i in `cat ~/bin/asxopts.txt`; do
	j=`echo $i | tr '[A-Z]' '[a-z]'`
	echo $i $j
	getintra $i >> /usr/local/lib/data/etos/$j.txt
done
for i in `cat ~/bin/sdoclist.txt` ; do
	j=`echo $i | tr '[A-Z]' '[a-z]'`
	echo $i $j
	getintra $i >> /usr/local/lib/data/sdoc/$j.txt
done
