#!/bin/bash

echo Generating objects  #"Usage: ds data_loc_dist qs query_loc_dist d_dx d_dy d_dist q_dx q_dy q_dist"

#time ${bindir}/test-rtree-Generator $obj_type $ds $data_loc_dist $dx $dy $dxdy_dist > d

# For mixed data-query may be used below..
#awk '{if ($1 != 2) print $0}' < d > ${datafile}
#rm -rf d

# obj: data ? query
if [[ $obj_type == 'data' ]];
then
		time ${bindir}/test-rtree-Generator $obj_type $ds $loc_dist $dx $dy $dxdy_dist > $datafile
		####### DATA PLOTTING:
		if [[ $dx > 0 ]];
		then
			# plotting requires 4 edge points of MBR
			awk 'BEGIN {}
			{print $3," ",$4; print $5," ",$4; print $5," ",$6; }  # may combine the prints in the same line if you wish.
			{print $3," ",$6; print $3," ",$4; print ""}
			END{}' $datafile > ${pltdir}/pltdata
			#bash $SCRIPT_PATH/plotting/pltRegionData-draw.sh
			else
			awk 'BEGIN {}
			{print $3," ",$4}
			END{}' $datafile > ${pltdir}/pltdata
			#bash $SCRIPT_PATH/plotting/pltPointData-draw.sh
		fi

		# R*-tree Loading:
		treename=D_${treeprefix}
		echo Load R*-Tree $treename
		# 2>&1 : combines (or called redirect) standard error (stderr) with standard out (stdout)
		# > r  : redirect std output to file r with replacing r.  >> : redirect and append to file r.

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
		echo -------------

		####### DATA + IDX PLOTTING:
#		bash $SCRIPT_PATH/plotting/pltDataAndDynLevel0-draw.sh  # use point data it is better
		####### ONLY IDX PLOTTING:
		bash $SCRIPT_PATH/plotting/pltDynLevel0-draw.sh  # use point data it is better

		echo -------------

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
		####### DATA + IDX PLOTTING: here I select aqar=1 and aqar 0.1 here. there are others..
#		bash $SCRIPT_PATH/plotting/pltDataAndSTRLevel0-draw.sh  -d$ds -a1
#		bash $SCRIPT_PATH/plotting/pltDataAndSTRLevel0-draw.sh  -d$ds -a0.1
		
		####### ONLY IDX PLOTTING: here I select aqar=1 and aqar 0.1 here. there are others..
		bash $SCRIPT_PATH/plotting/pltSTRLevel0-draw.sh  -d$ds -a1
		bash $SCRIPT_PATH/plotting/pltSTRLevel0-draw.sh  -d$ds -a0.3
		echo -------------

else
		if [[ $dx > 0 ]];
		then
			aqarlist=(0.1 0.3 0.7 1 1.4 3.3 10)
			for i in "${aqarlist[@]}"; do 
				aqar="$i";
				${bindir}/test-rtree-Generator $obj_type $ds $loc_dist $dx $dy $aqar > d1;   
				# generate only queries..
				awk '{if ($1 == 2) print $0}' < d1 > ${queryfile}_${aqar};      
				rm -rf d1;
				awk 'BEGIN {}
				{print $3," ",$4; print $5," ",$4; print $5," ",$6; }  # may combine the prints in the same line if you wish.
				{print $3," ",$6; print $3," ",$4; print ""}
				END{}' ${queryfile}_${aqar} > ${pltdir}/pltquery_${aqar};
				# you may plot all for debug !
				# $SCRIPT_PATH/plotting/pltquery-draw.sh -d$ds -a$aqar
			done
			./run-QueryExecOnTrees.sh
		else
			echo "Only window queries expected.!!"
    		exit
		fi
#		$SCRIPT_PATH/plotting/pltquery-draw.sh -d$ds -a0.3
fi


echo -------------
# Later, you may plot data and query within bash. like
# $ ./pltRegiondata-draw.sh





