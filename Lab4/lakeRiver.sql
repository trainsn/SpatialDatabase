select distinct featurecla
from ne_10m_lakes;

select distinct featurecla
from ne_10m_rivers_lake_centerlines;

drop table if exists rivers;
create table rivers
(
  gid int,
  name varchar(255),
  geom geometry(multilineString,4326)
);	
insert into rivers(gid,name,geom)
select gid,name,st_setSRID(geom,4326)
from ne_10m_rivers_lake_centerlines
where featurecla='River';

select * from rivers;

drop table if exists lakes;
create table lakes
(
  gid int,
  name varchar(255),
  year int,
  featurecla varchar(32), 
  scalerank numeric, 
  geom_lake geometry(multiPolygon,4326), 
  geom_centreline geometry(multilineString,4326)
);	
insert into lakes(gid,name, year, featurecla, scalerank, geom_lake, geom_centreline)
select gid,name, year, featurecla, scalerank, geom_lake, geom_centreline
from 
(
	select gid,name,year,featurecla,scalerank,st_setSRID(geom,4326) as geom_lake
	from ne_10m_lakes
	where featurecla='Lake' or featurecla='Reservoir'
) t1
join 
(
	select /*name,featurecla,scalerank,*/st_setSRID(geom,4326) as geom_centreline
	from ne_10m_rivers_lake_centerlines
	where featurecla='Lake Centerline'
) t2
on st_crosses(t1.geom_lake,t2.geom_centreline);

select *
from rivers r1,rivers r2
where r1.gid=r2.gid and r1.name<>r2.name ;

select *
from rivers
order by name;

select *
from rivers r1,rivers r2
where r1.gid<>r2.gid and st_equals(r1.geom,r2.geom)=true;

select gid,name,geom_centreline as geom
from lakes
where name='Rybinsk Reservoir';

select * 
from lakes l1,lakes l2
where l1.name=l2.name and  l1.featurecla=l2.featurecla and 
(l1.year<>l2.year)
or l1.scalerank<>l2.scalerank)
/*l1.scalerank<>l2.scalerank
st_equals(l1.geom_centreline,l2.geom_centreline)=true*/

select * 
from lakes l1,lakes l2
where l1.name=l2.name and  l1.year=l2.year and 
(l1.featurecla<>l2.featurecla)

select * 
from lakes l1,lakes l2
where st_equals(l1.geom_lake,l2.geom_lake)
and (l1.gid<l2.gid);

select * 
from lakes l1,lakes l2 
where l1.=l2.gid and st_equals(l1.geom_centreline,l2.geom_centreline)=false;

select gid,count(year)
from lakes
group by gid
having 1<count(year);

select gid,count(featurecla)
from lakes
group by gid
having 1<count(featurecla);


drop table if exists lakeName;
create table lakeName
(
  name varchar(255),
  year int ,
  featurecla varchar(32),
  geom_lake geometry(multipolygon,4326)
);
insert into lakeName
select name,year,featurecla,geom_lake
from lakes;

drop table if exists lakes1;
create table lakes1
(
   gid int,
   scalerank numeric,
   geom_lake geometry(multipolygon,4326)
);
insert into lakes1
select gid,scalerank,geom_lake
from lakes;

drop table if exists lakeCentreline;
create table lakeCentreline
(
   gid int,
   geom_centreline geometry(multilinestring)
);
insert into lakeCentreline
select gid,geom_centreline
from lakes;

select * from lakeCentreline;

drop table if exists r;
create table r
(
   a int,
   b int,
   c int,
   d int 
);
insert into r values(1,2,3,4),
		(1,2,3,3),
		(1,5,3,6),
		(1,2,3,6),
		(1,5,3,4),
		(1,5,3,3);
		
select distinct r1.a,r2.b,r1.c,r1.d
from R r1,R r2
where 
(
   r1.a=r2.a and r1.c=r2.c 
   and (r1.b=r2.b and r1.d=r2.d)=false  
)
except 
select * 
from r;


