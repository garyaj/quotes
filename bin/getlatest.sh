#!/bin/bash
cd ~/Downloads/geniustrader-0.01/data/etos
for i in `cat ~/bin/asxopts.txt` ; do
	~/bin/getcurohlc $i
done
cd ~/Downloads/geniustrader-0.01/data/sdoc
for i in `cat ~/bin/sdoclist.txt` ; do
	~/bin/getcurohlc $i
done
