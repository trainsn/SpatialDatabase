create or replace function ST_Path(sql text, startpoint integer)
    returns geometry
as $$
declare 
	cur1 refcursor; cur2 refcursor;
	rec1 record; rec2 record; recj record;
	j int;
	res geometry[];
begin
	/*select 2016 as gid, 'traveling path' as name, (ST_MakeLine(geom order by seq)) as geom 
from poi join
(select seq, id 
from pgr_tsp('select id, lon as x, lat as y from poi where name like ''%酒店''', 309)) as path
on poi.
where poi.id = path.id;*/
	open cur1 for 
	select poi.id as id,ST_Location2Node(lat,lon) as node
	from (select row_number() OVER (ORDER BY id) as rownum,id,lat,lon
	      from poi
	      where name like '%酒店'
	      ) as poi
	      join 
	      (select seq, id 
		from pgr_tsp(ST_DistanceMatrix
		(sql)::float8[], startpoint))
		as path
	      on poi.rownum=path.id+1;
	      
	open cur2 for 
	select poi.id as id,ST_Location2Node(lat,lon) as node
	from (select row_number() OVER (ORDER BY id) as rownum,id,lat,lon
	      from poi
	      where name like '%酒店'
	      ) as poi
	      join 
	      (select seq, id 
		from pgr_tsp(ST_DistanceMatrix
		(sql)::float8[], startpoint))
		as path
	      on poi.rownum=path.id+1;
	
	move cur2;
	j=0;
	loop		
		FETCH cur1 INTO rec1;
		EXIT WHEN NOT FOUND;
		FETCH cur2 INTO rec2;
		EXIT WHEN NOT FOUND;
		raise notice 'rec1.id=%',rec1.id;
		raise notice 'rec2.id=%',rec2.id;
		
		--选出每一次dijkstra所需要的路
		for recj in 
		select geom 
		from pgr_dijkstra(
		'select id,source,target,len as cost from road' ,rec1.node,rec2.node,false) as path
		join road on path.edge=road.id loop
			j=j+1;
			res[j]=recj.geom;
		end loop;
	end loop;

	return st_collect(res);

end;
$$ language plpgsql;


select 2016 as gid, 'traveling path' as name, 
ST_astext(st_path('select id, lon as x, lat as y from poi where name like ''%酒店''', 12)) as geom  

select geom 
		from pgr_dijkstra(
		'select id,source,target,len as cost from road' ,1,100,false) as path
		join road on path.edge=road.id
select geom, gid, name from (select row_number() OVER (ORDER BY id) as rownum,geom, id as gid, name from poi where name like '%酒店') as t where rownum=13

select path.id,poi.id as id,ST_Location2Node(lat,lon) as node
	from (select row_number() OVER (ORDER BY id) as rownum,id,lat,lon
	      from poi
	      where name like '%酒店'
	      ) as poi
	      join 
	      (select seq, id 
		from pgr_tsp(ST_DistanceMatrix
		('select id, lon as x, lat as y from poi where name like ''%酒店''')::float8[], 12))
		as path
	      on poi.rownum=path.id+1;