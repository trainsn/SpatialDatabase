create or replace function ST_P2LDistances(g1 geometry, g2 geometry) 
    returns float
as $$
declare
	temp geometry;
	ans float;inf float;
	dis float;

begin 
	inf=100000000;
	ans=inf;
	if (ST_GeometryType(g1)!='ST_Point') or (ST_GeometryType(g2)!='ST_LineString') then
		return null;
	end if;
	for i in 1..ST_NPoints(g2)-1 loop
		temp=st_makeline(ST_PointN(g2,i),st_pointn(g2,i+1));
		dis=ST_wP2LDistance(g1,temp);
		if (dis<ans) then 
			ans=dis;
		end if;
	end loop;
	return ans;
end;
$$ language plpgsql;

SELECT ST_P2LDistances('Point(0 0)'::geometry, 'LineString(1 1, 1 0, -1 0, -1 -1)'::geometry), ST_Distance('Point(0 0)'::geometry, 'LineString(1 1, 1 0, -1 0, -1 -1)'::geometry)