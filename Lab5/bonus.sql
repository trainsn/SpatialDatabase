DROP FUNCTION st_obbenvelope(geometry);
create or replace function ST_OBBEnvelope(g geometry )
    returns geometry
as $$

declare 
	 u float; v float;
	 exx float; eyy float; exy float;
	 a11 float; a12 float; a21 float; a22 float;
	 b11 float; b12 float; b21 float; b22 float;
	 x float; y float;
	 a float; b float; c float;
	 l1 float; l2 float;
	 np int;
	 pi geometry;
	 x1 float; y1 float;
	 x2 float; y2 float;
	 x3 float; y3 float;
	 x4 float; y4 float;
	 xmin float; ymin float;xmax float; ymax float;
	 len float;
	 str varchar(255);
	 geomlist geometry[];
	 line geometry;
	 --ret geometry;
	 si float;co float;
begin
	u=0;v=0;
	exx=0;eyy=0;exy=0;
	np=st_npoints(g);
	raise notice 'g=%',st_astext(g);
	select avg(st_x(geom)) into u
	from st_dumppoints(g);
	select avg(st_y(geom)) into v
	from st_dumppoints(g);
	select avg(st_x(geom)*st_x(geom)) into exx
	from st_dumppoints(g);
	select avg(st_y(geom)*st_y(geom)) into eyy
	from st_dumppoints(g);
	select avg(st_x(geom)*st_y(geom)) into exy
	from st_dumppoints(g);
		
	raise notice 'exx=% eyy=% exy=%',exx,eyy,exy;
	a11=exx-u*u;
	a12=exy-u*v;
	a21=exy-u*v;
	a22=eyy-v*v;
	raise notice 'a11=% a12=% a21=% a22=%',a11,a12,a21,a22;

	a=1;
	b=-(a11+a22);
	c=a11*a22-a12*a21;

	--l1,l2为特征值
	l1=(-b+sqrt(b*b-4*a*c))/(2*a);
	l2=(-b-sqrt(b*b-4*a*c))/(2*a);
	raise notice 'l1=% l2=%',l1,l2;

	--两个特征向量
	b11=l1-a11;
	b12=-a12;
	b21=-a21;
	b22=l1-a22;
	x1=b12;y1=b11; 
	if (x1=0) and (y1=0) then
		x1=1;
	end if;
	len=sqrt(x1*x1+y1*y1);
	x1=x1/len; y1=-y1/len;
	raise notice 'x1=% y1=%',x1,y1;

	b11=l2-a11;
	b12=-a12;
	b21=-a21;
	b22=l2-a22;
	x2=-b12;y2=b11; 
	if (x2=0) and (y2=0) then
		y2=1;
	end if;
	len=sqrt(x2*x2+y2*y2);
	x2=x2/len; y2=y2/len;
	raise notice 'x2=% y2=%',x2,y2;

	--raise notice 'b11=% b12=% b21=% b22=%',b11,b12,b21,b22;
	--转换到特征向量坐标系下并求边界值
	select min(dot(st_x(geom),st_y(geom),x1,y1)) into xmin
	from st_dumppoints(g);
	select max(dot(st_x(geom),st_y(geom),x1,y1)) into xmax
	from st_dumppoints(g);
	select min(dot(st_x(geom),st_y(geom),x2,y2)) into ymin
	from st_dumppoints(g);
	select max(dot(st_x(geom),st_y(geom),x2,y2)) into ymax
	from st_dumppoints(g);
	raise notice 'xmin=% ymin=% xmax=% ymax=%',xmin,ymin,xmax,ymax;
	--raise notice 'utrans=% vtrans=%',dot(u,v,x1,y1),dot(u,v,x2,y2);

	--转回原来的坐标系
	co=x1;si=y1;
	x1=dot(xmin,ymin,co,-si); y1=dot(xmin,ymin,si,co);
	geomlist[1]=st_makepoint(x1,y1);
	x2=dot(xmin,ymax,co,-si); y2=dot(xmin,ymax,si,co);
	geomlist[2]=st_makepoint(x2,y2);
	x3=dot(xmax,ymax,co,-si); y3=dot(xmax,ymax,si,co);
	geomlist[3]=st_makepoint(x3,y3);
	x4=dot(xmax,ymin,co,-si); y4=dot(xmax,ymin,si,co);
	geomlist[4]=st_makepoint(x4,y4);
	geomlist[5]=st_makepoint(x1,y1);

	raise notice 'x1=% y1=% x2=% y2=%',x1,y1,x2,y2;
	raise notice 'x3=% y3=% x4=% y4=%',x3,y3,x4,y4;
	if (x1=x2) and (x2=x3) and (x3=x4) and (y1=y2) and (y2=y3) and (y3=y4) then 
		return st_makepoint(x1,y1);
	end if;
	if ((x1=x2) and (y1=y2)) then
		return st_makeline(geomlist[1],geomlist[3]);
	end if;
	if ((x1=x3) and (y1=y3)) then
		return st_makeline(geomlist[2],geomlist[4]);
	end if;
	if ((x1=x4) and (y1=y4)) then
		return st_makeline(geomlist[2],geomlist[3]);	
	end if;				
	line=st_makeline(geomlist);
	raise notice 'line=%',line;--st_astext(line);
	return st_makepolygon(line);	
end;
	
$$ language plpgsql;

select st_astext(ST_OBBEnvelope( ST_GeomFromText('MultiPoint((3.7 1.7), (4.1 3.8), (4.7 2.9), (5.2 2.8), (6.0 4.0), (6.3 3.6), 
(9.7 6.3), (10.0 4.9), (11.0 3.6), (12.5 6.4))')));
select st_astext(ST_OBBEnvelope( ST_GeomFromText('MultiPoint((-1 1), (0 0), (2 3))')));
select st_astext(ST_OBBEnvelope( ST_GeomFromText('MultiPoint((-1 1),(0 0))')));
select st_astext(ST_OBBEnvelope( ST_GeomFromText('LineString(-1 1, 0 0, 2 3)')));
select st_astext(ST_OBBEnvelope( ST_GeomFromText('MultiPoint((-1 1))')));
select st_astext(ST_OBBEnvelope( ST_GeomFromText('MultiPoint((-1 1), (0 0), (0 1),(-1 0))')));
/*select st_astext(st_makepolygon(
'LINESTRING(4.0515819498733 0.820946046012217,
2.94134796040235 3.59684389471515,12.1483480971056 7.27922885625395,
13.2585820865766 4.50333100755101,4.0515819498733 0.820946046012217)'::geometry*/