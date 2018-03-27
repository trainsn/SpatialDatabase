create or replace function ST_AABBequals(g1 geometry, g2 geometry)
    returns boolean
 as $$
declare
	xmin1 float;
	xmax1 float;
	ymin1 float;
	ymax1 float;
	xmin2 float;
	xmax2 float;
	ymin2 float;
	ymax2 float;
	txmin float;
	txmax float;
	tymin float;
	tymax float;
	inf float;

begin 
	inf=100000000;
	xmin1=inf; ymin1=inf; xmax1=-inf; ymax1=-inf;
	for i in 1..ST_NumGeometries(g1) loop
		select min(st_x(geom)) into txmin		
		from st_dumppoints(ST_GeometryN(g1,i));
		select max(st_x(geom)) into txmax
		from st_dumppoints(ST_GeometryN(g1,i));
		select min(st_y(geom)) into tymin
		from st_dumppoints(ST_GeometryN(g1,i));
		select max(st_y(geom)) into tymax
		from st_dumppoints(ST_GeometryN(g1,i));
		if (txmin<xmin1) then xmin1=txmin; end if;
		if (tymin<ymin1) then ymin1=tymin; end if;
		if (txmax>xmax1) then xmax1=txmax; end if;
		if (tymax>ymax1) then ymax1=tymax; end if;
	end loop;

	xmin2=inf; ymin2=inf; xmax2=-inf; ymax2=-inf;
	for i in 1..ST_NumGeometries(g2) loop
		select min(st_x(geom)) into txmin		
		from st_dumppoints(ST_GeometryN(g2,i));
		select max(st_x(geom)) into txmax
		from st_dumppoints(ST_GeometryN(g2,i));
		select min(st_y(geom)) into tymin
		from st_dumppoints(ST_GeometryN(g2,i));
		select max(st_y(geom)) into tymax
		from st_dumppoints(ST_GeometryN(g2,i));
		if (txmin<xmin2) then xmin2=txmin; end if;
		if (tymin<ymin2) then ymin2=tymin; end if;
		if (txmax>xmax2) then xmax2=txmax; end if;
		if (tymax>ymax2) then ymax2=tymax; end if;
	end loop;

	if ((xmin1=xmin2) and (ymin1=ymin2) and (xmax1=xmax2) and (ymax1=ymax2)) then 
		return true;
	end if;
	return false;
end;
$$ language plpgsql;

SELECT ST_AABBequals('Polygon((2 1, 3 0, 1 0, 2 1))'::geometry, 'Polygon((1 0, 3 0, 3 1, 1 1, 1 0))'::geometry),
 'Polygon((2 1, 3 0, 1 0, 2 1))'::geometry = 'Polygon((1 0, 3 0, 3 1, 1 1, 1 0))'::geometry