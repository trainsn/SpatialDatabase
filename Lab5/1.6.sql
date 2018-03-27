create or replace function ST_LineIntersection(x1 float, y1 float, x2 float, y2 float, x3 float, y3 float, x4 float, y4 float) 
    returns geometry
as $$

declare 
    a float;b float;c float;
    d float;e float;
    t float;
    t1 float;
    t2 float;
    dis float;
    x float;y float;
    temp float;
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
		return 'GEOMETRYCOLLECTION EMPTY'::geometry;
	else 
		t1=dot(x2-x1,y2-y1,x3-x1,y3-y1)/dis;--the distance of p3
		t2=dot(x2-x1,y2-y1,x4-x1,y4-y1)/dis;--the distance of p4
		if ((t2>=0 and t2<=dis) and not (t1>=0 and t1<=dis)) then 
			temp=x3;x3=x4;x4=temp;
			temp=y3;y3=y4;y4=temp;
			temp=t1;t1=t2;t2=temp;
		end if;
		Raise Notice 't1=% t2=% dis=%',t1,t2,dis;
		if ((t1>=0 and t1<=dis) and (t2>=0 and t2<=dis)) then 
			return st_makeline(st_makepoint(x3,y3),st_makepoint(x4,y4));
		end if;
		if ((abs(t1)<1e-6 and t2<0) or (abs(t1-dis)<1e-6 and t2>dis)) then 
			return st_makepoint(x3,y3);
		end if;
		if ((t1>0 and t1<dis) and t2<0) then
			return st_makeline(st_makepoint(x1,y1),st_makepoint(x3,y3));
		end if;
		if ((t1>0 and t1<dis) and t2>dis) then
			return st_makeline(st_makepoint(x3,y3),st_makepoint(x2,y2));
		end if;		
		if ((t1<0 and t2>dis) or (t1>dis and t2<0)) then 
			return st_makeline(st_makepoint(x1,y1),st_makepoint(x2,y2));
		end if;
		
	end if ;
    else 
	t=e/d;
	if (t>=0 and t<=1) then
		x=x3+(x4-x3)*t;
		y=y3+(y4-y3)*t;
		t1=dot(x2-x1,y2-y1,x-x1,y-y1)/dis;
		if (t1>=0 and t1<=dis) then
			return st_makepoint(x,y);
		end if;
	end if;
    end if ;
    return 'GEOMETRYCOLLECTION EMPTY'::geometry;
end;
$$ language plpgsql;