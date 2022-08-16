#!/bin/bash
# default shell is already bash

# NOTE:(UK) This file
#     --- generate data set and load it into R*tree and STR-tree and Adp-STR-tree
#	  --- PLOT data set and Leaf MBRs.
#     --- run quey sets with different AQAR values on
#			--- R*
#			--- classic STR and
#			--- Adp-STR-tree having the same aqar with query set. The goal is to see the adv of adaptive STR tree.

# Sample usage:
#     --- ./settings.sh  -d10000  -lu -x0 -y0 -ef -c92  100 u  0.02  0.02
#														qs ql  qx    qy

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



# get data size from console:
while getopts 'd:l:x:y:e:c:' flag;   #
do
    case "${flag}" in
        d) ds=${OPTARG};;         # number of data
        l) loc_dist=${OPTARG};;   # data location distribution: (u)niform or (g)aussian
        x) dx=${OPTARG};;         # data x-size
        y) dy=${OPTARG};;         # data y-size
        e) dxdy_dist=${OPTARG};;  # fix of uniformly dist. b/w [ 0.001dx and dx ]
        c) capacity=$(($page_size*${OPTARG}));;   # has meaning for obj-type=data. capacity of R-tree
    esac
done



if [ $# -eq 0 ]
  then
    echo "No arguments supplied. See the Usage."
    exit
fi

export qs=$7   # query set size
export ql=$8   # query location distr. (u)niform or (g)aussian
export qx=$9   # query x-size
export qy=${10}   # query y-size


# data set:
#export obj_type # data vs query
export ds   # data set size
export loc_dist  # data location distribution: uniform or gaussian, u or g

# data extent: (point or region)
export dx #=0.03
export dy #=0.03
#export dx=0
#export dy=0
export dxdy_dist #=f    # DATA EXTENT distribution: if obj-type= data ==> f or u: fixed size or uniformly distr.
                                                    #else obj-type=query set an AQAR value: from [0.1, 0.3, 0.7, 1, 1.428, 3.33, 10 ]


export treeprefix=tree${ds}_${loc_dist}_${dx}_${dy}_${dxdy_dist}_${capacity}


# construct related directories s.a data, database/ds, query/ plt/ and results/ inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
export datafile=$HOME/eclipse-workspace/test-build/data/data${ds}_${loc_dist}_${dx}_${dy}_${dxdy_dist}

mkdir -p $HOME/eclipse-workspace/test-build/database/${ds}    # -p flag: mk dir only if dir does not exist.
export dbdir=$HOME/eclipse-workspace/test-build/database/${ds}

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
export queryfile=$HOME/eclipse-workspace/test-build/query/query${qs}_${ql}_${qx}_${qy}  # This is prefix of queryfile. We will add aqar-value as suffix later.


mkdir -p $HOME/eclipse-workspace/test-build/plt   # -p flag: mk dir only if dir does not exist.
export pltdir=$HOME/eclipse-workspace/test-build/plt

mkdir -p $HOME/eclipse-workspace/test-build/results
export resultsdir=$HOME/eclipse-workspace/test-build/results

./gen_data_query_AND_load_indexes.sh





