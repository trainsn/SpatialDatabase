CREATE OR REPLACE FUNCTION notify_trigger()
RETURNS TRIGGER AS $$
declare
	lastpos geometry;
	lasttime timestamp;
	id int;
	rec record;
	speed float;
BEGIN
	select  position into lastpos
	from track
	where carid=new.carid
	order by time desc
	limit 1; 

	select  time into lasttime
	from track
	where carid=new.carid
	order by time desc
	limit 1; 

	select carid into id
	from track 
	where carid=new.carid
	order by time desc
	limit 1;
	raise notice 'lastpos=% ,lasttime=%, carid=%',st_astext(lastpos),lasttime,id;

	for rec in 
	select *
	from guidepoints loop	
		rec.velocity=rec.velocity*4;	
		--raise notice 'dis1=%,dis2=%,time=%,carid=%',st_distance(lastpos,rec.geom,true),st_distance(rec.geom,new.position,true),new.time,id;
		if (st_distance(lastpos,rec.geom,true)>100 
		and st_distance(rec.geom,new.position,true)<100) then 
			raise notice 'dis1=%,dis2=%,time=%,carid=%',st_distance(lastpos,rec.geom,true),st_distance(rec.geom,new.position,true),new.time,id;			
			speed=ST_distance(lastpos,new.position,true)/EXTRACT(EPOCH FROM (new.time-lasttime))*3.6;
			raise notice 'speed=%',speed;
			if (speed<=rec.velocity*0.9) then
				insert into notifymessage
				values(new.time,id,'前方限速'||rec.velocity||'km/h');
			end if;
			if (speed>rec.velocity*0.9 and speed<=rec.velocity) then
				insert into notifymessage
				values(new.time,id,'前方限速'||rec.velocity||'km/h，当前车速'||speed||'km/h');
			end if;
			if (speed>rec.velocity) then
				insert into notifymessage
				values(new.time,id,'前方限速'||rec.velocity||'km/h，当前车速'||speed||'km/h，您已超速');
			end if;
		end if;
	end loop;
		
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

drop trigger notify_insert_trigger on track;
CREATE TRIGGER notify_insert_trigger
before INSERT ON track 
FOR EACH ROW
EXECUTE PROCEDURE notify_trigger();

delete from notifymessage;
delete from track;

insert into track values('2016-05-10 10:20:28', st_setsrid(ST_GeomFromText('point(120.104686575 30.283505885)'), 4326), 'Jack' , '101');
insert into track values('2016-05-10 10:20:29', st_setsrid(ST_GeomFromText('point(120.10475310 30.28328588)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:30', st_setsrid(ST_GeomFromText('point(120.104819625 30.283065875)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:31', st_setsrid(ST_GeomFromText('point(120.10488615 30.28284587)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:32', st_setsrid(ST_GeomFromText('point(120.104952675 30.282625865)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:33', st_setsrid(ST_GeomFromText('point(120.104819625 30.283065875)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:34', st_setsrid(ST_GeomFromText('point(120.104979285 30.282537863)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:35', st_setsrid(ST_GeomFromText('point(120.1049992425 30.2824718615)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:36', st_setsrid(ST_GeomFromText('point(120.10501920 30.28240586)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:37', st_setsrid(ST_GeomFromText('point(120.105045810 30.282317858)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:38', st_setsrid(ST_GeomFromText('point(120.105085725 30.282185855)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:39', st_setsrid(ST_GeomFromText('point(120.105125640 30.282053852)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:40', st_setsrid(ST_GeomFromText('point(120.105178860 30.281877848)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:41', st_setsrid(ST_GeomFromText('point(120.105218775 30.281745845)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:42', st_setsrid(ST_GeomFromText('point(120.105298605 30.281481839)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:43', st_setsrid(ST_GeomFromText('point(120.105378435 30.281217833)'), 4326), 'Jack', '101');
insert into track values('2016-05-10 10:20:29', st_setsrid(ST_GeomFromText('point(120.10475310 30.28328588)'), 4326), 'David', '102');
insert into track values('2016-05-10 10:20:30', st_setsrid(ST_GeomFromText('point(120.104779710 30.283197878)'), 4326), 'David', '102');
insert into track values('2016-05-10 10:20:29', st_setsrid(ST_GeomFromText('point(120.10475310 30.28328588)'), 4326), 'Tom', '103');
insert into track values('2016-05-10 10:20:30', st_setsrid(ST_GeomFromText('point(120.1047770490 30.2832066782)'), 4326), 'Tom', '103');
insert into track values('2016-05-10 10:20:29', st_setsrid(ST_GeomFromText('point(120.103880996283 30.2860733641809)'), 4326), 'Sally', '104');
insert into track values('2016-05-10 10:20:30', st_setsrid(ST_GeomFromText('point(120.1039895370264 30.28572229134472)'), 4326), 'Sally', '104');

/*select '2016-05-10 10:20:29'::timestamp-'2016-05-10 10:20:28'::timestamp;

select * from guidepoints;

select * from track;
delete from track;

select '前方限速'||1;*/