#!/bin/bash

# utku: Query Modes:  [intersection | 10NN | selfjoin | contains]
# 2>&1 : combines (or called redirect) standard error (stderr) with standard out (stdout)
# > r  : redirect output to file r with replacing r.  >> : redirect and append to file r.

# For Disk IO:
# Use awk '{if ($1 ~ /Reads/) print $2}' < r >> 1 
# For Latency:
# Use awk '{if ($1 ~ /Time/) print $9}' < r >> 1 

#echo $treename
#echo $treename_$aqar    --> bunu begenmedi..:<
#echo "$treename"_"$aqar"  -->bunu begendi. :>  
#echo ${treename}_${aqar}    -->bunu da begendi. :>


############## R*-tree: ##########################

echo ----------------  R*-tree -------------
treename=D_${treeprefix}
timestatsfile=1

for i in 0.1 0.3 0.7 1 1.4 3.3 10; do    
	aqar="$i";
	echo Querying $treename with ${queryfile}_$aqar;
	time ${bindir}/test-rtree-RTreeQuery ${queryfile}_${aqar} $dbdir/$treename intersection 2>r 1>$resultsdir/${treename}_${aqar};      #redirect cerr to 'r' AND redirect cout to results...file
	awk '{if ($1 ~ /Time/) print $9}' < r >> $timestatsfile;  
	rm -rf r;
	echo ----------------
	done

mv  $timestatsfile $pltdir  

echo ----------------

############   STR-tree    ##########################

echo ----------------  STR-tree ------------- 

treename=S_${treeprefix}_1
timestatsfile=2

for i in 0.1 0.3 0.7 1 1.4 3.3 10; do    
	aqar="$i";
	echo Querying $treename with ${queryfile}_$aqar;
	time ${bindir}/test-rtree-RTreeQuery ${queryfile}_${aqar} $dbdir/$treename intersection 2>r 1>$resultsdir/${treename}_${aqar};      #redirect cerr to 'r' AND redirect cout to results...file
	awk '{if ($1 ~ /Time/) print $9}' < r >> $timestatsfile;  
	rm -rf r;
	echo ----------------
	done

mv  $timestatsfile $pltdir

echo ----------------  

########   Adp STR-tree  ########################

echo ----------------  Adp-STR-tree -------------
 
timestatsfile=3
for i in 0.1 0.3 0.7 1 1.4 3.3 10; do    
	aqar="$i";
	treename=S_${treeprefix}_${aqar};
	echo Querying $treename with ${queryfile}_$aqar;
	time ${bindir}/test-rtree-RTreeQuery ${queryfile}_${aqar} $dbdir/$treename intersection 2>r 1>$resultsdir/${treename}_${aqar};      #redirect cerr to 'r' AND redirect cout to results...file
	awk '{if ($1 ~ /Time/) print $9}' < r >> $timestatsfile;  
	rm -rf r;
	echo ----------------
	done

mv  $timestatsfile $pltdir  
echo ----------------


##########   COMPARE the RESULTS for VALIDATION  ##############################

echo ----------------  VALIDATION -------------

echo Comparing *some* result sets like for aqar=0.1 or 0.3, ... 

sort -n $resultsdir/D_${treeprefix}_0.3 > a  #Dynamic
sort -n $resultsdir/S_${treeprefix}_1_0.3 > b  # STR
sort -n $resultsdir/S_${treeprefix}_0.3_0.3 > c  # Adaptive STR
if diff a b
then
echo "Same results with exhaustive search. Everything seems fine."
paste $SCRIPT_PATH/0 $pltdir/1 $pltdir/2 $pltdir/3 > $pltdir/RES
echo Results: `wc -l a`
rm -rf b 
else
echo "PROBLEM! We got different results from exhaustive search!"
fi

if diff a c
then
echo "Same results with exhaustive search. Everything seems fine."
rm -rf a c 
else
echo "PROBLEM! We got different results from exhaustive search!"
fi


cat $pltdir/1 $pltdir/2 $pltdir/3 | sort -n | head -1 > minY
cat $pltdir/1 $pltdir/2 $pltdir/3 | sort -n | tail -1 > maxY

echo minY
echo maxY
gnuplot -persist <<-EOFMarker
	set title "Query Exec. Latency's Sensitivity to AQAR (DS=$ds, Query Area=64e-4)"
	set xlabel "AQAR"
	set ylabel "Latency"
	set xrange[0.1:10]
	set yrange[${minY}-10:${maxY}+10]
	set logscale x 2                    # veriye göre 10, 2, 4 gibi oynamalar yaparak güzel şekil oluşturabilirsin..
	plot "~/eclipse-workspace/test-build/plt/RES" using 1:2 w lp title "R*tree", "~/eclipse-workspace/test-build/plt/RES" using 1:3 w lp title "STR-tree", "~/eclipse-workspace/test-build/plt/RES" using 1:4 w lp title "AdpSTR-tree"
EOFMarker


