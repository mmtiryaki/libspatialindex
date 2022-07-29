#! /bin/bash

# my execs:
bindir=$HOME/eclipse-workspace/test-build/

# construct related directories (i.e. data, query, database ..) inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
datadir=$HOME/eclipse-workspace/test-build/data

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
querydir=$HOME/eclipse-workspace/test-build/query

mkdir -p $HOME/eclipse-workspace/test-build/database;    # -p flag: mk dir only if dir does not exist.
dbdir=$HOME/eclipse-workspace/test-build/database;



echo Generating dataset
${bindir}/test-rtree-Generator 10000 100 > ${datadir}/mix

echo Creating new R-Tree and Querying
${bindir}/test-rtree-RTreeLoad ${datadir}/mix ${dbdir}/tree 20 intersection > res

echo Running exhaustive search
${bindir}/test-rtree-Exhaustive ${datadir}/mix intersection > res2

echo Comparing results
sort -n res > a
sort -n res2 > b
if diff a b
then
echo "Same results with exhaustive search. Everything seems fine."
echo Results: `wc -l a`
rm -rf a b res res2 tree.*
else
echo "PROBLEM! We got different results from exhaustive search!"
fi

