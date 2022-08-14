#!/bin/bash

# Run this file in bash with ./pltquery-draw.sh -a0.3   i.e.

# get query set size from console:
while getopts a: flag   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        a) qar=${OPTARG};;
    esac
done

gnuplot -persist <<-EOFMarker
	set title "Query Set with 100 query-regions in Unit Area"
	set xlabel "x"
	set ylabel "y"
	set xtics 0.1
	set ytics 0.1
	set grid
	set size square   
	unset logscale x
	unset logscale y
	set xrange[0:1.2]
	set yrange[0:1.2]
	set style line 1 lc rgb 'red' pt 7 pointsize 0.3   # unset style line 1
	plot "~/eclipse-workspace/test-build/plt/pltquery$qar" using 1:2 w l title "AQAR=$qar" ls 2

EOFMarker

# plot "~/eclipse-workspace/test-build/plt/pltquery0.1" using 1:2 w l title "AQAR=0.1" ls 2, "~/eclipse-workspace/test-build/plt/pltquery10" using 1:2 w l title "AQAR=10" ls 2 