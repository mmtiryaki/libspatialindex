#!/bin/bash
# default shell is already bash

# NOTE:(UK) This file uses real data sets and load it into R*tree and STR-tree.
# sample usage: ...$./realDataLoad.sh nyc public nyc_subway_stations  -- $1: database  $2:schema $3:spatial-table

# my execs:
bindir=$HOME/eclipse-workspace/test-build/

# my source:
export SCRIPT_PATH="$HOME/git/libspatialindex/test/rtree"  # Here, do not use "~/git/...". It

capacity=92
fillfactor=0.999   # used in only bulk loading

# external sorting parameters:
export pS=10000  # Page size (RPB). Used in ext-sort
export bP=100    # buffer size (num of buffers). Used in ext-sort

# construct related directories s.a data, database/ds, plt inside test-build area in eclipse WS.
mkdir -p  $HOME/eclipse-workspace/test-build/data  # -p flag: mk dir only if dir does not exist.
datadir=$HOME/eclipse-workspace/test-build/data

datafile="${datadir}/$3"

mkdir -p $HOME/eclipse-workspace/test-build/plt   # -p flag: mk dir only if dir does not exist.
pltdir=$HOME/eclipse-workspace/test-build/plt

mkdir -p $HOME/eclipse-workspace/test-build/database    # -p flag: mk dir only if dir does not exist.
dbdir=$HOME/eclipse-workspace/test-build/database
treename=tree_$3

echo Retrieve meta-data from PGSQL
# assume postgis module is loaded in public schema by default.
geomtype=$(PGPASSWORD=mypg1 PGOPTIONS=--search_path=public psql -h localhost -d $1 -U postgres -X -A -F' ' -w -t -c "
select gc.type from geometry_columns gc where gc.f_table_name = "\'$3\')

echo Retrieve data from PGSQL
# e/t in "if else..." format is important. [[ x == y ]];  --> valid.    [[x == y ]];  --> invalid.   i.e.
# For more clarifications, look at My PostGIS scripts/ 05-GenerateMBRdiagonals.sql
# ASSUME in spatial tables, we always have "gid" and "geom" attributes !!!!
# to access tables in other schemas, tried PGOPTIONS=--search_path=public. But is not working. thus I used "$2"."$3"  :<
if [[ $geomtype == POINT ]];
then
	PGPASSWORD=mypg1 PGOPTIONS=--search_path=public psql -h localhost -d $1 -U postgres -X -A -F' ' -w -t -c "
	with tmp as(SELECT gid, ST_X(geom) as xl, st_y(geom) as yl, ST_X(geom) as xh, st_y(geom) as yh FROM "$2"."$3")
	select 1 as INSERT,gid,xl,yl,xh,yh, min(xl) over() as minx,min(yl) over() as miny,max(xh) over() as maxx,max(yh) over() as maxy from tmp" > t
#elif [[ $geomtype == MULTIPOLYGON ]] || [[ $geomtype == POLYGON ]]; handle all other cases like polyline  similarly..
else
	PGPASSWORD=mypg1 PGOPTIONS=--search_path=public psql -h localhost -d $1 -U postgres -X -A -F' ' -w -t -c "
	with tmp1 as (
		select t.gid as gid, st_envelope(t.geom) as geom
		from "$2"."$3" t
		where st_numgeometries(t.geom)=1   -- ignore multiple polygons (or polylines).
    ),
	tmp2 as(
		select 1 as INSERT,tmp1.gid,  -- 1 means INSERT in libspatialindex.
		st_X(st_geometryN(st_points(tmp1.geom),1)) as xl,  st_y(st_geometryN(st_points(tmp1.geom),1)) as yl,  -- left-bottom (x,y )
    	st_X(st_geometryN(st_points(tmp1.geom),3)) as xh,  st_y(st_geometryN(st_points(tmp1.geom),3)) as yh  -- left-bottom (x,y )
		from tmp1
		where st_geometrytype(tmp1.geom) ilike 'ST_Polygon'  -- discard degenerate cases like vertical, horizontal polylines..
		order by 2
	)
	select \"insert\",gid, xl,yl,xh,yh, min(xl) over() as minx,min(yl) over() as miny,max(xh) over() as maxx,max(yh) over() as maxy from tmp2" >t
fi

awk '{print $1,$2,$3,$4,$5,$6 }' t > $datafile
minx=$(awk 'NR==1{print $7 }' t)
miny=$(awk 'NR==1{print $8 }' t)
maxx=$(awk 'NR==1{print $9 }' t)
maxy=$(awk 'NR==1{print $10 }' t)

rm -rf t

#pltdata may be generated here..!!
####### DATA PLOTTING: (Actually data objects's MBR PLOTTING, not object's itself.)
# (MULTI)POLYLINE icin de VT'dan MBR geldi. O yuzden POINT dısındaki her sey icin Region cizecegiz.
if [[ $geomtype == POINT ]];
	then
	awk 'BEGIN {}
	{print $3," ",$4}
	END{}' $datafile > ${pltdir}/pltdata
	$SCRIPT_PATH/plotting/pltPointData-draw.sh $minx $maxx $miny $maxy
else
	# plotting requires 4 edge points of MBR
	awk 'BEGIN {}
	{print $3," ",$4; print $5," ",$4; print $5," ",$6; }  # may combine the prints in the same line if you wish.
	{print $3," ",$6; print $3," ",$4; print ""}
	END{}' $datafile > ${pltdir}/pltdata
	bash $SCRIPT_PATH/plotting/pltRegionData-draw.sh $minx $maxx $miny $maxy 
fi




echo Load R*-Tree ${treename}_Dyn
# 2>&1 : combines (or called redirect) standard error (stderr) with standard out (stdout)
# > r  : redirect std output to file r with replacing r.  >> : redirect and append to file r.
#time ../../test-rtree-RTreeLoad $datafile $treename $capacity intersection > r 2>&1    # intersection is query type. But we are not sending any query!!

time ${bindir}/test-rtree-RTreeLoad $datafile ${dbdir}/$treename 1 100 $capacity intersection 1 2>r 1>${pltdir}/pltDynLevel0     #redirect cerr to 'r' AND redirect cout to plt...file
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
		  $1 ~ /Level/) print $0}' < r > ${dbdir}/${treename}_Dyn-Loading-Stats
rm -rf r
echo -------------

echo Load STR-Tree ${treename}_STR
time ${bindir}/test-rtree-RTreeBulkLoad $datafile ${dbdir}/$treename 1 100 $capacity $fillfactor 1 1 $pS $bP 2> r 1>${pltdir}/pltSTRLevel0;  #redirect cerr to 'r' AND redirect cout to plt...file
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
		  $1 ~ /Level/) print $0}' < r > ${dbdir}/${treename}_STR-Loading-Stats;
	rm -rf r;

	echo -------------

gnuplot -persist <<-EOFMarker
	set title "Leaf MBRs of R*-tree holding $3"
	set xlabel "x"
	set ylabel "y"
	unset logscale x
	unset logscale y
	set xrange[$minx:$maxx]
	set yrange[$miny:$maxy]
	unset xtics
	unset ytics
	set grid
	set size square
	#set style line 2 lc rgb 'black' linetype 1 lw 1  # unset style line 2
	plot "~/eclipse-workspace/test-build/plt/pltDynLevel0" using 1:2 w l  title "Leaf-MBR" lw 1
EOFMarker


gnuplot -persist <<-EOFMarker
	set title "Leaf MBRs of STR-tree holding $3"
	set xlabel "x"
	set ylabel "y"
	unset logscale x
	unset logscale y
	set xrange[$minx:$maxx]
	set yrange[$miny:$maxy]
	unset xtics
	unset ytics
	set grid
	set size square
	#set style line 2 lc rgb 'black' linetype 1 lw 1  # unset style line 2
	plot "~/eclipse-workspace/test-build/plt/pltSTRLevel0" using 1:2 w l  title "Leaf-MBR" lw 1
EOFMarker







