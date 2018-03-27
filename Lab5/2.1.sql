create or replace function ST_AABBEnvelope(g geometry)
    returns geometry
as $$
declare 
    xmin float;
    xmax float;
    ymin float;
    ymax float;
    txmin float;
    txmax float;
    tymin float;
    tymax float;
    inf float;
    
begin
	inf=100000000;
	xmin=inf; ymin=inf; xmax=-inf; ymax=-inf;
	for i in 0..ST_NumGeometries(g) loop
		select min(st_x(geom)) into txmin		
		from st_dumppoints(ST_GeometryN(g,i));
		select max(st_x(geom)) into txmax
		from st_dumppoints(ST_GeometryN(g,i));
		select min(st_y(geom)) into tymin
		from st_dumppoints(ST_GeometryN(g,i));
		select max(st_y(geom)) into tymax
		from st_dumppoints(ST_GeometryN(g,i));
		if (txmin<xmin) then xmin=txmin; end if;
		if (tymin<ymin) then ymin=tymin; end if;
		if (txmax>xmax) then xmax=txmax; end if;
		if (tymax>ymax) then ymax=tymax; end if;
	end loop;
	raise notice 'xmin=% xmax=% ymin=% ymax=%',xmin,xmax,ymin,ymax;
	return st_makeenvelope(xmin,ymin,xmax,ymax);
end;

$$ language plpgsql;

SELECT ST_AsText(ST_AABBEnvelope('Point(10 10)'::geometry)), ST_AsText(ST_Envelope('Point(10 10)'::geometry))
