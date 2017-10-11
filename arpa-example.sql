
drop table if exists cmrr_fact;

create table cmrr_fact (
    date_dim_id text,
    month_dim_id text,
    product_rate_plan_dim_id text,
    subscription_owner_account_dim_id text,
    invoice_owner_account_dim_id text,
    order_dim_id text,
    cmrr numeric
);

delete from cmrr_fact;

insert into cmrr_fact (
    date_dim_id, month_dim_id, product_rate_plan_dim_id, subscription_owner_account_dim_id, invoice_owner_account_dim_id, order_dim_id, cmrr
) values
('2017-01-31', '2017-01', '1001', '2002', '2002', '1234', 1000.00),
('2017-01-31', '2017-01', '1002', '2002', '2002', '1234', 2000.00),
('2017-01-31', '2017-01', '1001', '2004', '2004', '1234', 500.00),
('2017-01-31', '2017-01', '1002', '2004', '2004', '1234', 1000.00);

drop table if exists monthly_active_users_fact;

create table monthly_active_users_fact (
    month_dim_id text,
    subscription_owner_account_dim_id text,
    active_users numeric
);

insert into monthly_active_users_fact (
    month_dim_id, subscription_owner_account_dim_id, active_users
) values 
('2017-01', '2002', 13),
('2017-01', '2005', 10);


-- +------------------------------------+             +-----------------------------------+
-- | CMRR Fact                          |             | Monthly Active Users Fact         |
-- +------------------------------------+             +-----------------------------------+
-- | date_dim_id                        |             | month_dim_id                      |
-- | month_dim_id                       |             | subscription_owner_account_dim_id |
-- | product_rateplan_dim_id            |             | active_users                      |
-- | subscription_owner_account_dim_id  |             +-----------------------------------+
-- | invoice_owner_account_dim_id       |             
-- | order_dim_id                       |
-- | cmrr                               |
-- +------------------------------------+


select
    *,
    cmrr / active_users as arpa
from (
    select
        f1.month_dim_id,
        f1.subscription_owner_account_dim_id,
        sum(cmrr) as cmrr,
        sum(active_users) as active_users
    from cmrr_fact f1
    inner join monthly_active_users_fact f2
    on f1.month_dim_id = f2.month_dim_id
    and f1.subscription_owner_account_dim_id = f2.subscription_owner_account_dim_id
    group by
        f1.month_dim_id,
        f1.subscription_owner_account_dim_id
) x
;
