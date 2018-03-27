create or replace function ST_GeomBoundary(geom geometry)
    returns geometry
as $$
declare
	ans geometry;
	tgeom geometry;
	tpoint geometry;
	stp geometry;enp geometry;
	ring geometry[];inring geometry;
	temp geometry;

begin 
	if (ST_GeometryType(geom)='ST_Point' or ST_GeometryType(geom)='ST_MultiPoint') then 
		return 'GEOMETRYCOLLECTION EMPTY'::geometry;
	end if;
	
	if (ST_GeometryType(geom)='ST_LineString' or  ST_GeometryType(geom)='ST_MultiLineString') then 
		ans='MULTIPOINT EMPTY'::geometry;
		for i in 1..ST_NumGeometries(geom) loop
			tgeom=ST_GeometryN(geom,i);
			stp=st_startpoint(tgeom);enp=st_endpoint(tgeom);
			--若ST和en有重叠，那么重叠部分去掉
			tpoint=st_union(st_difference(stp,st_intersection(stp,enp)),
			st_difference(enp,st_intersection(stp,enp)));	
			
			ans=st_union(st_difference(ans,st_intersection(ans,tpoint)),
			st_difference(tpoint,st_intersection(ans,tpoint)));			
		end loop;
		if (ans='GEOMETRYCOLLECTION EMPTY'::geometry) then 
			return 'MULTIPOINT EMPTY'::geometry;
		end if;
		return ans;
	end if;
	
	if (ST_GeometryType(geom)='ST_Polygon' or  ST_GeometryType(geom)='ST_MultiPolygon') then 
		ans='GEOMETRYCOLLECTION EMPTY'::geometry;
		for i in 1..ST_NumGeometries(geom) loop
			tgeom=ST_GeometryN(geom,i);
			ring[1]=ST_ExteriorRing(tgeom);
			raise notice 'ring=%',ST_AsText(ring[1]);
			for j in 1..ST_NumInteriorRings(tgeom) loop
				inring=ST_InteriorRingN(tgeom,j);
				raise notice 'inring=% j=%',ST_AsText(inring),j;
				ring[j+1]=inring;	
				--raise notice 'ring=%',ST_AsText(ring);
			end loop;
			temp=st_collect(ring);--temp代表当前geom的边界（包括内外边界)
			if (ans='GEOMETRYCOLLECTION EMPTY'::geometry)then
				ans=temp;
			else 
				ans=st_collect(st_difference(ans,st_intersection(ans,temp)),st_difference(temp,st_intersection(ans,temp)));
			end if;
			--ans=st_un(ans,temp);
			raise notice 'ans=% ,i=%',ST_AsText(ans),i;
		end loop;
		
		return ans;
	end if;
	return 'GEOMETRYCOLLECTION EMPTY'::geometry;
end;
$$ language plpgsql;

SELECT ST_AsText(ST_GeomBoundary('Polygon((10 50, 20 30, 40 60, 10 50),
(10 50, 20 30, 40 60, 10 50),(10 50, 20 30, 40 60, 10 50))'::geometry)),
 ST_AsText(ST_Boundary('Polygon((10 50, 20 30, 40 60, 10 50),
 (10 50, 20 30, 40 60, 10 50),(10 50, 20 30, 40 60, 10 50))'::geometry))

--select ST_NumGeometries(ST_GeomFromText('Polygon((10 50, 20 30, 40 60, 10 50),(10 50, 20 30, 40 60, 10 50),(10 50, 20 30, 40 60, 10 50))'))
