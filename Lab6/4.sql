select seq as gid,'road' as name,geom 
from pgr_dijkstra(
'select id,source,target,len as cost from road' ,13083,5846,false) as path
join road on path.edge=road.id

--紫金港 玉泉
select seq as gid,'road' as name,geom 
from pgr_dijkstra(
'select id,source,target,len as cost from road
where id<>4298 and id<>2659' ,13083,5846,false) as path
join road on path.edge=road.id

select *from road
where id=2658 or id=2659

select *from road
where source=2269 or target=2269

select seq as gid,'road' as name,geom 
from pgr_dijkstra(
'select id,source,target,len as cost from road' ,13083,13516,false) as path
join road on path.edge=road.id

select ta
from 
(
	
)

--2267是2658这条路的终点
select *
from pgr_dijkstra(
'select id,source,target,len as cost from road
where id<>2659 and id<>5863',
2267,13516,false) as path
join road on path.edge=road.id