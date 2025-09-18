use prince;
select * from retail_orders;
-- 1. find top 10 highest reveue generating products 
select product_id, round(sum(sale_price),2) as sales
from retail_orders
group by product_id
order by sales desc
limit 10;

-- 2. find top 5 highest selling products in each region
with cte as 
(select region, product_id, round(sum(sale_price),2) as sales
from retail_orders
group by region, product_id)
select * 
from
(select * , row_number() over (partition by region order by sales desc) as rn
from cte) A
where rn <= 5;

-- 3. find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as 
(select year(order_date) as order_year, month(order_date) as order_month, round(sum(sale_price),2) as sales
from retail_orders
group by year(order_date), month(order_date) )
select order_month, sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- 4. for each category which month had highest sales 
with cte as 
(select category, date_format(order_date, '%Y%m') as order_year_month, round(sum(sale_price),2) as sales
from retail_orders
group by category, date_format(order_date, '%Y%m'))
select *
from
(select *, row_number() over (partition by category order by sales desc) as rn 
from cte) A
where rn = 1;

-- 5. which sub category had highest growth by profit in 2023 compare to 2022
with cte as 
 (select sub_category, year(order_date) as order_year, round(sum(sale_price),2) as sales
 from retail_orders
 group by sub_category, year(order_date)), 
 
 cte2 as 
(select sub_category, sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category)

select *, round((sales_2023-sales_2022)*1,2) as growth_from_2022_to_2023
from cte2
order by growth_from_2022_to_2023 desc
limit 1;
 

-- 6. Which region generated the highest total sales each year?
with cte as 
(select region, year(order_date) as order_year, round(sum(sale_price),2) as sales
from retail_orders
group by region, year(order_date))
select *
from
(select *, row_number() over (partition by order_year order by sales desc) as rn
from cte) A
where rn = 1;

-- 7. Which category has the highest average order value (AOV)?
select category, round(avg(sale_price),2) as avg_order_value
from retail_orders
group by category
order by avg_order_value desc
limit 1;


-- 8. Which subcategory experienced the largest drop in sales from 2022 to 2023?

with cte as 
 (select sub_category, year(order_date) as order_year, round(sum(sale_price),2) as sales
 from retail_orders
 group by sub_category, year(order_date)), 
 
 cte2 as 
(select sub_category, sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category)

select *, round((sales_2023-sales_2022)*1,2) as growth_from_2022_to_2023
from cte2
order by growth_from_2022_to_2023 asc
limit 1;
 
-- 9. List the top 3 most profitable products in each category.

with cte as
(select category, product_id, round(sum(sale_price),2) as sales
from retail_orders
group by category, product_id)
select *
from 
(select *, row_number() over (partition by category order by sales desc) as rn
from cte) A
where rn <= 3;

-- 10. Find the month with the highest number of orders (not sales) for each region.

with cte as 
(select region, date_format(order_date, '%Y%m') as order_month, count(*) as number_of_orders
from retail_orders
group by region, date_format(order_date, '%Y%m'))
select *
from
(select *, row_number() over (partition by region order by number_of_orders desc) as rn
from cte) A
where rn = 1;

-- 11. Calculate cumulative sales by month for 2023 (running total).

with cte as 
(select date_format(order_date, '%Y%m') as order_month, round(sum(sale_price),2) as sales
from retail_orders
where year(order_date) = 2023
group by date_format(order_date, '%Y%m'))

select order_month, sales, sum(sales) over(order by order_month) as cumulative_sales
from cte
order by order_month;

-- 12. Which category had the highest sales growth rate (percentage) between 2022 and 2023?
with cte as 
 (select category, year(order_date) as order_year, round(sum(sale_price),2) as sales
 from retail_orders
 group by category, year(order_date)), 
 
 cte2 as 
(select category, sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by category)

select *, round(((sales_2023 - sales_2022)/sales_2022)*100, 2) as sales_growth_rate
from cte2
order by sales_growth_rate desc
limit 1;