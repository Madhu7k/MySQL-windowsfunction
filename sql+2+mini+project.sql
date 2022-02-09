create database mini;
use mini;
  #                     SQL II - Mini Project
# Composite data of a business organisation, confined to ‘sales and delivery’ domain is given 
# for the period of last decade. From the given data retrieve solutions for the given scenario.
select * from cust_dimen;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select * from shipping_dimen;
-- 1. Join all the tables and create a new table called combined_table.
-- (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

create table combined_table as(
select cd.customer_name,cd.province, cd.region, cd.customer_segment, cd.cust_id,
m.ord_id,  m.sales,m.discount,m.order_quantity, m.profit, m.shipping_cost, m.product_base_margin,
 o.order_date, o. order_priority,  
p.product_category, p.product_sub_category, p.prod_id,
sd.order_id,sd.ship_mode, sd.ship_date, sd.ship_id
from cust_dimen as cd join market_fact m
on 	cd.cust_id=m.cust_id
inner join orders_dimen o
on o.ord_id=m.ord_id
inner join shipping_dimen sd
on m.ship_id=sd.ship_id
inner join prod_dimen p
on p.prod_id=m.prod_id);
select  * from combined_table;

-- 2. Find the top 3 customers who have the maximum number of orders
select * from (
select m.order_quantity,cd.customer_name,
dense_rank() over (order by m.order_quantity desc )max_num
from market_fact m join cust_dimen cd
on m.cust_id=cd.cust_id)top_3
group by customer_name
having max_num<=3;

select max(order_quantity) from market_fact;

-- 3. Create a new column DaysTakenForDelivery that contains the date difference
-- of Order_Date and Ship_Date.
alter table combined_table
add column DaysTakenForDelivery  int;
update combined_table
set DaysTakenForDelivery = abs(datediff(order_date,ship_date));

select * from combined_table;

-- 4. Find the customer whose order took the maximum time to get delivered

select c.customer_name,o.order_id, o.order_priority, sd.ship_mode,sd.ship_id,max(abs(datediff(o.order_date,sd.ship_date))) as DaysTakenForDelivery
from orders_dimen o join shipping_dimen sd	
on o.order_id=sd.order_id
inner join market_fact m
on m.ord_id=o.ord_id
inner join cust_dimen c
on m.cust_id=c.cust_id;


-- 5. Retrieve total sales made by each product from the data (use Windows function)

select p.prod_id, 
sum(sales) over(order by m.sales desc)tot_sales
from market_fact m join prod_dimen p
on m.prod_id=p.prod_id
group by p.prod_id;


-- 6. Retrieve total profit made from each product from the data (use windows function)

select p.product_sub_category, 
sum(profit) over(order by m.profit desc)tot_profit
from market_fact m join prod_dimen p
on m.prod_id=p.prod_id
group by p.product_sub_category;


-- 7. Count the total number of unique customers in January and how many of them
-- came back every month over the entire year in 2011
SELECT Year(order_date),Month(order_date),count(distinct cust_id) AS num
FROM combined_table
WHERE year(order_date)=2011 and cust_id in (
select distinct cust_id
from combined_table
where year(order_date)='2011' and	month(order_date)=1)
GROUP BY Year(order_date),Month(order_date);

-- 8. Retrieve month-by-month customer retention rate since the start of the
-- business.(using views)

/*Tips:
#1: Create a view where each user’s visits are logged by month, allowing for
the possibility that these will have occurred over multiple # years since
whenever business started operations
-- 2: Identify the time lapse between each visit. So, for each person and for each
month, we see when the next visit is.
# 3: Calculate the time gaps between visits
# 4: categorise the customer with time gap 1 as retained, >1 as irregular and
NULL as churned
# 5: calculate the retention month wise*/

select  * from combined_table ;







