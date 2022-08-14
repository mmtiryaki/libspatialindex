#!/bin/bash

# NOTE(utku): You can not run this file standalone. 

echo Generating queryset  #"Usage: ds data_loc_dist qs query_loc_dist d_dx d_dy d_dist q_dx q_dy q_dist" 

#time ../../test-rtree-Generator $ds $data_loc_dist $qs $query_loc_dist $dx $dy $d_dist $qx $qy $q_dist > d
aqarlist=(0.1 0.3 0.7 1 1.4 3.3 10)
for i in "${aqarlist[@]}"; do 
	export aqar="$i";
	${bindir}/test-rtree-Generator 1 u $qs $query_loc_dist 0.1 0.1 f $qx $qy ${aqar}   > d1;   # 1 u .. 0.1 0.1 f is dummy
	# generate only queries..
	awk '{if ($1 == 2) print $0}' < d1 > ${queryfile}_${aqar};      
	rm -rf d1;
	awk 'BEGIN {}
	{print $3," ",$4; print $5," ",$4; print $5," ",$6; }  # may combine the prints in the same line if you wish.
	{print $3," ",$6; print $3," ",$4; print ""}
	END{}' ${queryfile}_${aqar} > ${pltdir}/pltquery${aqar};
	done

###### PLOTTING a sample query set: 
bash $SCRIPT_PATH/../pltquery-draw.sh -a0.3
echo -----------









