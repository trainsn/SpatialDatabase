drop table if exists basket;
create table basket
(
	tid serial,
	items char(255)
);

--copy basket(items) from 'e:\\basket_convert.txt';
copy basket(items) from 'e:\\basket.txt';