#!/bin/bash
# default shell is already bash

# NOTE:(UK) This file uses real data sets and load it into R*tree and STR-tree.
# sample usage: ...$./realDataLoad.sh nyc_cb
# my execs:
bindir=$HOME/eclipse-workspace/test-build/

capacity=92
fillfactor=0.999   # used in only bulk loading

# external sorting parameters:
export pS=10000  # Page size (RPB). Used in ext-sort
export bP=100    # buffer size (num of buffers). Used in ext-sort

# construct related directories s.a data, database/ds, plt inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
datadir=$HOME/eclipse-workspace/test-build/data

datafilename=$1  #this takes the first arguman from commandline..
datafile=${datadir}/$datafilename
export xl=$2
export yl=$3
export xh=$4
export yh=$5


mkdir -p $HOME/eclipse-workspace/test-build/plt   # -p flag: mk dir only if dir does not exist.
pltdir=$HOME/eclipse-workspace/test-build/plt

mkdir -p $HOME/eclipse-workspace/test-build/database    # -p flag: mk dir only if dir does not exist.
dbdir=$HOME/eclipse-workspace/test-build/database

treename=tree_$datafilename

echo Load R*-Tree ${treename}_Dyn
# 2>&1 : combines (or called redirect) standard error (stderr) with standard out (stdout)
# > r  : redirect std output to file r with replacing r.  >> : redirect and append to file r.
#time ../../test-rtree-RTreeLoad $datafile $treename $capacity intersection > r 2>&1    # intersection is query type. But we are not sending any query!!

time ${bindir}/test-rtree-RTreeLoad ${datadir}/$datafilename ${dbdir}/$treename $capacity intersection 2>r 1>${pltdir}/pltDynLevel0     #redirect cerr to 'r' AND redirect cout to plt...file
awk '{if ($1 ~ /Time/  ||
		  $1 ~ /TOTAL/ ||
		  $1 ~ /Buffer/ ||
		  $1 ~ /Fill/ ||
		  ($1 ~ /Index/ && $2 ~ /capacity/) ||
		  $1 ~ /Utilization/ ||
		  $1 ~ /Buffer/ ||
		  $2 ~ /height/ ||
		  $1 ~ /Number/ ||
		  $1 ~ /Read/||
		  $1 ~ /Write/||
		  $1 ~ /Level/) print $0}' < r > ${dbdir}/${treename}_Dyn-Loading-Stats
rm -rf r
echo -------------

echo Load STR-Tree ${treename}_STR
time ${bindir}/test-rtree-RTreeBulkLoad ${datadir}/$datafilename ${dbdir}/$treename $capacity $fillfactor 1 $pS $bP 2> r 1>${pltdir}/pltSTRLevel0;  #redirect cerr to 'r' AND redirect cout to plt...file
	awk '{if ($1 ~ /Time/  ||
		  $1 ~ /TOTAL/ ||
		  $1 ~ /Buffer/ ||
		  $1 ~ /Fill/ ||
		  ($1 ~ /Index/ && $2 ~ /capacity/) ||
		  $1 ~ /Utilization/ ||
		  $1 ~ /Buffer/ ||
		  $2 ~ /height/ ||
		  $1 ~ /Number/ ||
		  $1 ~ /Read/||
		  $1 ~ /Write/||
		  $1 ~ /Level/) print $0}' < r > ${dbdir}/${treename}_STR-Loading-Stats;
	rm -rf r;

	echo -------------



####### PLOTTING:
bash ./pltDynLevel0-draw.sh
bash ./pltSTRLevel0-draw.sh






