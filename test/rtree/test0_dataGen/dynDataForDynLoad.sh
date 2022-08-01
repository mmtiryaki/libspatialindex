#! /bin/bash

# Only sample data/query generation::
# Use with command line argumans like ./dynDataForDynLoad.sh -d10000
# Now you can use this data s.a.
#	RTreeLoad with the following args: data/data database/tree 20 10NN

# my execs:
bindir=$HOME/eclipse-workspace/test-build/

# construct related directories (i.e. data, query, database ..) inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
data=$HOME/eclipse-workspace/test-build/data/data

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
queries=$HOME/eclipse-workspace/test-build/query/queries

# get data size from console:
while getopts d: flag   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        d) ds=${OPTARG};
    esac
done

# If you want to generate data that contains add and deletes for dynamic R-tree:
echo Generating dataset for dynamic loading i.e sample adds and deletes
$bindir/test-rtree-Generator $ds 10 > d  # Run generator with no simulation. we will have only additions.
awk '{if ($1 != 2) print $0}' < d > $data   # this file contains adds and deletes
awk '{if ($1 == 2) print $0}' < d > $queries
rm -rf d
