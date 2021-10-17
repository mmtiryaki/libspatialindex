#!/bin/bash  
# default shell is already bash

# NOTE:(UK) This file generates data set and load it into R*tree and STR-tree. 
# In case you wish to generate only data set and display it with gnuplot, then comment loading commands at the last 2 line.

# my source:
SCRIPT_PATH="$HOME/git/libspatialindex/test/rtree/test5/loadandRun/"  # Here, do not use "~/git/...". It does not work!

# my execs:
bindir=$HOME/eclipse-workspace/test-build/

# get WorkLoad-area and aqar and  from console:
while getopts r:a: flag   # r:area  a : aqar   
do
    case "${flag}" in
        r) area=${OPTARG};;
        a) aqar=${OPTARG};;
    esac
done

# data set:
data_loc_dist=u  # data location distribution: uniform or gaussian, u or g

# data extent: (point or region)
#export dx=0.01
#export dy=0.01
dx=0
dy=0
d_dist=f    # DATA EXTENT distribution: f or u: fixed size or uniformly distr.

# external sorting parameters:
pS=10000  # Page size (RPB). Used in ext-sort
bP=100    # buffer size (num of buffers). Used in ext-sort

capacity=92
fillfactor=0.999   # used in only bulk loading
treeprefix=tree${ds}_${data_loc_dist}_${dx}_${dy}_${d_dist}_${capacity}



# construct related directories s.a data, database/ds, plt inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
datadir=$HOME/eclipse-workspace/test-build/data 


mkdir -p $HOME/eclipse-workspace/test-build/plt   # -p flag: mk dir only if dir does not exist.
pltdir=$HOME/eclipse-workspace/test-build/plt


dslist=(10000 20000)  # data set sizes: 10K, 20K....100K
for i in "${dslist[@]}"; do    # note that aqar=1 is the ordinary STR. Others are Adp-STR.
	ds=$i;
	dpostfix=${ds}_${data_loc_dist}_${dx}_${dy}_${d_dist};
	datafile=${datadir}/data${dpostfix};
	treeprefix=tree${ds}_${data_loc_dist}_${dx}_${dy}_${d_dist}_${capacity}

	mkdir -p $HOME/eclipse-workspace/test-build/database/${ds};    # -p flag: mk dir only if dir does not exist.
	dbdir=$HOME/eclipse-workspace/test-build/database/${ds};

	echo Generating dataset;  #"Usage: ds data_loc_dist qs query_loc_dist d_dx d_dy d_dist q_dx q_dy q_dist" 
	time ${bindir}/test-rtree-Generator $ds $data_loc_dist 0 u $dx $dy $d_dist 0.1 0.1 f > d;   # 0 u ... 0.1 0.1 f : dummy values..

	awk '{if ($1 != 2) print $0}' < d > ${datafile};   
	rm -rf d;

	# plotting requires 4 edge points of MBR
	awk 'BEGIN {}
	{print $3," ",$4; print $5," ",$4; print $5," ",$6; }  # may combine the prints in the same line if you wish.
	{print $3," ",$6; print $3," ",$4; print ""}
	END{}' ${datafile} > ${pltdir}/pltdata;
	
	# Load R*-tree
	treename=D_${treeprefix}
	echo Load R*-Tree $treename;
	time ${bindir}/test-rtree-RTreeLoad $datafile ${dbdir}/$treename $capacity intersection 2>r 1>${pltdir}/pltDynLevel0;     #redirect cerr to 'r' AND redirect cout to plt...file
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
		  $1 ~ /Level/) print $0}' < r > ${dbdir}/"${treename}-Loading-Stats";
	rm -rf r;

	echo -------------;

	# Load STR-tree	 
	treename=S_${treeprefix}_1;
	echo Load STR R-Tree $treename;
	time ${bindir}/test-rtree-RTreeBulkLoad $datafile ${dbdir}/$treename $capacity $fillfactor 1 $pS $bP 2> r 1>${pltdir}/pltSTRLevel0_1;  #redirect cerr to 'r' AND redirect cout to plt...file
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

	echo -------------;

	# Load Adp-STR-tree	 
	treename=S_${treeprefix}_${aqar};
	echo Load STR R-Tree $treename;
	time ${bindir}/test-rtree-RTreeBulkLoad $datafile ${dbdir}/$treename $capacity $fillfactor ${aqar} $pS $bP 2> r 1>${pltdir}/pltSTRLevel0_${aqar};  #redirect cerr to 'r' AND redirect cout to plt...file
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

	echo -------------;
	done

# QUERYING
# remove the output if exists.
rm -rf $pltdir/AllDSoutput

qs=100
query_loc_dist=u  # QUERY location distribution: uniform of gaussian, u or g
# AQAR = qx/qy changes from [0.1, 0.3, 0.7, 1, 1.428, 3.33, 10 ]
# QUERY AREA = Example:  Alan = 16e-4  ==> 0.04 * 0.04   
qx=$(echo "sqrt($area)" |bc)
qy=$(echo "sqrt($area)" |bc)

mkdir -p  $HOME/eclipse-workspace/test-build/query  # -p flag: mk dir only if dir does not exist.
querydir=$HOME/eclipse-workspace/test-build/query

qpostfix=${qs}_${query_loc_dist}_${qx}_${qy}
queryfile=${querydir}/query${qpostfix}

mkdir -p $HOME/eclipse-workspace/test-build/results
resultsdir=$HOME/eclipse-workspace/test-build/results

echo Generating queryset  #"Usage: ds data_loc_dist qs query_loc_dist d_dx d_dy d_dist q_dx q_dy q_dist" 
${bindir}/test-rtree-Generator 1 u $qs $query_loc_dist 0.1 0.1 f $qx $qy ${aqar}   > d1   # 1 u .. 0.1 0.1 f is dummy
# generate only queries..
awk '{if ($1 == 2) print $0}' < d1 > ${queryfile}_${aqar}      
rm -rf d1
awk 'BEGIN {}
{print $3," ",$4; print $5," ",$4; print $5," ",$6; }  # may combine the prints in the same line if you wish.
{print $3," ",$6; print $3," ",$4; print ""}
END{}' ${queryfile}_${aqar} > ${pltdir}/pltquery${aqar}

for i in "${dslist[@]}"; do    # note that aqar=1 is the ordinary STR. Others are Adp-STR.
	ds=$i;
	dbdir=$HOME/eclipse-workspace/test-build/database/${ds};
	treeprefix=tree${ds}_${data_loc_dist}_${dx}_${dy}_${d_dist}_${capacity};
	
	treename=D_${treeprefix};
	echo Querying $treename with ${queryfile}_$aqar;
	time ${bindir}/test-rtree-RTreeQuery ${queryfile}_${aqar} $dbdir/$treename intersection 2>r 1>$resultsdir/${treename}_${aqar};      #redirect cerr to 'r' AND redirect cout to results...file
	#awk '{if ($1 ~ /Time/) print $9}' < r >> $timestatsfile;
	t1=$(awk '{if ($1 ~ /Time/) print $9}'< r);
	rm -rf r;
	echo ----------------;  
	
	treename=S_${treeprefix}_1;
	echo Querying $treename with ${queryfile}_$aqar;
	time ${bindir}/test-rtree-RTreeQuery ${queryfile}_${aqar} $dbdir/$treename intersection 2>r 1>$resultsdir/${treename}_${aqar};      #redirect cerr to 'r' AND redirect cout to results...file
	#awk '{if ($1 ~ /Time/) print $9}' < r >> $timestatsfile;  
	t2=$(awk '{if ($1 ~ /Time/) print $9}'< r);  
	rm -rf r;
	
	echo ----------------;
	
	treename=S_${treeprefix}_${aqar};
	echo Querying $treename with ${queryfile}_$aqar;
	time ${bindir}/test-rtree-RTreeQuery ${queryfile}_${aqar} $dbdir/$treename intersection 2>r 1>$resultsdir/${treename}_${aqar};      #redirect cerr to 'r' AND redirect cout to results...file
	#awk '{if ($1 ~ /Time/) print $9}' < r >> $timestatsfile;
	t3=$(awk '{if ($1 ~ /Time/) print $9}'< r);    
	rm -rf r;
	echo ----------------;
	
	echo ----------------  VALIDATION -------------;

	echo Comparing result sets like for given aqar;

	sort -n $resultsdir/D_${treeprefix}_$aqar > a;  #Dynamic
	sort -n $resultsdir/S_${treeprefix}_1_$aqar > b;  # STR
	sort -n $resultsdir/S_${treeprefix}_${aqar}_${aqar} > c;  # Adaptive STR
	if diff a b
	then
	echo "Same results with exhaustive search. Everything seems fine.";
	echo $ds $t1 $t2 $t3 >> $pltdir/AllDSoutput;
	echo Results: `wc -l a`;
	rm -rf b; 
	else	
	echo "PROBLEM! We got different results from exhaustive search!";
	fi;
	if diff a c
	then
	echo "Same results with exhaustive search. Everything seems fine.";
	rm -rf a c; 
	else
	echo "PROBLEM! We got different results from exhaustive search!";
	fi;
done


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
	set yrange [ 0.000 : 100. ] noreverse writeback
	set y2range [ * : * ] noreverse writeback
	set zrange [ * : * ] noreverse writeback
	set cbrange [ * : * ] noreverse writeback
	set rrange [ * : * ] noreverse writeback
	NO_ANIMATION = 1
	## Last datafile plotted: "immigration.dat"
	## plot 'immigration.dat' using 6:xtic(1) ti col, '' u 12 ti ## col, '' u 13 ti col, '' u 14 ti col
	plot '$pltdir/AllDSoutput' using 2:xtic(1) ti col, '' u 3 ti col, '' u 4 ti col, '' u 5 ti col, '' u 6 ti col, '' u 7 ti col, '' u 8 ti col, '' u 9 ti col
EOFMarker


