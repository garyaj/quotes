#!/bin/bash
#cd ~/Downloads/geniustrader/data/etos
cd ~/mktdata/data/txtfiles/etos
for i in `cat ~/bin/asxopts.txt` ; do
	getprc $i
done
