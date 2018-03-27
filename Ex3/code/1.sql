copy FlightTrack(code, date, latitude, longtitude, course, direction,height) 
from 'e:\\Tracklog.txt'
delimiter '#'
null 'NULL';

update FlightTrack A
set geom=
    ST_SetSRID(ST_MakePoint(B.latitude,B.longtitude),4326)
        from FlightTrack as B;
