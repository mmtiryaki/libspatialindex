#! /bin/bash

# NOTE(UK): This file is to run a set of queries on R*tree and (Adp)-STR-tree AFTER generating dataset and query Workload.
# In case you wish to generate only Query set and display it with gnuplot, then comment loading commands at the last 2 line.

# my source:
export SCRIPT_PATH="$HOME/git/libspatialindex/test/rtree/test5/runQry/"  # Here, do not use "~/git/...". It does not work!

# my execs:
export bindir=$HOME/eclipse-workspace/test-build/   # En sondaki / olsa da olmasa da sorun yok.

# get "data size" from console:
while getopts d: flag   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        d) ds=${OPTARG};;
    esac
done

# QUERY SET characteristics:
export qs=100
export query_loc_dist=u  # QUERY location distribution: uniform of gaussian, u or g
# AQAR = qx/qy changes from [0.1, 0.3, 0.7, 1, 1.428, 3.33, 10 ]
# QUERY AREA = Example:  Alan = 16e-4  ==> 0.04 * 0.04   
export qx=0.08
export qy=0.08


# CHANGE THE FOLLOWING ONLY IF NEW INDEX HAS BEEN LOADED !!..
# DO NOT TOUCH FOLLOWING !!! the following MUST MATCH already exist "data&index" characteristics:  (Indexes should have been loaded before.)

export ds
export data_loc_dist=u    # DATA LOC. dist.
#POINT DATA:
export dx=0
export dy=0
#REGION:
#export dx=0.01
#export dy=0.01
export d_dist=f     # DATA EXTENT dist.

export capacity=92
export fillfactor=0.999   # used in only bulk loading
export treeprefix=tree${ds}_${data_loc_dist}_${dx}_${dy}_${d_dist}_${capacity}
      
      
      

# construct related directories s.a data, database/ds, plt inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
export querydir=$HOME/eclipse-workspace/test-build/query

export qpostfix=${qs}_${query_loc_dist}_${qx}_${qy}
export queryfile=${querydir}/query${qpostfix}

export dbdir=$HOME/eclipse-workspace/test-build/database/${ds}  # already exist before..

mkdir -p $HOME/eclipse-workspace/test-build/plt   # Already exists.. -p flag: mk dir only if dir does not exist.
export pltdir=$HOME/eclipse-workspace/test-build/plt

mkdir -p $HOME/eclipse-workspace/test-build/results
export resultsdir=$HOME/eclipse-workspace/test-build/results


$SCRIPT_PATH/run-QueryGen.sh    # sometime, . at the beginning makes all exports global in the current shell.
$SCRIPT_PATH/run-QueryExecOnTrees.sh


