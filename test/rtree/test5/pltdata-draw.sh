#!/bin/bash

# Run this file in bash with ./pltdata-draw.sh -d10000   i.e.

# get data size from console:
while getopts d: flag   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        d) ds=${OPTARG};;
    esac
done

gnuplot -persist <<-EOFMarker
	set title "Data Set with $ds objects in Unit Area "  
	set xlabel "x"
	set ylabel "y"
	unset logscale x
	unset logscale y
	set xrange[0:1.2]
	set yrange[0:1.2]
	set grid
	set size square   
	set style line 1 lc rgb 'black' pt 7 pointsize 0.3   # unset style line 1
	plot "~/eclipse-workspace/test-build/plt/pltdata" using 1:2 w p title "point" ls 1  #-->> POINT data set
EOFMarker

#plot "pltdata" using 1:2 w l title "region" ls 2  #-->> Use this for REGION data set  

# Run this file with gnuplot>load "pltdata-draw"  --> Cannot run in this way of course..