#!/bin/bash
# default shell is already bash

# NOTE:(UK) This file generates 2 types of objetcs::
#     --- data set and load it into R*tree and STR-tree and PLOT data set and Leaf MBRs.
#     --- quey set with a specific AQAR values.

# Sample usage:
#       --- run-1-DataGenAndLoad.sh -tdata  -d100 -lu -x0.04 -y0.04 -ef   -c5
#		--- run-1-DataGenAndLoad.sh -tquery -d100 -lu -x0.04 -y0.04 -e1.4

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
while getopts 't:d:l:x:y:e:c:' flag;   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        t) obj_type=${OPTARG};;   # data or query
        d) ds=${OPTARG};;         # number of objects
        l) loc_dist=${OPTARG};;   # obj location distribution: (u)niform or (g)aussian
        x) dx=${OPTARG};;         # obj x-size
        y) dy=${OPTARG};;         # obj y-size
        e) dxdy_dist=${OPTARG};;  # fix of uniformly dist. b/w [ 0.001dx and dx ]
        c) capacity=$(($page_size*${OPTARG}));;   # has meaning for obj-type=data. capacity of R-tree
    esac
done



if [ $# -eq 0 ]
  then
    echo "No arguments supplied. See the Usage."
    exit
fi

if [[ $obj_type == 'data' ]] && [[ $capacity -lt 4 ]];
  then
    echo $capacity
    echo "No valid capacity supplied. See the usage."
    exit
fi

if [[ $obj_type == 'data' ]] && ([[ $dxdy_dist != 'f' ]] && [[ $dxdy_dist != 'u' ]]);
  then
    echo "No valid extent-dist supplied. See the usage."
    exit
fi

if [[ $obj_type == 'query' ]] && ([[ $dxdy_dist == 'f' ]] || [[ $dxdy_dist == 'u' ]]);
  then
    echo "No AQAR supplied. See the usage."
    exit
fi



# obj set:
export obj_type # data vs query
export ds   # obj set size
export loc_dist  # data location distribution: uniform or gaussian, u or g

# data extent: (point or region)
export dx #=0.03
export dy #=0.03
#export dx=0
#export dy=0
export dxdy_dist #=f    # DATA EXTENT distribution: if obj-type= data ==> f or u: fixed size or uniformly distr.
                                                    #else obj-type=query set an AQAR value: from [0.1, 0.3, 0.7, 1, 1.428, 3.33, 10 ]


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

./run.sh





