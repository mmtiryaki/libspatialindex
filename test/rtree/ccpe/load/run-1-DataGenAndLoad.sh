#!/bin/bash
# default shell is already bash

# NOTE:(UK) This file generates data set and load it into R*tree and STR-tree.
# In case you wish to generate only data set and display it with gnuplot, then comment loading commands at the last 2 line.

# Sample usage: ./run-1-DataGenAndLoad.sh -d10000

# my source:
export SCRIPT_PATH="$HOME/git/libspatialindex/test/rtree/ccpe/load"  # Here, do not use "~/git/...". It does not work!

# my execs:
export bindir=$HOME/eclipse-workspace/test-build/

# get data size from console:
while getopts d: flag   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        d) ds=${OPTARG};;
    esac
done

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Look at the usage"
    exit
fi

# system params:
export page_size=1  # number of 4K
# Common usage ise page size 4K. (92 is for 4K.) If you change page size, you should increase capacity.
export capacity=$(($page_size*92))
export fillfactor=0.999   # used in only bulk loading
export cache_size=10 # max. number of 4K-pages in mem

# external sorting parameters:
export pS=10000  # Page size (RPB). Used in ext-sort
export bP=100    # buffer size (num of buffers). Used in ext-sort


# data set:
export ds   # read from console
export data_loc_dist=u  # data location distribution: uniform or gaussian, u or g

# data extent: (point or region)
#export dx=0.01
#export dy=0.01
export dx=0
export dy=0
export d_dist=f    # DATA EXTENT distribution: f or u: fixed size or uniformly distr.





export treeprefix=tree${ds}_${data_loc_dist}_${dx}_${dy}_${d_dist}_${capacity}




# construct related directories s.a data, database/ds, plt inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
export datadir=$HOME/eclipse-workspace/test-build/data
export dpostfix=${ds}_${data_loc_dist}_${dx}_${dy}_${d_dist}

export datafile=${datadir}/data${dpostfix}

mkdir -p $HOME/eclipse-workspace/test-build/plt   # -p flag: mk dir only if dir does not exist.
export pltdir=$HOME/eclipse-workspace/test-build/plt

mkdir -p $HOME/eclipse-workspace/test-build/database/${ds}    # -p flag: mk dir only if dir does not exist.
export dbdir=$HOME/eclipse-workspace/test-build/database/${ds}





# No more global definitions exist in the following scirpts. Otherwise we should have used . "$SCRIPT_PATH"/run-DataGen if there were therein.
"$SCRIPT_PATH"/run-DataGen.sh    # you may or may not write bash at the beginning.
bash "$SCRIPT_PATH"/run-DataLoad.sh



