create or replace function ST_LineIntersection(g1 geometry, g2 geometry) 
    returns geometry
as $$
declare
	linei geometry;linej geometry;
	top int;
	temp geometry;	
	geomlist geometry[];

begin 
	if (ST_GeometryType(g1)!='ST_LineString') or (ST_GeometryType(g2)!='ST_LineString') then
		return null;
	end if;
	top=0;
	raise notice 'npoint=%',ST_NPoints(g1);
	for i in 1..ST_NPoints(g1)-1 loop
		linei=st_makeline(ST_PointN(g1,i),st_pointn(g1,i+1));
		for j in 1..ST_NPoints(g2)-1 loop
			linej=st_makeline(ST_PointN(g2,j),st_pointn(g2,j+1));
			temp=ST_wLineIntersection(linei,linej);
			top=top+1;
			geomlist[top]=temp;
		end loop;
	end loop;
	return ST_union(geomlist);
end;
$$ language plpgsql;

SELECT ST_Astext(st_reverse(ST_LineIntersection('LineString(4 4,0 0, 3 3)'::geometry, 'LineString(5 4, 1 1, 2 2)'::geometry))), 
ST_AsText(ST_Intersection('LineString(4 4,0 0, 3 3)'::geometry, 'LineString(5 4, 1 1, 2 2)'::geometry));
SELECT st_equals(ST_LineIntersection('LineString(4 4,0 0, 3 3)'::geometry, 'LineString(5 4, 1 1, 2 2)'::geometry),
ST_Intersection('LineString(4 4,0 0, 3 3)'::geometry, 'LineString(5 4, 1 1, 2 2)'::geometry));