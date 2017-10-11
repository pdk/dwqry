select
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
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
on salesperson_dim.salesperson_dim_id = invoice_item_fact.salesperson_dim_id
;

--  item_count | sale_amount | shipping_weight
-- ------------+-------------+-----------------
--       16222 |   691687.83 |        397108.9
-- (1 row)


select
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
;

--  item_count | sale_amount | shipping_weight
-- ------------+-------------+-----------------
--       16222 |   691687.83 |        397108.9
-- (1 row)

select
    account_sales_region,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join account_geo_dim
on account_geo_dim.account_geo_dim_id = invoice_item_fact.account_geo_dim_id
group by
    account_sales_region
;

--  account_sales_region | item_count | sale_amount | shipping_weight
-- ----------------------+------------+-------------+-----------------
--  Europe               |       3981 |   161940.35 |         97689.6
--  N/A                  |       1802 |    71434.04 |         44574.2
--  South/Latin America  |       1727 |    77992.52 |         40057.1
--  Asia & Pacific       |       6271 |   274631.59 |        156865.2
--  CIS                  |        635 |    24634.82 |         13607.9
--  Africa               |       1223 |    53316.95 |         28959.6
--  North America        |         75 |     2896.61 |          2176.7
--  Arab States          |        508 |    24840.95 |         13178.6
-- (8 rows)

select
    account_sales_region,
    month_name,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join account_geo_dim
on account_geo_dim.account_geo_dim_id = invoice_item_fact.account_geo_dim_id
inner join date_dim
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
where date_value >= '2017-08-01'::date and date_value <= '2017-09-30'::date
group by
    account_sales_region,
    month_name
order by account_sales_region, month_name
;

--  account_sales_region | month_name | item_count | sale_amount | shipping_weight
-- ----------------------+------------+------------+-------------+-----------------
--  Africa               | Aug        |        597 |    24486.41 |         14096.8
--  Africa               | Sep        |        421 |    20145.25 |          9796.2
--  Arab States          | Aug        |        447 |    21474.97 |         11711.4
--  Asia & Pacific       | Aug        |       2327 |    98382.94 |         59812.8
--  Asia & Pacific       | Sep        |       1821 |    72016.53 |         46376.2
--  CIS                  | Aug        |        417 |    17110.69 |          7899.0
--  CIS                  | Sep        |        114 |     3765.16 |          3001.7
--  Europe               | Aug        |       1104 |    49847.21 |         27653.8
--  Europe               | Sep        |        959 |    34610.35 |         22469.9
--  N/A                  | Aug        |        580 |    22372.33 |         12840.6
--  N/A                  | Sep        |        357 |    11009.15 |         10018.2
--  South/Latin America  | Aug        |        422 |    20531.48 |          9926.7
--  South/Latin America  | Sep        |        295 |    13092.75 |          5406.3
-- (13 rows)


select
    account_sales_region,
    month_name,
    sum(item_count) as item_count,
    sum(sale_amount) as sale_amount,
    sum(shipping_weight) as shipping_weight
from invoice_item_fact
inner join account_geo_dim
on account_geo_dim.account_geo_dim_id = invoice_item_fact.account_geo_dim_id
inner join date_dim
on date_dim.date_dim_id = invoice_item_fact.date_dim_id
where date_value >= '2017-08-01'::date and date_value <= '2017-09-30'::date
group by
    account_sales_region,
    month_name
order by account_sales_region, month_name
;

--  account_sales_region | month_name | item_count | sale_amount | shipping_weight
-- ----------------------+------------+------------+-------------+-----------------
--  Africa               | Aug        |        597 |    24486.41 |         14096.8
--  Africa               | Sep        |        421 |    20145.25 |          9796.2
--  Arab States          | Aug        |        447 |    21474.97 |         11711.4
--  Asia & Pacific       | Aug        |       2327 |    98382.94 |         59812.8
--  Asia & Pacific       | Sep        |       1821 |    72016.53 |         46376.2
--  CIS                  | Aug        |        417 |    17110.69 |          7899.0
--  CIS                  | Sep        |        114 |     3765.16 |          3001.7
--  Europe               | Aug        |       1104 |    49847.21 |         27653.8
--  Europe               | Sep        |        959 |    34610.35 |         22469.9
--  N/A                  | Aug        |        580 |    22372.33 |         12840.6
--  N/A                  | Sep        |        357 |    11009.15 |         10018.2
--  South/Latin America  | Aug        |        422 |    20531.48 |          9926.7
--  South/Latin America  | Sep        |        295 |    13092.75 |          5406.3
-- (13 rows)

select
    salesperson_first_name,
    salesperson_last_name,
    salesperson_email,
    sum(sale_amount) as sale_amount
from invoice_item_fact
inner join salesperson_dim
on salesperson_dim.salesperson_dim_id = invoice_item_fact.salesperson_dim_id
group by
    salesperson_first_name,
    salesperson_last_name,
    salesperson_email
order by
    salesperson_last_name,
    salesperson_first_name
limit 10
;

--  salesperson_first_name | salesperson_last_name |       salesperson_email        | sale_amount
-- ------------------------+-----------------------+--------------------------------+-------------
--  Emili                  | Aliberti              | ealiberti1k@simplemachines.org |     8056.90
--  Vickie                 | Bembrigg              | vbembriggb@nbcnews.com         |     1564.24
--  Mame                   | Berrecloth            | mberrecloth4@reuters.com       |     4212.66
--  Marysa                 | Berriman              | mberriman1p@1und1.de           |    11483.73
--  Eleanora               | Blabber               | eblabber2i@desdev.cn           |    10891.15
--  Enriqueta              | Blackbourn            | eblackbournt@wikia.com         |     2728.72
--  Krystle                | Blaschek              | kblaschek1g@dedecms.com        |    10142.93
--  Cynthie                | Bricklebank           | cbricklebank1d@disqus.com      |     6786.06
--  Eloisa                 | Bulstrode             | ebulstrode12@hud.gov           |     6880.08
--  Jessamine              | Burnage               | jburnageo@deviantart.com       |     7369.97
-- (10 rows)

select
    *
from (
    select
        *,
        rank() over (
            partition by account_sales_region order by sale_amount desc
        ) as region_sales_rank
    from (
        select
            salesperson_first_name,
            salesperson_last_name,
            salesperson_email,
            account_sales_region,
            sum(item_count) as item_count,
            sum(sale_amount) as sale_amount,
            sum(shipping_weight) as shipping_weight
        from invoice_item_fact
        inner join account_geo_dim
        on account_geo_dim.account_geo_dim_id = invoice_item_fact.account_geo_dim_id
        inner join date_dim
        on date_dim.date_dim_id = invoice_item_fact.date_dim_id
        inner join salesperson_dim
        on salesperson_dim.salesperson_dim_id = invoice_item_fact.salesperson_dim_id
        where date_value >= '2017-08-01'::date and date_value <= '2017-08-31'::date
        group by
            salesperson_first_name,
            salesperson_last_name,
            salesperson_email,
            account_sales_region
    ) x
) y
where region_sales_rank <= 3
order by account_sales_region, sale_amount desc
;

--  salesperson_first_name | salesperson_last_name |        salesperson_email        | account_sales_region | item_count | sale_amount | shipping_weight | region_sales_rank
-- ------------------------+-----------------------+---------------------------------+----------------------+------------+-------------+-----------------+-------------------
--  Rici                   | Peggrem               | rpeggrem1e@wired.com            | Africa               |        136 |     7274.79 |          4410.5 |                 1
--  Eloisa                 | Bulstrode             | ebulstrode12@hud.gov            | Africa               |        153 |     6129.76 |          3262.9 |                 2
--  Kimbell                | Wakelam               | kwakelama@dedecms.com           | Africa               |        136 |     5546.38 |          2535.5 |                 3
--  Lion                   | Handrok               | lhandrokf@discovery.com         | Arab States          |         97 |     5000.10 |          3129.0 |                 1
--  Brittaney              | McJerrow              | bmcjerrow1s@ow.ly               | Arab States          |         96 |     4263.91 |          1547.4 |                 2
--  Cynthie                | Bricklebank           | cbricklebank1d@disqus.com       | Arab States          |         83 |     3957.31 |          1871.7 |                 3
--  Marion                 | Philippsohn           | mphilippsohn11@vinaora.com      | Asia & Pacific       |        186 |     8720.76 |          5738.6 |                 1
--  Kain                   | Follan                | kfollan25@w3.org                | Asia & Pacific       |        145 |     7193.05 |          4169.7 |                 2
--  Berty                  | Hounsome              | bhounsome1b@a8.net              | Asia & Pacific       |        132 |     5869.63 |          3437.8 |                 3
--  Eadie                  | Eymer                 | eeymer21@cloudflare.com         | CIS                  |        128 |     7638.97 |          2821.2 |                 1
--  Dita                   | Ogbourne              | dogbourne1l@constantcontact.com | CIS                  |        112 |     4368.54 |          1559.2 |                 2
--  Fielding               | Mochar                | fmochar18@360.cn                | CIS                  |         72 |     2209.31 |          1405.8 |                 3
--  Dionysus               | Winterflood           | dwinterflood1@altervista.org    | Europe               |        181 |     9166.97 |          5276.6 |                 1
--  Ranee                  | Mayo                  | rmayo3@webs.com                 | Europe               |        124 |     6514.35 |          2342.5 |                 2
--  Evania                 | Pope                  | epopev@foxnews.com              | Europe               |        127 |     6385.74 |          3350.8 |                 3
--  Kimmie                 | Simonds               | ksimonds1o@google.pl            | N/A                  |        129 |     6727.58 |          2070.2 |                 1
--  Chad                   | MacVay                | cmacvayw@slideshare.net         | N/A                  |        147 |     4294.81 |          4009.5 |                 2
--  Rici                   | Peggrem               | rpeggrem1e@wired.com            | N/A                  |        106 |     4204.60 |          2947.5 |                 3
--  Jessalyn               | Giacopini             | jgiacopiniu@bing.com            | South/Latin America  |        124 |     6950.34 |          2798.8 |                 1
--  Elenore                | Flay                  | eflayx@guardian.co.uk           | South/Latin America  |         94 |     4687.48 |          2348.2 |                 2
--  Nehemiah               | Scrowton              | nscrowton1j@statcounter.com     | South/Latin America  |         80 |     4574.17 |          2475.8 |                 3
-- (21 rows)