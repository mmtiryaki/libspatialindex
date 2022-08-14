#!/bin/bash

# NOTE(utku): You can not run this file standalone. This file is called from "run-GenerateDataAndLoadDyn-STR" in which "ds data_loc_dist qs ..." are set (i.e. exported). 
# ATTENTION: export x = 5  --> INCORRECT.   export x=5 is CORRECT 

echo Generating dataset  #"Usage: ds data_loc_dist qs query_loc_dist d_dx d_dy d_dist q_dx q_dy q_dist" 

time ${bindir}/test-rtree-Generator $ds $data_loc_dist 0 u $dx $dy $d_dist 0.1 0.1 f > d   # 0 u ... 0.1 0.1 f : dummy values..

awk '{if ($1 != 2) print $0}' < d > ${datafile}   
rm -rf d

# plotting requires 4 edge points of MBR
awk 'BEGIN {}
{print $3," ",$4; print $5," ",$4; print $5," ",$6; }  # may combine the prints in the same line if you wish.
{print $3," ",$6; print $3," ",$4; print ""}
END{}' ${datafile} > ${pltdir}/pltdata

####### PLOTTING: 
bash $SCRIPT_PATH/../pltdata-draw.sh

echo -------------
# Later, you may plot data and query within bash.
# test5/$ ./pltdata-draw.sh


