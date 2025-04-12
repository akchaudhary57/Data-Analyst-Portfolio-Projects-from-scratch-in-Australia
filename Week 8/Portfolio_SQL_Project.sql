use bronze;

drop table if exists sales;
-- Append historical data into sale table using union. Understand difference between union and union all
select * into sales
from product_sales_2015
union 
select * from product_sales_2016
union 
select * from product_sales_2017

-- Union vs Union All

select 'A'
union 
select 'A'

select 'A'
union all
select 'A'

-- Give me Revenue per productname
-- Give me unique clients per productname 
-- Give me Avg net reveune per model name.
-- Give me Avg client per model name
create view RevenueAggregationbyProducts as 
with getrevenue as (
select 
cast(sum((s.OrderQuantity*p.productprice) - (s.OrderQuantity*p.ProductCost)) as decimal(19,2)) AS 'NetRevenue', 
p.ModelName,
p.Productname,
count(distinct s.CustomerKey) as UniqueClients,
pc.SubcategoryName,
s.productkey
from sales as s
left join products as p 
on s.productkey = p.productkey
left join Product_Subcategories as pc 
on p.ProductSubcategoryKey = pc.ProductSubcategoryKey
group by p.ModelName,pc.SubcategoryName,s.productkey,p.Productname

)
select *,
avg(NetRevenue) over (partition by Modelname) as AvgrevenueperModel,
avg(UniqueClients) over (partition by Modelname) as AvgClientsperModel
from getrevenue
order by Modelname

-- Cohort Analysis
-- A group of people or items sharing a common characteristics.
-- Examine a behaviour of specific groups over time. 

create view revenueperclient as 
select distinct 
cast(sum((s.OrderQuantity*p.productprice) - (s.OrderQuantity*p.ProductCost)) as decimal(19,2)) AS 'NetRevenue', 
p.ModelName,
p.Productname,
s.CustomerKey,
s.OrderDate
from sales as s
left join products as p 
on s.productkey = p.productkey
group by p.ModelName,
p.Productname,
s.CustomerKey,
s.OrderDate

-- Yearly cohort analysis on first purchase  vs Yearly Purchase
create view yearly_cohort as 
with yearly_cohort as (
select 
distinct 
CustomerKey,
year(min(orderdate) over(partition by customerkey)) as cohort_year
from 
sales
)
select 
y.cohort_year,
year(s.OrderDate) as Purchase_year,
sum(netrevenue) as netrevenue
from revenueperclient as s
left join yearly_cohort as y
on s.CustomerKey = y.CustomerKey
group by y.cohort_year,year(s.OrderDate);

create view yearly_cohort_customer as 
with yearly_cohort as (
select 
distinct 
CustomerKey,
year(min(orderdate) over(partition by customerkey)) as cohort_year
from 
sales
)
select 
y.cohort_year,
year(s.OrderDate) as Purchase_year,
count(distinct s.customerkey) as UniqueCustomer
from revenueperclient as s
left join yearly_cohort as y
on s.CustomerKey = y.CustomerKey
group by y.cohort_year,year(s.OrderDate)

select * from yearly_cohort_customer

-- Customer segmentaion - who are our most valuable customer

create view customer_segmentation as 
with revenue as 
(
select 
Modelname,
customerkey,
sum(netrevenue) as netrevenue
from revenueperclient
group by Modelname,customerkey
), customer_segments as (
select 
PERCENTILE_CONT(0.25) within group (order by netrevenue) over(partition by Modelname) as '25_percetile',
PERCENTILE_CONT(0.75) within group  (order by netrevenue) over(partition by Modelname) as '75_percetile',
*
from 
revenue 
), segment_summary as (
select 
case when netrevenue < [25_percetile] then '1 - Low Value Client'
when netrevenue <= [75_percetile] then '1 - Mid Value Client'
else '3- High-value' end as customer_segment,
*
from 
customer_segments
)
select customer_segment,sum(netrevenue) as  netrevenue
from segment_summary
group by customer_segment

-- Home work - Customer counts

-- Customer retention - who are not purchasing recently - churn rate
-- Active Customer - Customer who made a purchase within the last 6 month
-- Churned Customer - Customer who has n't made a purchase in over 6 months.
 
with getlastpurchase as (
select 
ROW_NUMBER() over (partition by customerkey order by orderdate desc) as rn,
*
from revenueperclient
)
select *,case when orderdate<dateadd(month,-6,(select max(orderdate) from revenueperclient)) then 'Churn'
        else 'Active' end as customer_status
		into churndata
from getlastpurchase where rn= 1

