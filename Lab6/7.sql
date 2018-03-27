create view CurrentTrack(carID, position, roadID) as 
select c.carid,position,id
from road,(select t1.carid,t1.position
		from track t1 join (select max(time) as maxtime,carid
				from track
				group by carid ) t2
		on t1.time=t2.maxtime and t1.carid=t2.carid) c	
where st_distance(geom,position)<=all
	(select st_distance(geom,position)
	from road r1,(select t1.carid,t1.position
		from track t1 join (select max(time) as maxtime,carid
				from track
				group by carid ) t2
		on t1.time=t2.maxtime and t1.carid=t2.carid) c1
	where c1.carid=c.carid)

select roadid,count(*) as num
from currenttrack
group by roadid
order by count(*) desc

CREATE OR REPLACE FUNCTION currenttrack_trigger()
RETURNS TRIGGER AS $$
BEGIN
	insert into track(carid,position) values(new.carid,new.position);
	RETURN null;
END;
$$ LANGUAGE plpgsql;

drop trigger if exists currenttrack_insert_trigger on currenttrack;
CREATE TRIGGER currenttrack_insert_trigger
instead of INSERT ON currenttrack 
FOR EACH ROW
EXECUTE PROCEDURE currenttrack_trigger();


