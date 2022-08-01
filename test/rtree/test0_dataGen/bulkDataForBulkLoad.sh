#! /bin/bash

# Only sample data/query generation::
# Use with command line argumans like ./bulkDataForBuklLoad.sh -d10000
# Now you can use this data s.a.
#    RTreeBulkLoad with the following args:   data/data_for_bulk database/tree 92 0.99

# my execs:
bindir=$HOME/eclipse-workspace/test-build/

# construct related directories (i.e. data, query, database ..) inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
data_for_bulk=$HOME/eclipse-workspace/test-build/data/data_for_bulk

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
queries=$HOME/eclipse-workspace/test-build/query/queries

# get data size from console:
while getopts d: flag   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        d) ds=${OPTARG};
    esac
done


echo Generating dataset for bulk loading
$bindir/test-rtree-Generator $ds 0 > d  # Run generator with no simulation. we will have only additions.
awk '{if ($1 != 2) print $0}' < d > $data_for_bulk   # this file contains only additions
awk '{if ($1 == 2) print $0}' < d > $queries
rm -rf d

