create or replace function ST_NearestCinema(lat float,lon float) 
    returns integer
as $$
declare 
    nodeID int;
    cinema int[];road int[];
    rec record;
    i int;
    dis float; min float;
    roadans int; ans int; 
begin
	select ST_Location2Node(lat,lon) into nodeId
	from node;

	i=0;
	for rec in  
	   select id,ST_Location2Node(poi.lat,poi.lon) as roadID
	   from poi 	 
	   where name like '%%影%%' loop
		i=i+1;
		cinema[i]=rec.id;
		road[i]=rec.roadid;
	end loop;

	min=1000000000;
	for j in 1..i loop
		select agg_cost into dis
		from pgr_dijkstra(
		'select id,source,target,len as cost from road' ,nodeID,road[j],false)
		order by seq desc
		limit 1;

		if (dis)<min then
			min=dis;
			roadans=road[j];
		end if;
	end loop;

	select id into ans 
	from 
	(
		select id,ST_Location2Node(poi.lat,poi.lon) as roadID
		from poi 	 
		where name like '%%影%%'
	) as t  
	where roadid=roadans;
   
	return ans;
end;

$$ language plpgsql;

select ST_NearestCinema(30.3043168, 120.076331798)

select *
	from pgr_dijkstra(
	'select id,source,target,len as cost from road' ,1,100,false)
	order by seq desc
	limit 1

select ST_Location2Node(poi.lat,poi.lon)
	  from poi 	 
	  where name like '%%影%%' 
	  
select ST_Location2Node(poi.lat,poi.lon)
	from poi 	 
	where name like '%%影%%'

select * 
from road 
order by id
limit 100;