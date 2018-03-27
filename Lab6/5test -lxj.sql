drop table if exists guidepoints;
create table guidepoints
	(
		type int,
		direction int,
		velocity float,
		geom geometry,
		edgeid int
	);
create or replace function ST_GuideDirection(ids int[])
	returns void
as $$
declare 
    num1 int = 0;
    num3 int = 0;
    i int;
    j int;
    l1 geometry;
    l3 geometry;
    tmp geometry;
    min double precision = 0.0;
    counter int = 0;
    p2 int;
    source1 int;
    target1 int;
    source2 int;
    target2 int;
    x1 double precision;	
    x2 double precision;
    x3 double precision;
    y1 double precision;
    y2 double precision;
    y3 double precision;
    gp1 geometry;
    gp2 geometry;
    gp3 geometry;
    vx1 float;vx2 float; vy1 float; vy2 float;
    len1 float; len2 float;
    a float; b float; c float;
begin
	for i in array_lower(ids,1)..array_upper(ids,1) loop
	-------------------------------------------------------------------
		select source from road where id = ids[i] into source1;
		select target from road where id = ids[i] into target1;
		select source from road where id = ids[i+1] into source2;
		select target from road where id = ids[i+1] into target2;
		if source1=source2 then p2 = source1;  end if;
		if target1=source2 then p2 = source2;  end if;
		if target1=target2 then p2 = target1;  end if;
		if source1=target2 then p2 = target2;  end if;
		select geom into gp2 from node where id = p2;
		raise notice ' gp2=% ', st_astext(gp2);
		--找到可能的路口，两条路的公共点
	------------------------------------------------------------------
		select geom  
		from road 
		where  road.id = ids[i] 
		into l1;
		num1 = st_npoints(l1);	
		if st_pointn(l1,num1) = gp2 then 
			gp1 = st_pointn(l1,num1-1);
		end if;
		if st_pointn(l1,1) = gp2 then 
			gp1 = st_pointn(l1,2);
		end if;
		raise notice ' gp1=% ', st_astext(gp1);
		--获取p1的位置
	-------------------------------------------------------------------------

		select geom  
		from road 
		where  road.id = ids[i+1] 
		into l3;
		num3 = st_npoints(l3);
		raise notice 'num3=% ', num3;
		if st_pointn(l3,num3) = gp2 then 
			gp3 = st_pointn(l3,num3-1);
		end if;
		if st_pointn(l3,1) = gp2 then 
			gp3 = st_pointn(l3,2);
		end if;
		raise notice ' gp3=% ', st_astext(gp3);
		--获取p3的位置
	-------------------------------------------------------------------	
		x1 = st_x(gp1);
		y1 = st_y(gp1);
		x2 = st_x(gp2);
		y2 = st_y(gp2);
		x3 = st_x(gp3);
		y3 = st_y(gp3);
		a=y1-y2;
		b=x2-x1;
		c=x1*y2-x2*y1;
		raise notice 'a=% b=% c=%',a,b,c;
		
		len1=sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
		len2=sqrt((x3-x2)*(x3-x2)+(y3-y2)*(y3-y2));
		raise notice 'len1 = %', len1;
		raise notice 'len2 = %', len2;
			
		vx1=(x2-x1)/len1; vy1=(y2-y1)/len1;
		vx2=(x3-x2)/len2; vy2=(y3-y2)/len2;
		raise notice 'cos=%',abs(vx1*vx2+vy1*vy2);
		if (abs(vx1*vx2+vy1*vy2)<sqrt(0.5)) then 
				raise notice 'online%',a*x3+b*y3+c;
			if (a*x3+b*y3+c>0) then 
				insert into guidepoints(type,direction,geom,edgeid)
				values (2,1,gp1,ids[i]);
			else 
				insert into guidepoints(type,direction,geom,edgeid)
				values (2,2,gp1,ids[i]);
			end if;
		else 
			insert into guidepoints(type,direction,geom,edgeid)
			values (2,0,gp1,ids[i]);
			end if;
	/*	if (y1-y2)*x3+(x2-x1)*y3+x1*y2-x2*y1>0 and 
		abs(((x2-x1)*(x3-x1)+(y3-y1)*(y2-y1))/sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))*sqrt((x3-x1)*(x3-x1)+(y3-y1)*(y3-y1)))<sqrt(2)/2
		then insert into guidepoints values(2,1,null,gp1,ids[i+1]);
		else if (y1-y2)*x3+(x2-x1)*y3+x1*y2-x2*y1<0 and 
		abs(((x2-x1)*(x3-x1)+(y3-y1)*(y2-y1))/sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))*sqrt((x3-x1)*(x3-x1)+(y3-y1)*(y3-y1)))<sqrt(2)/2
		then insert into guidepoints values(2,2,null,gp1,ids[i+1]);
		else insert into guidepoints values(2,0,null,gp1,ids[i+1]);
		end if;
		end if;
		*/
	end loop;
end;
$$ language plpgsql;
----------------------------------------------------------------------------------
--用于生成数组的自设函数
create or replace function ST_patharray(sql text)
    returns int[]
as $$
declare
	mviews record;
	mview record;
	path int[];
	num int = 0;
	i int = 0;
begin
	for mviews in execute sql loop
		num = num+1;
	end loop;
	for mview in execute sql loop
		path[i] = mview.id;
		if i>=num then exit; end if;
		i = i+1;
		
	end loop;
	return path;
end;
$$ language plpgsql;
------------------------------------------------------------------------------------
select st_guidedirection(st_patharray('select road.id
		from pgr_dijkstra(''select id,source,target,len as cost from road'', 13083,5846,false,false) as path1,
		pgr_dijkstra(''select id,source,target,len as cost from road'', 13083,5846,false,false) as path2,road
		where source = path1.id1 and target = path2.id1 and path1.id1<>path2.id1'));
select * from guidepoints;