#!/bin/bash

gnuplot -persist <<-EOFMarker
	set title "Leaf MBRs of STR-tree holding $ds objects"
	set xlabel "x"
	set ylabel "y"
	unset logscale x
	unset logscale y
	set xrange[${"xl"}:${"xh"}]
	set yrange[${"yl"}:${"yh"}]
	set grid
	set size square
	set style line 2 lc rgb 'black' linetype 1 lw 1  # unset style line 2
	plot "~/eclipse-workspace/test-build/plt/pltSTRLevel0" using 1:2 w l  title "Leaf-MBR" ls 2
EOFMarker

