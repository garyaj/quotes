#!/bin/bash
cd ~/Downloads/geniustrader-0.01/data/etos
for i in ??? ; do
	cvt2db.pl etos $i
done
cd ~/Downloads/geniustrader-0.01/data/sdoc
for i in ??? ; do
	cvt2db.pl sdoc $i
done
