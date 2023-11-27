drop view if exists load_invoice_item_fact_view;

drop table if exists invoice_item_fact_date_rollup;
drop table if exists invoice_item_fact_geo_rollup;
drop table if exists invoice_item_fact_salesperson_rollup;
drop table if exists invoice_item_fact_account_rollup;

drop table if exists invoice_item_fact_full_cube;
drop table if exists invoice_item_fact;
drop table if exists salesperson_dim;
drop table if exists account_geo_dim;
drop table if exists account_dim;
drop table if exists product_dim;
drop table if exists invoice_dim;
drop table if exists load_invoice_items;
drop table if exists load_invoices;
drop table if exists load_salespeople;
drop table if exists load_products;
drop table if exists load_accounts;
drop table if exists country_region_map;
drop table if exists date_dim;

create table date_dim (
    date_dim_id bigserial not null primary key,
    year_number numeric(4) not null,
    date_value date not null,
    month_number numeric(2) not null,
    month_name text not null,
    day_number numeric(2) not null,
    is_week_day boolean not null,
    is_holiday boolean not null,
    is_last_day_of_month boolean not null
);

insert into date_dim (
    date_value,
    year_number,
    month_number,
    month_name,
    day_number,
    is_week_day,
    is_holiday,
    is_last_day_of_month
)
select
  d.cur_date as date_value,
  extract(year from d.cur_date) as year_number,
  extract(month from d.cur_date) as month_number,
  to_char(d.cur_date, 'Mon') as month_name,
  extract(day from d.cur_date) as day_number,
  case
    when extract(isodow from d.cur_date) between 2 and 5
    then true
    else false
  end as is_week_day,
  case
    when d.cur_date = '2017-09-03'::date then true
    when d.cur_date = '2017-10-08'::date then true
    else false
  end as is_holiday,
  case
    when d.cur_date = (date_trunc('MONTH', d.cur_date) + INTERVAL '1 MONTH - 1 day')::DATE
    then true
    else false
  end as is_last_day_of_month
from (
    select '2017-07-01'::date + generate_series(0, 91) as cur_date
) d;

create table country_region_map (
    country text,
    region text,
    north_south text
);

copy country_region_map from '/Users/pkelly/home-stuff/src/dwqry/country-region-map.csv' delimiter ',' csv header;

create table load_accounts (
    Account_ID text,
    Name text,
    Phone text,
    Email text,
    Last_Year_Total_Sales numeric,
    Country text,
    State_Province text,
    City text
);

copy load_accounts from '/Users/pkelly/home-stuff/src/dwqry/accounts.csv' delimiter ',' csv header;

create table load_products (
    Product_ID text,
    Name text,
    Retail_Price numeric,
    Shipping_Weight numeric
);

copy load_products from '/Users/pkelly/home-stuff/src/dwqry/products.csv' delimiter ',' csv header;

create table load_salespeople (
    Salesperson_ID text,
    First_Name text,
    Last_Name text,
    Email text,
    Job_Title text
);

copy load_salespeople from '/Users/pkelly/home-stuff/src/dwqry/salespeople.csv' delimiter ',' csv header;

create table load_invoices (
    Invoice_Number numeric,
    Invoice_Date date,
    Account_ID text,
    Salesperson_ID text
);

copy load_invoices from '/Users/pkelly/home-stuff/src/dwqry/invoices.csv' delimiter ',' csv header;

create table load_invoice_items (
    Invoice_Number numeric,
    Product_ID text,
    Item_Count numeric,
    Sale_Price numeric
);

copy load_invoice_items from '/Users/pkelly/home-stuff/src/dwqry/invoice-items.csv' delimiter ',' csv header;

create table invoice_dim (
    invoice_dim_id bigserial not null primary key,
    invoice_number numeric not null default 0,
    constraint invoice_dim_unq unique (
        invoice_number
    )
);

insert into invoice_dim (
    invoice_number
)
select distinct invoice_number
from load_invoices;

create table product_dim (
    product_dim_id bigserial not null primary key,
    product_id text not null default 'N/A' ,
    product_name text not null default 'N/A',
    product_retail_price numeric not null default 0.00,
    product_shipping_weight numeric not null default 0.00,
    constraint product_dim_unq unique (
        product_id,
        product_name,
        product_retail_price,
        product_shipping_weight
    )
);

insert into product_dim (
    product_id,
    product_name,
    product_retail_price,
    product_shipping_weight
)
select
    Product_ID,
    Name,
    coalesce(Retail_Price, 0),
    coalesce(Shipping_Weight, 0)
from load_products;

create table account_dim (
    account_dim_id bigserial not null primary key,
    account_id text not null default 'N/A',
    account_name text not null default 'N/A',
    account_phone text not null default 'N/A',
    account_email text not null default 'N/A',
    account_last_year_total_sales numeric not null default 0,
    constraint account_dim_unq unique (
        account_id,
        account_name,
        account_phone,
        account_email,
        account_last_year_total_sales
    )
);

insert into account_dim (
    account_id,
    account_name,
    account_phone,
    account_email,
    account_last_year_total_sales
)
select distinct
    coalesce(account_id, 'N/A'),
    coalesce(name, 'N/A'),
    coalesce(phone, 'N/A'),
    coalesce(email, 'N/A'),
    coalesce(last_year_total_sales, 0)
from load_accounts;

create table account_geo_dim (
    account_geo_dim_id bigserial not null primary key,
    account_sales_region text not null default 'N/A',
    account_country text not null default 'N/A',
    account_state_province text not null default 'N/A',
    account_city text not null default 'N/A',
    constraint account_geo_dim_unq unique (
        account_geo_dim_id,
        account_sales_region,
        account_country,
        account_state_province,
        account_city
    )
);

insert into account_geo_dim (
    account_sales_region,
    account_country,
    account_state_province,
    account_city
)
select distinct
    coalesce(m.region, 'N/A') as sales_region,
    coalesce(a.country, 'N/A'),
    coalesce(a.state_province, 'N/A'),
    coalesce(a.city, 'N/A')
from load_accounts a
left outer join country_region_map m
on a.country = m.country;

create table salesperson_dim (
    salesperson_dim_id bigserial not null primary key,
    salesperson_id text not null default 'N/A',
    salesperson_first_name text not null default 'N/A',
    salesperson_last_name text not null default 'N/A',
    salesperson_email text not null default 'N/A',
    salesperson_job_title text not null default 'N/A',
    constraint salesperson_dim_unq unique (
        salesperson_id,
        salesperson_first_name,
        salesperson_last_name,
        salesperson_email,
        salesperson_job_title
    )
);

insert into salesperson_dim (
    salesperson_id,
    salesperson_first_name,
    salesperson_last_name,
    salesperson_email,
    salesperson_job_title
)
select distinct
    coalesce(salesperson_id, 'N/A'),
    coalesce(first_name, 'N/A'),
    coalesce(last_name, 'N/A'),
    coalesce(email, 'N/A'),
    coalesce(job_title, 'N/A')
from load_salespeople;

create table invoice_item_fact (
    date_dim_id bigint not null references date_dim,
    invoice_dim_id bigint not null references invoice_dim,
    account_dim_id bigint not null references account_dim,
    account_geo_dim_id bigint not null references account_geo_dim,
    product_dim_id bigint not null references product_dim,
    salesperson_dim_id bigint not null references salesperson_dim,
    item_count integer not null,
    sale_amount numeric not null,
    shipping_weight numeric not null,
    constraint invoice_item_fact_unq unique (
        date_dim_id,
        invoice_dim_id,
        account_dim_id,
        account_geo_dim_id,
        product_dim_id,
        salesperson_dim_id
    )
);


create view load_invoice_item_fact_view
as
with distinct_invoice_items as (
    select distinct on (invoice_number, product_id)
        *
    from load_invoice_items
    order by invoice_number, product_id, item_count
)
select
--  a.account_id,
 a.name as account_name,
 a.phone,
 a.email as account_email,
 a.last_year_total_sales,
coalesce(a.country, 'N/A') as country,
coalesce(a.state_province, 'N/A') as state_province,
coalesce(a.city, 'N/A') as city,
--  ii.invoice_number,
 ii.product_id,
 coalesce(ii.item_count, 0) as item_count,
 ii.sale_price,
 coalesce(ii.item_count * ii.sale_price, 0) as sale_amount,
 i.invoice_number,
 i.invoice_date,
 i.account_id,
 i.salesperson_id,
--  p.product_id,
 p.name as product_name,
 p.retail_price,
 coalesce(p.shipping_weight * ii.item_count, 0) as shipping_weight,
--  s.salesperson_id,
 s.first_name,
 s.last_name,
 s.email as salesperson_email,
 s.job_title
from load_invoices i
left outer join distinct_invoice_items ii
on i.invoice_number = ii.invoice_number
left outer join load_accounts a
on a.account_id = i.account_id
left outer join load_products p
on p.product_id = ii.product_id
left outer join load_salespeople s
on s.salesperson_id = i.salesperson_id
;



insert into invoice_item_fact (
    date_dim_id,
    invoice_dim_id,
    account_dim_id,
    account_geo_dim_id,
    product_dim_id,
    salesperson_dim_id,
    item_count,
    sale_amount,
    shipping_weight
)
select
    date_dim.date_dim_id,
    invoice_dim.invoice_dim_id,
    account_dim.account_dim_id,
    account_geo_dim.account_geo_dim_id,
    product_dim.product_dim_id,
    salesperson_dim.salesperson_dim_id,
    v.item_count,
    v.sale_amount,
    v.shipping_weight
from load_invoice_item_fact_view v
left outer join date_dim
on date_dim.date_value = v.invoice_date
left outer join invoice_dim
on invoice_dim.invoice_number = v.invoice_number
left outer join account_dim
on account_dim.account_id = v.account_id
left outer join account_geo_dim
on account_geo_dim.account_country = v.country
and account_geo_dim.account_state_province = v.state_province
and account_geo_dim.account_city = v.city
left outer join product_dim
on product_dim.product_id = v.product_id
left outer join salesperson_dim
on salesperson_dim.salesperson_id = v.salesperson_id
;

create table invoice_item_fact_full_cube
as
select
    date_dim.date_value,
    date_dim.month_number,
    date_dim.month_name,
    date_dim.is_week_day,
    date_dim.is_holiday,
    date_dim.is_last_day_of_month,
    account_dim.account_id,
    account_dim.account_name,
    account_dim.account_phone,
    account_dim.account_email,
    account_dim.account_last_year_total_sales,
    account_geo_dim.account_geo_dim_id,
    account_geo_dim.account_sales_region,
    account_geo_dim.account_country,
    account_geo_dim.account_state_province,
    account_geo_dim.account_city,
    invoice_dim.invoice_number,
    product_dim.product_id,
    product_dim.product_name,
    product_dim.product_retail_price,
    product_dim.product_shipping_weight,
    salesperson_dim.salesperson_id,
    salesperson_dim.salesperson_first_name,
    salesperson_dim.salesperson_last_name,
    salesperson_dim.salesperson_email,
    salesperson_dim.salesperson_job_title,
    invoice_item_fact.item_count,
    invoice_item_fact.sale_amount,
    invoice_item_fact.shipping_weight
from invoice_item_fact
inner join account_dim
on account_dim.account_dim_id = invoice_item_fact.account_dim_id
inner join account_geo_dim
on account_geo_dim.account_geo_dim_id = invoice_item_fact.account_geo_dim_id
inner join date_dim
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
inner join invoice_dim
on invoice_dim.invoice_dim_id = invoice_item_fact.invoice_dim_id
inner join product_dim
on product_dim.product_dim_id = invoice_item_fact.product_dim_id
inner join salesperson_dim
on salesperson_dim.salesperson_dim_id = invoice_item_fact.salesperson_dim_id;

create unique index invoice_item_fact_full_cube_unq on invoice_item_fact_full_cube (
    date_value,
    month_number,
    month_name,
    is_week_day,
    is_holiday,
    is_last_day_of_month,
    account_id,
    account_name,
    account_phone,
    account_email,
    account_last_year_total_sales,
    account_geo_dim_id,
    account_sales_region,
    account_country,
    account_state_province,
    account_city,
    invoice_number,
    product_id,
    product_name,
    product_retail_price,
    product_shipping_weight,
    salesperson_id,
    salesperson_first_name,
    salesperson_last_name,
    salesperson_email,
    salesperson_job_title,
    item_count,
    sale_amount,
    shipping_weight
);


create table invoice_item_fact_date_rollup (
    date_dim_id bigint not null references date_dim,
    item_count integer not null,
    sale_amount numeric not null,
    shipping_weight numeric not null,
    constraint invoice_item_fact_date_rollup_unq unique (
        date_dim_id
    )
);

insert into invoice_item_fact_date_rollup (
    date_dim_id,
    item_count,
    sale_amount,
    shipping_weight
)
select
    date_dim_id,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
group by
    date_dim_id
;

create table invoice_item_fact_geo_rollup (
    date_dim_id bigint not null references date_dim,
    account_geo_dim_id bigint not null references account_geo_dim,
    item_count integer not null,
    sale_amount numeric not null,
    shipping_weight numeric not null,
    constraint invoice_item_fact_geo_rollup_unq unique (
        date_dim_id,
        account_geo_dim_id
    )
);

insert into invoice_item_fact_geo_rollup (
    date_dim_id,
    account_geo_dim_id,
    item_count,
    sale_amount,
    shipping_weight
)
select
    date_dim_id,
    account_geo_dim_id,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
group by
    date_dim_id,
    account_geo_dim_id
;

create table invoice_item_fact_salesperson_rollup (
    date_dim_id bigint not null references date_dim,
    account_dim_id bigint not null references account_dim,
    salesperson_dim_id bigint not null references salesperson_dim,
    item_count integer not null,
    sale_amount numeric not null,
    shipping_weight numeric not null,
    constraint invoice_item_fact_salesperson_rollup_unq unique (
        date_dim_id,
        account_dim_id,
        salesperson_dim_id
    )
);

insert into invoice_item_fact_salesperson_rollup (
    date_dim_id,
    account_dim_id,
    salesperson_dim_id,
    item_count,
    sale_amount,
    shipping_weight
)
select
    date_dim_id,
    account_dim_id,
    salesperson_dim_id,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
group by
    date_dim_id,
    account_dim_id,
    salesperson_dim_id
;

create table invoice_item_fact_account_rollup (
    date_dim_id bigint not null references date_dim,
    account_dim_id bigint not null references account_dim,
    account_geo_dim_id bigint not null references account_geo_dim,
    item_count integer not null,
    sale_amount numeric not null,
    shipping_weight numeric not null,
    constraint invoice_item_fact_account_rollup_unq unique (
        date_dim_id,
        account_dim_id,
        account_geo_dim_id
    )
);

insert into invoice_item_fact_account_rollup (
    date_dim_id,
    account_dim_id,
    account_geo_dim_id,
    item_count,
    sale_amount,
    shipping_weight
)
select
    date_dim_id,
    account_dim_id,
    account_geo_dim_id,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
group by
    date_dim_id,
    account_dim_id,
    account_geo_dim_id
;


select 'invoice_item_fact_full_cube' as table_name, count(*) as row_count from invoice_item_fact_full_cube union all
select 'invoice_item_fact' as table_name, count(*) as row_count from invoice_item_fact union all
select 'invoice_item_fact_account_rollup' as table_name, count(*) as row_count from invoice_item_fact_account_rollup union all
select 'invoice_item_fact_date_rollup' as table_name, count(*) as row_count from invoice_item_fact_date_rollup union all
select 'invoice_item_fact_geo_rollup' as table_name, count(*) as row_count from invoice_item_fact_geo_rollup union all
select 'invoice_item_fact_salesperson_rollup' as table_name, count(*) as row_count from invoice_item_fact_salesperson_rollup
order by 2 asc
;

--               table_name              | row_count
-- --------------------------------------+-----------
--  invoice_item_fact_date_rollup        |        79
--  invoice_item_fact_account_rollup     |       214
--  invoice_item_fact_geo_rollup         |       214
--  invoice_item_fact_salesperson_rollup |       214
--  invoice_item_fact_full_cube          |      1518
--  invoice_item_fact                    |      1518
