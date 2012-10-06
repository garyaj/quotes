#!/bin/bash
cd ~/mktdata/data/txtfiles
for i in `cat ~/bin/asxopts.txt`; do
	getprc $i
	j=`echo $i | tr '[A-Z]' '[a-z]'`
	cvt2mas.pl $j.txt | sort > /usr/local/lib/data/etos/$j.txt
done
for i in `cat ~/bin/sdoclist.txt` ; do
	getprc $i
	j=`echo $i | tr '[A-Z]' '[a-z]'`
	cvt2mas.pl $j.txt | sort > /usr/local/lib/data/sdoc/$j.txt
done
