 drop table if exists T1; drop table if exists T2;drop table if exists T3;
 create table T1 (A int, B int); create table T2 (B int, C int); create table T3 (A int, D int);
 insert into T1 values (2,1);
 insert into T2 values (1,3);
 insert into T3 values (3,4);
 select * from (T1 full outer join T2) full outer join T3;
 select * from T1 full outer join (T2 full outer join T3);