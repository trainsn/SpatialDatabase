create or replace function ST_P2LDistance(x1 float, y1 float, x2 float, y2 float,x3 float, y3 float) 
    returns float
as $$
declare 
   dispro float;len float;dis float;t float;
   d2 float;d3 float;res float;
begin
	t=dot(x3-x2,y3-y2,x1-x2,y1-y2)/ST_P2PDistance(x3,y3,x2,y2);
	len=ST_P2PDistance(x3,y3,x2,y2);
	dispro=ST_P2PDistance(x1,y1,x2+t*(x3-x2)/len,
	y2+t*(y3-y2)/len);--distance to project point
	Raise Notice 'dispro=% t=% len=%',dispro,t,len;
	if (t>len or t<0) then		
		d2=ST_P2PDistance(x1,y1,x2,y2);
		d3=ST_P2PDistance(x1,y1,x3,y3);
		Raise Notice 'd2=% d3=%',d2,d3;
		res=min(d2,d3);
		Raise Notice 'res=%',res;
		return res;
	else 
		return dispro;		
	end if;
end;

$$ language plpgsql;

select min(2,1);

SELECT ST_WP2LDistance('Point(20 20)'::geometry, 'LineString(0 0, 10 10)'::geometry), ST_Distance('Point(5 5)'::geometry, 'LineString(20 20, 10 10)'::geometry)