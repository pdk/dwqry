-- drill down to a single product
select
    year_number,
    month_number,
    product_name,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join date_dim 
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
inner join product_dim
on product_dim.product_dim_id = invoice_item_fact.product_dim_id
where product_name = 'Shiro Miso'
group by 1, 2, 3
order by 1, 2, 3
;

 year_number | month_number | product_name | item_count | sale_amount | shipping_weight 
-------------+--------------+--------------+------------+-------------+-----------------
        2017 |            7 | Shiro Miso   |         44 |     1847.56 |          1289.2
        2017 |            8 | Shiro Miso   |         69 |     2897.31 |          2021.7
        2017 |            9 | Shiro Miso   |         24 |     1007.76 |           703.2
(3 rows)

-- let's add a custom object, and relate it to products
create table custom_object (
    id bigserial not null primary key,
    cust_obj_value varchar(255) not null,
    product_dim_id bigint not null
);

-- adding in a single row related to an existing dimension is OK
insert into custom_object (cust_obj_value, product_dim_id)
values ('custom object value 1', 30);

-- same query as before, but now with the custom object joined in
select
    year_number,
    month_number,
    product_name,
    cust_obj_value,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join date_dim 
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
inner join product_dim
on product_dim.product_dim_id = invoice_item_fact.product_dim_id
left outer join custom_object 
on custom_object.product_dim_id = product_dim.product_dim_id
where product_name = 'Shiro Miso'
group by 1, 2, 3, 4
order by 1, 2, 3, 4
;

-- numbers are still correct, but we have a new column
 year_number | month_number | product_name |    cust_obj_value     | item_count | sale_amount | shipping_weight 
-------------+--------------+--------------+-----------------------+------------+-------------+-----------------
        2017 |            7 | Shiro Miso   | custom object value 1 |         44 |     1847.56 |          1289.2
        2017 |            8 | Shiro Miso   | custom object value 1 |         69 |     2897.31 |          2021.7
        2017 |            9 | Shiro Miso   | custom object value 1 |         24 |     1007.76 |           703.2
(3 rows)

-- how about if we omit the product, and just use the custom object value?
select
    year_number,
    month_number,
    cust_obj_value,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join date_dim 
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
inner join product_dim
on product_dim.product_dim_id = invoice_item_fact.product_dim_id
left outer join custom_object 
on custom_object.product_dim_id = product_dim.product_dim_id
where product_name = 'Shiro Miso'
group by 1, 2, 3
order by 1, 2, 3
;

-- this is still OK
 year_number | month_number |    cust_obj_value     | item_count | sale_amount | shipping_weight 
-------------+--------------+-----------------------+------------+-------------+-----------------
        2017 |            7 | custom object value 1 |         44 |     1847.56 |          1289.2
        2017 |            8 | custom object value 1 |         69 |     2897.31 |          2021.7
        2017 |            9 | custom object value 1 |         24 |     1007.76 |           703.2
(3 rows)

-- adding in a SECOND row related to a single dimension will double the results
insert into custom_object (cust_obj_value, product_dim_id)
values ('custom object value 2', 30);

-- exact same query as before, including product and custom object
select
    year_number,
    month_number,
    product_name,
    cust_obj_value,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join date_dim 
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
inner join product_dim
on product_dim.product_dim_id = invoice_item_fact.product_dim_id
left outer join custom_object 
on custom_object.product_dim_id = product_dim.product_dim_id
where product_name = 'Shiro Miso'
group by 1, 2, 3, 4
order by 1, 2, 3, 4
;

-- now our sales have doubled. this is incorrect.
 year_number | month_number | product_name |    cust_obj_value     | item_count | sale_amount | shipping_weight 
-------------+--------------+--------------+-----------------------+------------+-------------+-----------------
        2017 |            7 | Shiro Miso   | custom object value 1 |         44 |     1847.56 |          1289.2
        2017 |            7 | Shiro Miso   | custom object value 2 |         44 |     1847.56 |          1289.2
        2017 |            8 | Shiro Miso   | custom object value 1 |         69 |     2897.31 |          2021.7
        2017 |            8 | Shiro Miso   | custom object value 2 |         69 |     2897.31 |          2021.7
        2017 |            9 | Shiro Miso   | custom object value 1 |         24 |     1007.76 |           703.2
        2017 |            9 | Shiro Miso   | custom object value 2 |         24 |     1007.76 |           703.2
(6 rows)

-- contrast that with a breakdown by another dimension
select
    year_number,
    month_number,
    product_name,
    salesperson_email,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join date_dim 
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
inner join product_dim
on product_dim.product_dim_id = invoice_item_fact.product_dim_id
inner join salesperson_dim 
on salesperson_dim.salesperson_dim_id = invoice_item_fact.salesperson_dim_id
where product_name = 'Shiro Miso'
group by 1, 2, 3, 4
order by 1, 2, 3, 4
;

-- note how the amounts are correctly broken down here, not doubled
-- e.g. 713.83 + 587.86 + 545.87 = 1,847.56
 year_number | month_number | product_name |      salesperson_email       | item_count | sale_amount | shipping_weight 
-------------+--------------+--------------+------------------------------+------------+-------------+-----------------
        2017 |            7 | Shiro Miso   | genevold9@netvibes.com       |         17 |      713.83 |           498.1
        2017 |            7 | Shiro Miso   | nscrowton1j@statcounter.com  |         14 |      587.86 |           410.2
        2017 |            7 | Shiro Miso   | tpawelczyk8@usnews.com       |         13 |      545.87 |           380.9
        2017 |            8 | Shiro Miso   | ajorgensen1f@youku.com       |         15 |      629.85 |           439.5
        2017 |            8 | Shiro Miso   | cmacvayw@slideshare.net      |          1 |       41.99 |            29.3
        2017 |            8 | Shiro Miso   | dwinterflood1@altervista.org |         14 |      587.86 |           410.2
        2017 |            8 | Shiro Miso   | jgiacopiniu@bing.com         |         10 |      419.90 |           293.0
        2017 |            8 | Shiro Miso   | lclewes16@godaddy.com        |         15 |      629.85 |           439.5
        2017 |            8 | Shiro Miso   | rmayo3@webs.com              |         14 |      587.86 |           410.2
        2017 |            9 | Shiro Miso   | ewitherow1m@google.com.br    |          1 |       41.99 |            29.3
        2017 |            9 | Shiro Miso   | fpingstone23@netvibes.com    |          5 |      209.95 |           146.5
        2017 |            9 | Shiro Miso   | tongp@google.com.au          |         18 |      755.82 |           527.4
(12 rows)

-- same query as before, without product
select
    year_number,
    month_number,
    cust_obj_value,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join date_dim 
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
inner join product_dim
on product_dim.product_dim_id = invoice_item_fact.product_dim_id
left outer join custom_object 
on custom_object.product_dim_id = product_dim.product_dim_id
where product_name = 'Shiro Miso'
group by 1, 2, 3
order by 1, 2, 3
;

-- now it's very mysterious how/why the sales have doubled
 year_number | month_number |    cust_obj_value     | item_count | sale_amount | shipping_weight 
-------------+--------------+-----------------------+------------+-------------+-----------------
        2017 |            7 | custom object value 1 |         44 |     1847.56 |          1289.2
        2017 |            7 | custom object value 2 |         44 |     1847.56 |          1289.2
        2017 |            8 | custom object value 1 |         69 |     2897.31 |          2021.7
        2017 |            8 | custom object value 2 |         69 |     2897.31 |          2021.7
        2017 |            9 | custom object value 1 |         24 |     1007.76 |           703.2
        2017 |            9 | custom object value 2 |         24 |     1007.76 |           703.2
(6 rows)

