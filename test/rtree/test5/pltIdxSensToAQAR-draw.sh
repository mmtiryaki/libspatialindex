#!/bin/bash

# Run this file in bash with ./pltdata-draw.sh -d10000   i.e.

# get data size from console:
while getopts d: flag   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        d) ds=${OPTARG};;
    esac
done

cat $pltdir/1 $pltdir/2 $pltdir/3 | sort -n | head -1 > minY
cat $pltdir/1 $pltdir/2 $pltdir/3 | sort -n | tail -1 > maxY

gnuplot -persist <<-EOFMarker
	set title "Query Exec. Latency's Sensitivity to AQAR (DS=$ds, Query Area=64e-4)"
	set xlabel "AQAR"
	set ylabel "Latency"
	set xrange[0.1:10]
	set yrange[${minY}-10:${maxY}+10]
	set logscale x 2                    # veriye göre 10, 2, 4 gibi oynamalar yaparak güzel şekil oluşturabilirsin..
	plot "~/eclipse-workspace/test-build/plt/RES" using 1:2 w lp title "R*tree", "~/eclipse-workspace/test-build/plt/RES" using 1:3 w lp title "STR-tree", "~/eclipse-workspace/test-build/plt/RES" using 1:4 w lp title "AdpSTR-tree"
EOFMarker