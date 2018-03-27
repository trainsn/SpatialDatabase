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
begin
	for i in array_lower(ids,1)..array_upper(ids,1) loop
		select source from road where id = ids[i] into source1;
		select target from road where id = ids[i] into target1;
		select source from road where id = ids[i+1] into source2;
		select target from road where id = ids[i+1] into target2;
		if source1=source2 then p2 = source1;  end if;
		if target1=source2 then p2 = source2;  end if;
		if target1=target2 then p2 = target1;  end if;
		if source1=target2 then p2 = target2;  end if;
		select geom into gp2 from node where id = p2;
		select node.geom  from node,road 
		where st_intersects(node.geom,road.geom) and st_distance(gp2,node.geom,true)>10
		and road.id = ids[i] 
		order by st_distance(gp2,node.geom,true)
		limit 1 
		into gp1;
		select node.geom  from node,road 
		where st_intersects(node.geom,road.geom) and st_distance(gp2,node.geom,true)>10 
		and road.id = ids[i+1]
		order by st_distance(gp2,node.geom,true)
		limit 1 
		into gp3;
		x1 = st_x(gp1);
		y1 = st_y(gp1);
		x2 = st_x(gp2);
		y2 = st_y(gp2);
		x3 = st_x(gp3);
		y3 = st_y(gp3);
		if (y1-y2)*x3+(x2-x1)*y3+x1*y2-x2*y1>0 and 
		((x2-x1)*(x3-x1)+(y3-y1)*(y2-y1))/sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))*sqrt((x3-x1)*(x3-x1)+(y3-y1)*(y3-y1))>sqrt(2)/2
		then insert into guidepoints values(2,1,null,gp1,ids[i]);
		else if (y1-y2)*x3+(x2-x1)*y3+x1*y2-x2*y1>0 and 
		((x2-x1)*(x3-x1)+(y3-y1)*(y2-y1))/sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))*sqrt((x3-x1)*(x3-x1)+(y3-y1)*(y3-y1))>sqrt(2)/2
		then insert into guidepoints values(2,2,null,gp1,ids[i]);
		else insert into guidepoints values(2,0,null,gp1,ids[i]);
		end if;
		end if;
	end loop;
end;
$$ language plpgsql;
with recursive x(path,cycle) as
(
	(select array[id],false
	from (select road.id
		from pgr_dijkstra('select id,source,target,len as cost from road', 13083,5864,false,false) as path1,
		pgr_dijkstra('select id,source,target,len as cost from road', 13083,5864,false,false) as path2,road
		where source = path1.id1 and target = path2.id1 and path1.id1<>path2.id1) as tmp)
	union
	(select x.path||tmp.id, tmp.id=any(path)
	from x,(select road.id
		from pgr_dijkstra('select id,source,target,len as cost from road', 13083,5864,false,false) as path1,
		pgr_dijkstra('select id,source,target,len as cost from road', 13083,5864,false,false) as path2,road
		where source = path1.id1 and target = path2.id1 and path1.id1<>path2.id1) as tmp
	where not cycle
	)
)
select st_guidedirection(path) from x;
select * from guidepoints;