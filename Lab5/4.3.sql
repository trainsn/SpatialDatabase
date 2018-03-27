create or replace function ST_PolygonContainPoint(g1 geometry, g2 geometry)
    returns boolean
as $$

declare 
    j int;
    pi geometry;
    pj geometry;
    xi float; xj float; yi float; yj float;
    x float; y float;
    polyCorners int;
    oddNodes bool;
    tempg geometry;
    boundary geometry;
    a float;b float; c float;
    dis float; t1 float;
  
begin
   if ST_GeometryType(g1) != 'ST_Polygon' or ST_GeometryType(g2) != 'ST_Point' then 
        return NULL; 
    end if; 

    oddNodes=false;

    boundary=ST_GeomBoundary(g1);
    /*tempg=st_geometryn(boudary,1);
    polyCorners=ST_NumPoints(tempg);
    for  i in 1..polyConrners*/
    --raise notice 'boundary'
    raise notice 'numgeometries=%',st_numgeometries(boundary);
    for  k in 1..st_numgeometries(boundary) loop
	    tempg=st_geometryn(boundary,k);
	    polyCorners=ST_NumPoints(tempg);
	    --j=polyCorners;	    
	    for i in 1..polyCorners-1 loop
		j=i+1;
		pi=st_pointn(tempg,i);pj=st_pointn(tempg,j);
		xi=st_x(pi);yi=st_y(pi);
		xj=st_x(pj);yj=st_y(pj);
		
		a=yi-yj;
		b=xj-xi;
		c=xi*yj-xj*yi;
		dis=ST_P2PDistance(xi,yi,xj,yj);
	
		--判断g2是否在线上,exterior ring->true inring->false
		raise notice 'a=% b=% c=%',a,b,c;
		x=st_x(g2);y=st_y(g2);
		raise notice 'x=% ,y=% atline=%',x,y,abs(a*x+b*y+c);
		if (abs(a*x+b*y+c)<1e-6) then 
			t1=dot(xj-xi,yj-yi,x-xi,y-yi)/dis;
			raise notice 't1=%',t1;
			if (t1>=0 and t1<=dis) then 
				/*if (k=1) then 
					return true;
				else*/ 
					return false;
				--end if;
			end if;
		end if;
		
		--x=st_x(g2);y=st_y(g2);
		if (((yi<y) and (yj>=y) 
		or (yj<y) and (yi>=y))
		and (xi<=x or xj<=x)) then 
			if (xi+(y-yi)/(yj-yi)*(xj-xi)<x) then
			  oddNodes=not oddNodes;
			 end if;
		end if; 	
	    end loop;
    end loop;    
    return oddNodes;
end;
	
$$ language plpgsql;

/*SELECT ST_PolygonContainPoint('Polygon((0 0, 2 0, 2 2, 0 2, 0 0),
 (0.1 0.1, 1 0.1, 1 1, 0.1 1, 0.1 0.1))'::geometry, 
 'Point(2 2)'::geometry),
  ST_Contains('Polygon((0 0, 2 0, 2 2, 0 2, 0 0), 
  (0.1 0.1, 1 0.1, 1 1, 0.1 1, 0.1 0.1))'::geometry, 'Point(2 2)'::geometry)*/
  SELECT ST_PolygonContainPoint('Polygon((-1 0, 0 1, 1 0, 0 -1, -1 0))'::geometry, 
  'Point(0 0)'::geometry),
   ST_Contains('Polygon((-1 0, 0 1, 1 0, 0 -1, -1 0))'::geometry, 
   'Point(0 0)'::geometry);
   SELECT ST_PolygonContainPoint('Polygon((-1 0, -1 2, 0 1, 1 2, 1 0,-1 0))'::geometry, 'Point(0.5 1)'::geometry), ST_Contains('Polygon((-1 0, -1 2, 0 1, 1 2, 1 0,-1 0))'::geometry, 'Point(0.5 1)'::geometry)
/*select st_numgeometries(ST_GeomBoundary('Polygon((0 0, 2 0, 2 2, 0 2, 0 0), 
(0.1 0.1, 1 0.1, 1 1, 0.1 1, 0.1 0.1))'::geometry));*/