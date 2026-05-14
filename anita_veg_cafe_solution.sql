select * from members;
select * from sales;
select * from menu;
----------------------------------------------------------------------------------------------------------------
--1. What is the total amount each customer has spent at the café?
select s.customer_id,sum(m.price) as total
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id;
----------------------------------------------------------------------------------------------------------------
--2. How many distinct days has each customer placed an order?
select customer_id,count(distinct(order_date)) as distinct_days from sales
group by customer_id
order by distinct_days;
----------------------------------------------------------------------------------------------------------------
--3. What was the first dish ordered by each customer?
select customer_id,product_id,product_name from 
(select s.customer_id,s.product_id,m.product_name,
dense_rank() over(partition by customer_id order by order_date) as rn 
from sales s
join menu m on m.product_id = s.product_id)
where rn = 1
---------------------------------------------------------------------------------------------------------------
--4. Which menu item is the most popular overall?
with total as (select m.product_name,count(s.product_id) as total_ordered_item from menu m
join sales s on m.product_id = s.product_id
group by m.product_name),
most_p as (select max(total_ordered_item) as most from total)
select product_name
from total
where total_ordered_item = (select most from most_p)
-----------------------------------------------------------------------------------------------------------------
--5. What is the most frequently ordered dish for each customer?
select s.customer_id,m.product_name from sales s
join menu m on s.product_id = m.product_id
group by customer_id,m.product_name
having count(s.product_id) >=2
order by customer_id;
-------------------------------------------------------------------------------------------------------------------
-- 6. After joining the loyalty program, what dish did each member first order?
select customer_id,product_name,join_date,order_date from
(select s.customer_id,mm.product_name,m.join_date,s.order_date,
dense_rank() over(partition by s.customer_id order by order_date) as rn 
from sales s 
join members m on s.customer_id = m.customer_id
join menu mm on s.product_id = mm.product_id
where m.join_date <s.order_date)
where rn = 1
--------------------------------------------------------------------------------------------------------------------
-- 7. Before joining the loyalty program, what dish did each customer order last?
select customer_id,product_name,join_date,order_date from
(select s.customer_id,mm.product_name,m.join_date,s.order_date,
dense_rank() over(partition by s.customer_id order by order_date desc) as rn 
from sales s 
join members m on s.customer_id = m.customer_id
join menu mm on s.product_id = mm.product_id
where m.join_date >s.order_date)
where rn = 1
-------------------------------------------------------------------------------------------------------------------
-- 8. For each member, how many items and how much did they spend before joining?
select s.customer_id,count(mm.product_id) as quantity,sum(mm.price) as total_spending
from sales s 
join members m on s.customer_id = m.customer_id
join menu mm on s.product_id = mm.product_id
where m.join_date >s.order_date
group by s.customer_id
--------------------------------------------------------------------------------------------------------------------
--**9.If each ₹1 = 10 points,and Paneer Butter Masala earns double points,how many points does each customer earn?
select s.customer_id,
sum(case
when s.product_id = 1 then m.price*20
else m.price*10
end) as total_points
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id;
-----------------------------------------------------------------------------------------------------------------------
--** 10. In their first loyalty week (starting from join_date),
-- members earn double points on all items. How many points do Aarav and Meera have by the end of January?
select s.customer_id,mm.join_date,
sum(case
when s.order_date between mm.join_date and mm.join_date + interval '6 days' then m.price*20
else m.price*10
end) as total_points
from sales s
join menu m on m.product_id = s.product_id
join members mm on s.customer_id = mm.customer_id
WHERE s.order_date <= '2021-01-31'
group by s.customer_id,mm.join_date
order by s.customer_id;


