#!/bin/bash
# default shell is already bash

# NOTE:(UK) This file generates data set and load it into R*tree and STR-tree.
# In case you wish to generate only data set and display it with gnuplot, then comment loading commands at the last 2 line.

# Sample usage: ./run-1-DataGenAndLoad.sh -d10000

# my source:
export SCRIPT_PATH="$HOME/git/libspatialindex/test/rtree/animations"  # Here, do not use "~/git/...". It does not work!

# my execs:
export bindir=$HOME/eclipse-workspace/test-build/

# get data size from console:
while getopts 't:d:l:x:y:e:' flag;   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        t) obj_type=${OPTARG};;
        d) ds=${OPTARG};;
        l) loc_dist=${OPTARG};;
        x) dx=${OPTARG};;
        y) dy=${OPTARG};;
        e) dxdy_dist=${OPTARG};;
    esac
done

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Usage:"
    exit
fi

# system params:
export page_size=1  # number of 4K
# Common usage ise page size 4K. (92 is for 4K.) If you change page size, you should increase capacity.
export capacity=$(($page_size*5))
export fillfactor=0.999   # used in only bulk loading
export cache_size=10 # max. number of 4K-pages in mem
# external sorting parameters:
export pS=10000  # Page size (RPB). Used in ext-sort
export bP=100    # buffer size (num of buffers). Used in ext-sort


# obj set:
export obj_type # data vs query
export ds   # obj set size 
export loc_dist  # data location distribution: uniform or gaussian, u or g

# data extent: (point or region)
export dx #=0.03
export dy #=0.03
#export dx=0
#export dy=0
export dxdy_dist #=f    # DATA EXTENT distribution: f or u: fixed size or uniformly distr. OR AQAR value for query


export treeprefix=tree${ds}_${loc_dist}_${dx}_${dy}_${dxdy_dist}_${capacity}


# construct related directories s.a data, database/ds, plt inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
export datafile=$HOME/eclipse-workspace/test-build/data/data${ds}_${loc_dist}_${dx}_${dy}_${dxdy_dist}

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
export queryfile=$HOME/eclipse-workspace/test-build/query/query${ds}_${loc_dist}_${dx}_${dy}_${dxdy_dist}


mkdir -p $HOME/eclipse-workspace/test-build/plt   # -p flag: mk dir only if dir does not exist.
export pltdir=$HOME/eclipse-workspace/test-build/plt

mkdir -p $HOME/eclipse-workspace/test-build/database/${ds}    # -p flag: mk dir only if dir does not exist.
export dbdir=$HOME/eclipse-workspace/test-build/database/${ds}





# No more global definitions exist in the following scirpts. Otherwise we should have used . "$SCRIPT_PATH"/run-DataGen if there were therein.
"$SCRIPT_PATH"/run-DataGenAndLoad.sh    # you may or may not write bash at the beginning.




