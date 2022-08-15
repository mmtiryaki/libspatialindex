#!/bin/bash

# get data size from console:
while getopts d: flag   # you may add extra s.a. flags d:x:a:
do
    case "${flag}" in
        d) ds=${OPTARG};;
    esac
done

gnuplot -persist <<-EOFMarker
	set title "Data And Leaf MBRs of R*-tree holding $ds objects"
	set xlabel "x"
	set ylabel "y"
	unset logscale x
	unset logscale y
	set xrange[0:1.2]
	set yrange[0:1.2]
	set grid
	set size square
#	set style line 2 lc rgb 'black' linetype 1 lw 1  # unset style line 2
	plot "~/eclipse-workspace/test-build/plt/pltdata" using 1:2 w p title "point" ps 0.2 pt 15, "~/eclipse-workspace/test-build/plt/pltDynLevel0" using 1:2 w l  title "Leaf-MBR" dt 2
EOFMarker


# Run this file with gnuplot>load " ... "  --> Cannot run in this way of course..