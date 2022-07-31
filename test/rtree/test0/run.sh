#! /bin/bash

# Only sample data/query generation::

# my execs:
bindir=$HOME/eclipse-workspace/test-build/

# construct related directories (i.e. data, query, database ..) inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
data=$HOME/eclipse-workspace/test-build/data/data

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
queries=$HOME/eclipse-workspace/test-build/query/queries

echo Generating dataset
$bindir/test-rtree-Generator 10000 100 > d
awk '{if ($1 != 2) print $0}' < d > $data
awk '{if ($1 == 2) print $0}' < d > $queries
rm -rf d

