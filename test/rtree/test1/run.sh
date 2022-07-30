#! /bin/bash

# my execs:
bindir=$HOME/eclipse-workspace/test-build/

# construct related directories (i.e. data, query, database ..) inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
data=$HOME/eclipse-workspace/test-build/data/data

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
queries=$HOME/eclipse-workspace/test-build/query/queries

mkdir -p $HOME/eclipse-workspace/test-build/database;    # -p flag: mk dir only if dir does not exist.
tree=$HOME/eclipse-workspace/test-build/database/tree;

echo Generating dataset
$bindir/test-rtree-Generator 10000 100 > d
awk '{if ($1 != 2) print $0}' < d > $data
awk '{if ($1 == 2) print $0}' < d > $queries
rm -rf d

echo Creating new R-Tree
$bindir/test-rtree-RTreeLoad $data $tree 20 10NN

echo Querying R-Tree
$bindir/test-rtree-RTreeQuery $queries $tree 10NN > res
cat $data $queries > .t

echo Running exhaustive search
$bindir/test-rtree-Exhaustive .t 10NN > res2

echo Comparing results
sort -n res > a
sort -n res2 > b
if diff a b
then
echo "Same results with exhaustive search. Everything seems fine."
echo Results: `wc -l a`
rm -rf a b res res2 .t $tree.*
else
echo "PROBLEM! We got different results from exhaustive search!"
fi
