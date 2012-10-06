#!/bin/bash
#cd ~/Downloads/geniustrader/data/etos
cd ~/mktdata/data/txtfiles/sdoc
for i in `cat ~/bin/sdoclist.txt` ; do
	getprc $i
done
