#!/bin/bash

# NOTE(utku): You can not run this file standalone. This file is called from "run-GenerateDataAndLoadDyn-STR" in which "ds data_loc_dist qs ..." are set (i.e. exported). 
# ATTENTION: export x = 5  --> INCORRECT.   export x=5 is CORRECT 

echo Generating dataset  #"Usage: ds data_loc_dist qs query_loc_dist d_dx d_dy d_dist q_dx q_dy q_dist" 

#time ${bindir}/test-rtree-Generator $obj_type $ds $data_loc_dist $dx $dy $dxdy_dist > d   

# For mixed data-query may be used below..
#awk '{if ($1 != 2) print $0}' < d > ${datafile}   
#rm -rf d

# obj: data ? query
if [[ $obj_type == 'data' ]]; 
then
currentfile=${datafile}
time ${bindir}/test-rtree-Generator $obj_type $ds $loc_dist $dx $dy $dxdy_dist > ${currentfile}   
else
currentfile=${queryfile}
time ${bindir}/test-rtree-Generator $obj_type $ds $loc_dist $dx $dy $dxdy_dist > $currentfile
fi

####### PLOTTING: 
if [[ $dx > 0 ]]; 
then
# plotting requires 4 edge points of MBR
awk 'BEGIN {}
{print $3," ",$4; print $5," ",$4; print $5," ",$6; }  # may combine the prints in the same line if you wish.
{print $3," ",$6; print $3," ",$4; print ""}
END{}' ${currentfile} > ${pltdir}/pltdata
#bash $SCRIPT_PATH/../plotting/pltRegionData-draw.sh
else
awk 'BEGIN {}
{print $3," ",$4} 
END{}' ${currentfile} > ${pltdir}/pltdata
#bash $SCRIPT_PATH/../plotting/pltPointData-draw.sh
fi

echo -------------
# Later, you may plot data and query within bash. like
# test5/$ ./pltRegiondata-draw.sh


# R*-tree Loading:
treename=D_${treeprefix}
echo Load R*-Tree $treename
# 2>&1 : combines (or called redirect) standard error (stderr) with standard out (stdout)
# > r  : redirect std output to file r with replacing r.  >> : redirect and append to file r.
#time ../../test-rtree-RTreeLoad $datafile $treename $capacity intersection > r 2>&1    # intersection is query type. But we are not sending any query!!

time ${bindir}/test-rtree-RTreeLoad $datafile ${dbdir}/$treename $page_size $cache_size $capacity intersection 1 2>r 1>${pltdir}/pltDynLevel0     #redirect cerr to 'r' AND redirect cout to plt...file
awk '{if ($1 ~ /Time/  ||
		  $1 ~ /TOTAL/ ||
		  $1 ~ /Buffer/ ||
		  $1 ~ /Fill/ ||
		  ($1 ~ /Index/ && $2 ~ /capacity/) ||
		  $1 ~ /Utilization/ ||
		  $1 ~ /Buffer/ ||
		  $2 ~ /height/ ||
		  $1 ~ /Number/ ||
		  $1 ~ /Read/||
		  $1 ~ /Write/||
		  $1 ~ /Level/) print $0}' < r > ${dbdir}/"${treename}-Loading-Stats"
rm -rf r
# mv already replaces..! do not need to remove old file. But moving takes time. don't
#mv  "${treename}.dat" "${treename}.idx" "${treename}-Loading-Stats" ${dbdir}/
echo -------------
####### PLOTTING:
bash $SCRIPT_PATH/../plotting/pltDataAndDynLevel0-draw.sh  # use point data it is better

echo -------------


 
treename=STR_${treeprefix};
echo Load R*-Tree $treename
time ${bindir}/test-rtree-RTreeBulkLoad $datafile ${dbdir}/$treename $page_size $cache_size $capacity $fillfactor 1 1 $pS $bP 2> r 1>${pltdir}/pltSTRLevel0_1;  #redirect cerr to 'r' AND redirect cout to plt...file
awk '{if ($1 ~ /Time/  ||
	  $1 ~ /TOTAL/ ||
	  $1 ~ /Buffer/ ||
	  $1 ~ /Fill/ ||
	  ($1 ~ /Index/ && $2 ~ /capacity/) ||
	  $1 ~ /Utilization/ ||
	  $1 ~ /Buffer/ ||
	  $2 ~ /height/ ||
	  $1 ~ /Number/ ||
	  $1 ~ /Read/||
	  $1 ~ /Write/||
	  $1 ~ /Level/) print $0}' < r > ${dbdir}/${treename}-Loading-Stats;
rm -rf r;
echo -------------
####### PLOTTING:
bash $SCRIPT_PATH/../plotting/pltDataAndSTRLevel0-draw.sh  # use point data it is better
echo -------------


