#!/bin/bash  

echo ----------------  PLOTTING... -------------

gnuplot -persist <<-EOFMarker
	# set terminal pngcairo  transparent enhanced font "arial,10" fontscale 1.0 size 600, 400 
	# set output 'histograms.2.png'
	set boxwidth 0.9 absolute
	set style fill   solid 1.00 border lt -1
	set key fixed right top vertical Right noreverse noenhanced autotitle nobox
	set style histogram clustered gap 1 title textcolor lt -1
	set datafile missing '-'
	set style data histograms
	set xtics border in scale 0,0 nomirror rotate by -45  autojustify
	set xtics  norangelimit 
	set xtics   ()
	set title "Q Exec. Latencies Sensitivity to Data Volume (AQAR=${aqar},QueryArea=$area " 
	set xrange [ * : * ] noreverse writeback
	set x2range [ * : * ] noreverse writeback
	set yrange [ 0.000 : 500. ] noreverse writeback
	set y2range [ * : * ] noreverse writeback
	set zrange [ * : * ] noreverse writeback
	set cbrange [ * : * ] noreverse writeback
	set rrange [ * : * ] noreverse writeback
	NO_ANIMATION = 1
	## Last datafile plotted: "immigration.dat"
	## plot 'immigration.dat' using 6:xtic(1) ti col, '' u 12 ti ## col, '' u 13 ti col, '' u 14 ti col
	plot '$HOME/eclipse-workspace/test-build/plt/AllDSoutput' using 2:xtic(1) ti col, '' using 3 ti col, '' u 4 ti col
EOFMarker


