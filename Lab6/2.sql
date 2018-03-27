/*select id, lon as x, lat as y,name
from poi where name like '%酒店'

select id, lon as x, lat as y,name
from poi where id=1;
select id, lon as x, lat as y from poi where name like ''%酒店''

select seq, id1, id2, round(cost::numeric, 2) AS cost
 from pgr_tsp('select id, lon as x, lat as y from poi where name like ''%酒店''', 309)*/

create or replace function ST_DistanceMatrix(sql text) 
    returns float[][]
as $$
declare 
	reci record;
	recj record;
	ans float[][];
	temp float;
	tarr float[][];
	i int;j int;
	pi int;pj int;
	n int;
begin
	
	i=0;j=0;

	/*ans=ARRAY[[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	];*/
	n=0;
	for reci in execute sql loop
	  n=n+1;
	end loop;
	ans = array_fill(0.0, ARRAY[n, n]);
	
	for reci in execute sql loop
           i=i+1;
           j=0;
	   for recj in execute sql loop
		j=j+1;
		--raise notice 'xi=%,yi=%',reci.x,reci.y;
		--raise notice 'xj=%,yj=%',recj.x,recj.y;
		pi=ST_Location2Node(reci.y,reci.x);
		pj=ST_Location2Node(recj.y,recj.x);
		--raise notice 'i=%,pi=%',i,pi;
		--raise notice 'j=%,pj=%',j,pj;

		if (i>j) then
			ans[i][j]=ans[j][i];
		else 
			if (pi<>pj) then 
				select agg_cost into temp
				from pgr_dijkstra(
				'select id,source,target,len as cost from road' ,
				pi
				,pj,false)
				order by seq desc
				limit 1;	
				--raise notice 'i=%,pi=%',i,ST_Location2Node(reci.y,reci.x);
				--raise notice 'j=%,pj=%',j,ST_Location2Node(recj.y,recj.x);
				--ans:=ans||array[array[0.0]];
				ans[i][j]=temp;
				--tarr[j]=temp;
				--tarr=array_append(tarr,temp);
				--raise notice'ans[%][%]=%',i,j,ans[i][j];
			else 
				temp=0;
				ans[i][j]=temp;
				--tarr=array_append(tarr,temp);
				--tarr[j]=0;
				--raise notice'ans[%][%]=%',i,j,ans[i][j];
			end if;
		end if;		
	   end loop;
	   --ans=ans||tarr;
	   --ans=array_cat(ans,tarr);
	end loop;
		
	return ans;
end;

$$ language plpgsql;


select ST_DistanceMatrix('select id, lon as x, lat as y from poi where id>=1 and id<=2');

select seq, id 
from pgr_tsp(ST_DistanceMatrix('select id, lon as x, lat as y,name
from poi where name like ''%酒店''')::float8[], 12)	

	

SELECT seq, id FROM pgr_tsp('{{0,1,2,3},{1,0,4,5},{2,4,0,6},{3,5,6,0}}'::float8[],1,2);

SELECT ARRAY[5,6] || ARRAY[[1,2],[3,4]];

select {{0,1,2,3},{1,0,4,5},{2,4,0,6},{3,5,6,0}}

select * 

select 2016 as gid, 'traveling path' as name, st_Astext((ST_MakeLine(geom order by seq))) as geom 
from poi, (select seq, id2 from pgr_tsp('select
 id, lon as x, lat as y from poi where name like ''%酒店''', 309)) as path
where poi.id = path.id2;