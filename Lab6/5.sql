create or replace function ST_GuideDirection(ids int[]) 
    returns void
as $$
declare 
	id1 int; test int; err int :=0;
	n int :=0;
	--p1st int;  p2st int; p1en int; p2en int;
	l1 int[];l2 int[];
	pi geometry; pj geometry;
	geom1 geometry; geom2 geometry;
	ptemp geometry;
	num1 int; num2 int;
	x1 float;x2 float; y1 float; y2 float; x3 float; y3 float;
	vx1 float;vx2 float; vy1 float; vy2 float;
	len1 float; len2 float;
	a float; b float; c float;
	guidep geometry;
	temp float;
	flag boolean;
begin
	--raise notice 'i''m here';
	foreach id1 in array ids loop
		n=n+1;
	end loop;

	drop table if exists guidepoints;
	create table guidepoints(
		type int,
		direction int,
		velocity int,
		geom geometry(point,4326),
		edgeid int
	);
	
	raise notice 'n=%',n;

	
	for test in 1..n-1 loop	
		select source into temp
		from road 
		where id=ids[test];
		l1[1]=temp;

		select target into temp
		from road 
		where id=ids[test];
		l1[2]=temp;
			
		select source into temp 
		from road
		where id=ids[test+1];
		l2[1]=temp;
			
		select target into temp 
		from road
		where id=ids[test+1];
		l2[2]=temp;

		--raise notice 'l1[1]=%,l1[2]=%,l2[1]=%,l2[2]=%',l1[1],l1[2],l1[1],l2[2];
	
		for i in 1..2 loop
			for j in 1..2 loop
				if (l1[i]=l2[j]) then 										
					select count(*)>=3 into flag
					from road
					where source=l1[i] or target=l1[i];

					--raise notice 'p1=%,p2=%,p2=%,p3=%',l1[3-i],l1[i],l2[j],l2[3-j];
				end if;
			end loop;
		end loop;
		
		if (flag) then 
			
			select st_npoints(geom) into num1
			from road
			where id=ids[test];

			select st_npoints(geom) into num2
			from road
			where id=ids[test+1];

			select geom into geom1
			from road
			where id=ids[test];

			select geom into geom2
			from road
			where id=ids[test+1];

			err=err+1;
			if (err=53 or err=54) then 
				raise notice 'err=%,geom1=%,geom2=%',err,st_astext(geom1),st_astext(geom2);
			end if;
			--获取p1,p2,p3三个点坐标
			for i in 1..num1 loop
				pi=st_pointn(geom1,i);
				for j in 1..num2 loop
					pj=st_pointn(geom2,j);					
					if (st_equals(st_astext(pi)::geometry,st_astext(pj)::geometry)and (i=1 or i=num1) and (j=1 or j=num2)) then	
						if (err=53 or err=54) then
							raise notice 'err=%,pi=%,pj=%',err,st_astext(pi),st_astext(pj);
						end if;					
						guidep=pi;
						--raise notice 'i=%,j=%',i,j;
						x2=st_x(pi); y2=st_y(pi);
						if (i=1) then 
							ptemp=st_pointn(geom1,2);
							x1=st_x(ptemp); y1=st_y(ptemp);
						end if;
						if (i=num1) then 
							ptemp=st_pointn(geom1,num1-1);
							--raise notice 'ptemp=%',st_astext(ptemp);
							x1=st_x(ptemp); y1=st_y(ptemp);
						end if;
						if (j=1) then 
							ptemp=st_pointn(geom2,2);
							x3=st_x(ptemp); y3=st_y(ptemp);
						end if;
						if (j=num2) then 
							ptemp=st_pointn(geom2,num2-1);
							x3=st_x(ptemp); y3=st_y(ptemp);
						end if;
					end if;				
				end loop;
			end loop;

			
			
			--raise notice 'x1=%,y1=%,x2=%,y2=%,x3=%,y3=%',x1,y1,x2,y2,x3,y3;
					
			len1=sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
			len2=sqrt((x3-x2)*(x3-x2)+(y3-y2)*(y3-y2));		
			vx1=(x2-x1)/len1; vy1=(y2-y1)/len1;
			vx2=(x3-x2)/len2; vy2=(y3-y2)/len2;
			--raise notice 'vx1=%,vy1=%,vx2=%,vy2=%',vx1,vy1,vx2,vy2;
			
			--由p1,p2构成第一条直线
			a=y1-y2;
			b=x2-x1;
			c=x1*y2-x2*y1;
			--raise notice 'a=% b=% c=%',a,b,c;

			--raise notice 'cos=%',abs(vx1*vx2+vy1*vy2);
			if (abs(vx1*vx2+vy1*vy2)<sqrt(0.5)) then 	
				--raise notice 'online%',a*x3+b*y3+c;
				if (a*x3+b*y3+c>0) then 
					insert into guidepoints(type,direction,geom,edgeid)
					values (2,1,guidep,ids[test+1]);
				else 
					insert into guidepoints(type,direction,geom,edgeid)
					values (2,2,guidep,ids[test+1]);
				end if;
			else 
				insert into guidepoints(type,direction,geom,edgeid)
				values (2,0,guidep,ids[test+1]);
			end if;
		end if;		
	end loop;
end;

$$ language plpgsql;

create or replace function test()
    returns int[]
as $$
declare 
	rec record;
	ans int[];
	i int :=0;
begin 
	for rec in 
	select road.id as gid,geom 
	from pgr_dijkstra(
	'select id,source,target,len as cost from road' ,13083,5846,false) as path
	join road on path.edge=road.id loop
		i=i+1;
		ans[i]=rec.gid;
	end loop;
	return ans;
end;
$$ language plpgsql;
select ST_GuideDirection(test());

/*select ST_GuideDirection(array[21212,21357,21358,21359,21360,21361,21408,21409,21383,21384,21385,21400,21399,21398,21594,
21471,21470,21469,21468,21467,21445,21444,21443,6634,6635,13318,13308,13307,13306,13305,14124,13303,13312,13313,14496,
14497,13228,13229,13230,13231,13232,5864,5863]);*/
select *
from guidepoints g
where geom not in (
	select geom
	from referenceguidepoints r )

select *
from guidepoints;

except
select *
from referenceguidepoints r 

select edgeid,st_astext(t1.geom) as geom1,st_astext(t2.geom) as geom2 from 
(select row_number() over() as rownum,*
from referenceguidepoints) t1
 right outer join 
(select row_number() over() as rownum,*
from guidepoints) t2
on st_equals(t1.geom,t2.geom)
--order by geom1;

select id,source,target,st_astext(geom) 
from road
where id=6326 or id=5375

select st_astext(geom) 
from node 
where id=4530

select st_astext(geom)
from referenceguidepoints
except 
select st_astext(geom)
from guidepoints;

select st_astext(geom)
from guidepoints
except
select st_astext(geom)
from referenceguidepoints

select st_astext(geom)
from guidepoints
group by st_astext(geom)
having count(st_astext(geom))>1;

