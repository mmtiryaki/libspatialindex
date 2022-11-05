#!/bin/bash
# default shell is already bash

# NOTE:(UK) This file generates 2 types of objetcs::
#     --- data set and load it into R*tree 
#     --- query set with a specific AQAR values.
#	  --- execute diffrent types of queries inersection|selfjoin|10NN
# Sample usage:
#		---  ./run.sh 100 u 0.04 0.04 f 5 1 u 0.08 0.08 1.4 selfjoin

# my source:
export SCRIPT_PATH="$HOME/git/libspatialindex/test/rtree"  # Here, do not use "~/git/...". It does not work!

# my execs:
export bindir=$HOME/eclipse-workspace/test-build/
# system params:
export page_size=1  # number of 4K
# Common usage ise page size 4K. (92 is for 4K.) If you change page size, you should increase capacity.
#export capacity=$(($page_size*5))
export capacity
export fillfactor=0.999   # used in only bulk loading
export cache_size=10 # max. number of 4K-pages in mem
# external sorting parameters:
export pS=10000  # Page size (RPB). Used in ext-sort
export bP=100    # buffer size (num of buffers). Used in ext-sort



export treeform=tree$1_$2_$3_$4_$5_$6
export queryform=query$7_$8_$9_${10}_${11}

# construct related directories s.a data, database/ds, plt inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
export datafile=$HOME/eclipse-workspace/test-build/data/data$1_$2_$3_$4_$5

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
export queryfile=$HOME/eclipse-workspace/test-build/query/$queryform
#export queryfile=$HOME/eclipse-workspace/test-build/query/queryfile

mkdir -p $HOME/eclipse-workspace/test-build/database/$1    # -p flag: mk dir only if dir does not exist.
export dbdir=$HOME/eclipse-workspace/test-build/database/$1

mkdir -p $HOME/eclipse-workspace/test-build/plt   # -p flag: mk dir only if dir does not exist.
export pltdir=$HOME/eclipse-workspace/test-build/plt

mkdir -p $HOME/eclipse-workspace/test-build/results
export resultsdir=$HOME/eclipse-workspace/test-build/results

echo Generate data "set" with $1 $2 $3 $4 $5;
${bindir}/test-rtree-Generator data $1 $2 $3 $4 $5 > $datafile

echo Generate R*tree with capacity $6;
treename=D_${treeform}
${bindir}/test-rtree-RTreeLoad $datafile ${dbdir}/$treename $page_size $cache_size $6 ${12} 0


# for guaranteeing a fresh seed
sleep 1

echo Generate query "set" with $7 $8 $9 ${10} ${11};
${bindir}/test-rtree-Generator query $7 $8 $9 ${10} ${11} > ${queryfile}

echo Range Querying $treename with ${queryform};
time ${bindir}/test-rtree-RTreeQuery ${queryfile} $dbdir/$treename $cache_size ${12} 2>r 1>$resultsdir/${treename}_$queryform;      #redirect cerr to 'r' AND redirect cout to results...file
awk '{if ($1 ~ /Reads/) print $2}' < r >> readstat;  # append each Reads-value to r1
awk '{if ($1 ~ /Time/) print $9}' < r >> timestat;   # append each Time-value to t1
rm -rf r;
echo ----------------

mv  readstat $pltdir
mv  timestat $pltdir

# Proof of correctness:::
cat $datafile ${queryfile} > .t
echo Running exhaustive search
time ${bindir}/test-rtree-Exhaustive .t ${12} > res2

echo Comparing results
sort -n $resultsdir/${treename}_$queryform > a
sort -n res2 > b
if diff a b
then echo "Same results with exhaustive search. Everything seems fine."
else echo "PROBLEM! We got different results from exhaustive search!"
fi
echo Results: `wc -l a`
rm -rf a b res2 .t




