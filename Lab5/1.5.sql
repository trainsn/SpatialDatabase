create extension postgis;

select ST_P2PDistance(103.5, 200.4, 105.6, 200.7), 
       ST_Distance(ST_GeomFromText('Point(103.5 200.4)'), ST_GeomFromText('Point(105.6 200.7)'));


create or replace function ST_LineIntersects(x1 float, y1 float, x2 float, y2 float, x3 float, y3 float, x4 float, y4 float) 
    returns boolean
as $$
declare 
    a float;
    b float;
    c float;
    d float;
    e float;
    t float;
    t1 float;
    t2 float;
    dis float;
    x float;
    y float;
begin
    a=y1-y2;
    b=x2-x1;
    c=x1*y2-x2*y1;
    d=a*(x4-x3)+b*(y4-y3);
    e=-a*x3-b*y3-c;
    dis=ST_P2PDistance(x1,y1,x2,y2);
    Raise Notice '% %',d,e;
    if (abs(d)<1e-6) then 
        if (abs(e)>=1e-6) then
		return false;
	else 
		/*t1=(x3-x1)/(x2-x1);
		t2=(x4-x1)/(x2-x1);*/
		t1=dot(x2-x1,y2-y1,x3-x1,y3-y1)/dis;
		t2=dot(x2-x1,y2-y1,x4-x1,y4-y1)/dis;
		Raise Notice '% %',t1,t2;
		if ((t1>=0 and t1<=dis) or (t2>=0 and t2<=dis) or (t1<0 and t2>dis)) then
			return true;
		else 
			return false;
		end if ;
	end if ;
    else 
	t=e/d;
	if (t>=0 and t<=1) then
		x=x3+(x4-x3)*t;
		y=y3+(y4-y3)*t;
		t1=dot(x2-x1,y2-y1,x-x1,y-y1)/dis;
		if (t1>=0 and t1<=dis) then
			return true;
		else 
			return false;
		end if;
	else 
		return false;
	end if;
    end if ;
end;

$$ language plpgsql;

create or replace function ST_WLineIntersects(g1 geometry, g2 geometry)
    returns boolean
as $$
declare p1 geometry;
        p2 geometry;
        p3 geometry;
        p4 geometry;
begin
    if ST_GeometryType(g1) != 'ST_LineString' or ST_NumPoints(g1) != 2 or
       ST_GeometryType(g2) != 'ST_LineString' or ST_NumPoints(g2) != 2 then 
        return NULL; 
    end if;

    p1 = ST_PointN(g1, 1);
    p2 = ST_PointN(g1, 2);
    p3 = ST_PointN(g2, 1);
    p4 = ST_PointN(g2, 2);
    
    return ST_LineIntersects(ST_X(p1), ST_Y(p1), ST_X(p2), ST_Y(p2), ST_X(p3), ST_Y(p3), ST_X(p4), ST_Y(p4));
end;
$$ language plpgsql;

SELECT ST_WLineIntersects('LineString(12 12, 18 18)'::geometry, 'LineString(10 10, 20 20)'::geometry),
 ST_Intersects('LineString(12 12, 18 18)'::geometry, 'LineString(10 10, 20 20)'::geometry)
