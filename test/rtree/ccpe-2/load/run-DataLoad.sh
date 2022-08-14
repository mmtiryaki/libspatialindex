#!/bin/bash

# utku: Query Modes:  [intersection | 10NN | selfjoin | contains]
# $datafile, ${ds}, ${data_loc_dist}, ${dx}, ${dy}, ${d_dist}"  has already been set..!

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


# Now, STR and Adp-STR Loading:
# the "same data set" is loaded into STR and Adpt-STR. But, Adp-STR is loaded based on AQAR, which is a workload characteristic.
aqarlist=(0.1 0.3 0.7 1 1.4 3.3 10)
for i in "${aqarlist[@]}"; do    # note that aqar=1 is the ordinary STR. Others are Adp-STR.
	aqar="$i";
	treename=S_${treeprefix}_"$i";
	if (( $(echo "$i == 1" |bc) )); then    # here the echo send expresion to bc library. It return 0 or 1. ((  )) converts it to true or false..
		echo Load STR R-Tree $treename;
	else
		echo Load Adp-STR R-Tree $treename;
	fi;

	time ${bindir}/test-rtree-RTreeBulkLoad $datafile ${dbdir}/$treename $page_size $cache_size $capacity $fillfactor 1 ${aqar} $pS $bP 2> r 1>${pltdir}/pltSTRLevel0_${aqar};  #redirect cerr to 'r' AND redirect cout to plt...file
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
done

####### PLOTTING:
bash $SCRIPT_PATH/../pltDynLevel0-draw.sh
bash $SCRIPT_PATH/../pltSTRLevel0-draw.sh
bash $SCRIPT_PATH/../pltSTRLevel0_0.3-draw.sh






