#!/bin/bash
# default shell is already bash

# get data size from console:
ds=$1
es=$2

echo Retrieve data from PGSQL
PGPASSWORD=mypg1 psql -h localhost -d nyc -U postgres -X -A -F' ' -w -t -c 'with nyc_ss as(SELECT gid, ST_X(geom) as xl, st_y(geom) as yl, ST_X(geom) as xh, st_y(geom) as yh FROM nyc_subway_stations ) select 1 as INSERT,nyc_ss.gid,xl,yl,xh,yh from nyc_ss' > datafile




