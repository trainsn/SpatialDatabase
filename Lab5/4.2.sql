/*首先判断有没有线重合的情况，一票否决
然后判断有没有交点，交点必须是两个几何的其中一个边界的其中一个点
最后判断有没有相接的情况*/
create or replace function ST_LineTouches(g1 geometry, g2 geometry)
    returns boolean    
as $$

declare 
    p1 geometry;p2 geometry; p3 geometry;p4 geometry; 
    bdg1 geometry; bdg2 geometry;
    x1 float; x2 float; x3 float; x4 float;
    y1 float; y2 float; y3 float; y4 float;	
    a float;b float;c float;
    d float;e float;
    t float;
    t1 float;
    t2 float;
    dis float;
    x float;y float;
    temp float;
    flag int;
  
begin
   if ST_GeometryType(g1) != 'ST_LineString' or ST_GeometryType(g2) != 'ST_LineString' then 
        return NULL; 
    end if; 

  bdg1=ST_GeomBoundary(g1);
  bdg2=ST_GeomBoundary(g2);
  raise notice 'bdg1=% bdg2=%',st_astext(bdg1),st_astext(bdg2);	
  
  for i in 1..ST_NPoints(g1)-1 loop
      p1=ST_PointN(g1,i);p2=st_pointn(g1,i+1);
      x1=st_x(p1);x2=st_x(p2);
      y1=st_y(p1);y2=st_y(p2);
      a=y1-y2;
      b=x2-x1;
      c=x1*y2-x2*y1;      
      for j in 1..ST_NPoints(g2)-1 loop
         p3=ST_PointN(g2,j);p4=st_pointn(g2,j+1);
         x3=st_x(p3);x4=st_x(p4);
	 y3=st_y(p3);y4=st_y(p4);    
	    d=a*(x4-x3)+b*(y4-y3);
	    e=-a*x3-b*y3-c;
	    dis=ST_P2PDistance(x1,y1,x2,y2);
	    --Raise Notice '% %',d,e;
	    if (abs(d)<1e-6) then 
		if (abs(e)>=1e-6) then
			--return 'GEOMETRYCOLLECTION EMPTY'::geometry;
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
				--return st_makeline(st_makepoint(x3,y3),st_makepoint(x4,y4));
				raise notice 'Intersect';
				return false;
			end if;
			if ((abs(t1)<1e-6 and t2<0) or (abs(t1-dis)<1e-6 and t2>dis)) then 
				--return st_makepoint(x3,y3);
			end if;
			if ((t1>0 and t1<dis) and t2<0) then
				--return st_makeline(st_makepoint(x1,y1),st_makepoint(x3,y3));
				raise notice 'Intersect';
				return false;
			end if;
			if ((t1>0 and t1<dis) and t2>dis) then
				--return st_makeline(st_makepoint(x3,y3),st_makepoint(x2,y2));
				raise notice 'Intersect';
				return false;
			end if;		
			if ((t1<0 and t2>dis) or (t1>dis and t2<0)) then 
				--return st_makeline(st_makepoint(x1,y1),st_makepoint(x2,y2));
				raise notice 'Intersect';
				return false;
			end if;			
		end if ;
	     else 
		raise notice 'there is a point';
		t=e/d;
		x=x3+(x4-x3)*t;
		y=y3+(y4-y3)*t;
		raise notice 'x=% ,y=% t=%',x,y,t;

		t1=dot(x2-x1,y2-y1,x-x1,y-y1)/dis/dis;
		raise notice 't1=%  dis=%',t1,dis;
		
		if (t>1e-6 and t+1e-6<1) then			
						
			-- if it is all in the line
			if (t1>1e-6 and t1+1e-6<1) then
				return false;
			end if;
			--这里说明交点在g1头上，但需要判断是不是终点引起的			
			if (abs(t1)<1e-6 or abs(t1-1)<1e-6) then 
				flag=2;
				p3=ST_GeometryN(bdg2,1);
				x3=st_x(p3);y3=st_y(p3);
				p4=ST_GeometryN(bdg2,ST_NumGeometries(bdg2));
				x4=st_x(p4);y4=st_y(p4);
				raise notice 'x3=%,y3=%,x4=%,y4=%',x3,y3,x4,y4;
				if ((abs(x-x3)>1e-6) or (abs(y-y3)>1e-6) or x3 is null) and 
				((abs(x-x4)>1e-6) or (abs(y-y4)>1e-6) or x4 is null) then 
					flag=flag-1;
				end if;
				
				p3=ST_GeometryN(bdg1,1);
				x3=st_x(p3);y3=st_y(p3);
				p4=ST_GeometryN(bdg1,ST_NumGeometries(bdg1));
				x4=st_x(p4);y4=st_y(p4);
				raise notice 'x3=%,y3=%,x4=%,y4=%',x3,y3,x4,y4;
				if (abs(x-x3)>1e-6 or abs(y-y3)>1e-6 or x3 is null) and 
				((abs(x-x4)>1e-6) or (abs(y-y4)>1e-6) or x4 is null) then 
					flag=flag-1;
				end if;

				if flag=0 then 
					return false;
				end if;
			end if;			
		end if;
		--说明交点是在g2头上
		if (abs(t)<1e-6 or abs(t-1)<1e-6) and (t1>0 and t1<1) then 
			flag=2;
			p3=ST_GeometryN(bdg2,1);
			x3=st_x(p3);y3=st_y(p3);
			p4=ST_GeometryN(bdg2,ST_NumGeometries(bdg2));
			x4=st_x(p4);y4=st_y(p4);
			raise notice 'x3=%,y3=%,x4=%,y4=%',x3,y3,x4,y4;
			if ((abs(x-x3)>1e-6) or (abs(y-y3)>1e-6) or x3 is null) and 
			((abs(x-x4)>1e-6) or (abs(y-y4)>1e-6) or x4 is null) then 
				flag=flag-1;
			end if;
				
			p3=ST_GeometryN(bdg1,1);
			x3=st_x(p3);y3=st_y(p3);
			p4=ST_GeometryN(bdg1,ST_NumGeometries(bdg1));
			x4=st_x(p4);y4=st_y(p4);
			raise notice 'x3=%,y3=%,x4=%,y4=%',x3,y3,x4,y4;
			if (abs(x-x3)>1e-6 or abs(y-y3)>1e-6 or x3 is null) and 
			((abs(x-x4)>1e-6) or (abs(y-y4)>1e-6) or x4 is null) then 
				flag=flag-1;
			end if;

			if flag=0 then 
				return false;
			end if;
		end if;
		
	    end if ;   
      end loop;
  end loop;

  
  for i in 1..ST_NPoints(g1)-1 loop
	p1=ST_PointN(g1,i);p2=st_pointn(g1,i+1);
	raise notice 'g1 p1=% p2=%',st_astext(p1),st_astext(p2);
	x1=st_x(p1);x2=st_x(p2);
	y1=st_y(p1);y2=st_y(p2);
	a=y1-y2;
	b=x2-x1;
	c=x1*y2-x2*y1;
	dis=ST_P2PDistance(x1,y1,x2,y2);
	
	raise notice 'a=% b=% c=%',a,b,c;
	p3=ST_GeometryN(bdg2,1);
	x3=st_x(p3);y3=st_y(p3);
	raise notice 'x3=% ,y3=% atline=%',x3,y3,abs(a*x3+b*y3+c);
	if (abs(a*x3+b*y3+c)<1e-6) then 
		t1=dot(x2-x1,y2-y1,x3-x1,y3-y1)/dis;
		raise notice 't1=%',t1;
		if (t1>=0 and t1<=dis) then 
			return true;
		end if;
	end if;
	p3=ST_GeometryN(bdg2,ST_NumGeometries(bdg2));
	x3=st_x(p3);y3=st_y(p3);
	raise notice 'x3=% ,y3=% atline=%',x3,y3,abs(a*x3+b*y3+c);
	if (abs(a*x3+b*y3+c)<1e-6) then 
		t1=dot(x2-x1,y2-y1,x3-x1,y3-y1)/dis;
		raise notice 't1=%',t1;
		if (t1>=0 and t1<=dis) then 
			return true;
		end if;
	end if;
   end loop;

   for i in 1..ST_NPoints(g2)-1 loop
	p1=ST_PointN(g2,i);p2=st_pointn(g2,i+1);
	raise notice 'g2 p1=% p2=%',st_astext(p1),st_astext(p2);
	x1=st_x(p1);x2=st_x(p2);
	y1=st_y(p1);y2=st_y(p2);	
	--raise 'x1=% y1=% x2=% y2=%',x1,y1,x2,y2;
	a=y1-y2;
	b=x2-x1;
	c=x1*y2-x2*y1;
	dis=ST_P2PDistance(x1,y1,x2,y2);
	
	raise notice 'a=% b=% c=%',a,b,c;
	p3=ST_GeometryN (bdg1,1);
	x3=st_x(p3);y3=st_y(p3);
	
	
	raise notice 'x3=% ,y3=% atline=%',x3,y3,a*x3+b*y3+c;
	if (abs(a*x3+b*y3+c)<1e-6) then 
		t1=dot(x2-x1,y2-y1,x3-x1,y3-y1)/dis;
		raise notice 't1=%',t1;
		if (t1>=0 and t1<=dis) then 
			return true;
		end if;
	end if;
	p3=ST_GeometryN(bdg1,ST_NumGeometries(bdg1));
	x3=st_x(p3);y3=st_y(p3);
	raise notice 'x3=% ,y3=% atline=%',x3,y3,abs(a*x3+b*y3+c);
	if (abs(a*x3+b*y3+c)<1e-6) then 
		t1=dot(x2-x1,y2-y1,x3-x1,y3-y1)/dis;
		raise notice 't1=%',t1;
		if (t1>=0 and t1<=dis) then 
			return true;
		end if;
	end if;
   end loop;
  raise notice 'end';
  return false;
end;
	
$$ language plpgsql;

SELECT ST_LineTouches('LineString(0 0, 1 0)'::geometry, 'LineString(-1 1, 0 0 , 1 1)'::geometry), 
ST_Touches('LineString(0 0, 1 0)'::geometry, 'LineString(-1 1, 0 0 , 1 1)'::geometry);

/*SELECT ST_LineTouches('LineString(-1 0, 0 0 ,0 1)'::geometry, 
'LineString(0 -1, 0 0,1 0,0 1)'::geometry), 
ST_Touches('LineString(-1 0, 0 0 ,0 1)'::geometry, 
'LineString(0 -1, 0 0,1 0,0 1)'::geometry)*/