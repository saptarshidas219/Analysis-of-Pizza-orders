create database pizza
use pizza

select * from order_details
select * from pizza_types
select * from pizzas
select * from orders
--Retrieve the total number of orders placed.
select COUNT(distinct order_id) as Total_Orders
from 
orders

--Calculate the total revenue generated from pizza sales.

select round(sum(order_details.quantity * pizzas.price),2) as Revenue
from order_details join pizzas
on
order_details.pizza_id = pizzas.pizza_id

--Identify the highest-priced pizza.
with mycte as ( 
select * from (
select *,DENSE_RANK() over(order by price desc) as Ranking
from pizzas ) as t
where t.Ranking =1)

select p.name,q.price from pizza_types as p join mycte as q
on
p.pizza_type_id = q.pizza_type_id

--Identify the most common pizza size ordered.

select t.size,count(t.quantity) as qty
from
(select order_details.order_details_id,order_details.quantity,pizzas.size
from order_details join pizzas on
order_details.pizza_id = pizzas.pizza_id) as t
group by t.size
order by qty desc

--List the top 5 most ordered pizza types along with their quantity
select t.name, sum(t.quantity) as Total_qty
from
(
select pizza_types.name, order_details.quantity
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id) as t
group by t.name
order by Total_qty desc




--Join the necessary tables to find the total quantity of each pizza category ordered.
select t.category, count(t.quantity) as total_qty
from
(select t1.category, t2.quantity
from pizza_types t1 join pizzas as t3 on t1.pizza_type_id = t3.pizza_type_id
join order_details as t2 on t2.pizza_id = t3.pizza_id) as t
group by t.category
order by total_qty desc

-- Determine the distribution of orders by hour of the day.

select DATEPART(hh,orders.time) as hrs,COUNT(order_id) as Total_Count
from orders
group by DATEPART(hh,orders.time)
order by DATEPART(hh,orders.time) asc

--Group the orders by date and calculate the average number of pizzas ordered per day..


select sum(t.total_qty)/count(t.date) as avg_qty_perday 
from (select t1.date,sum(t2.quantity) total_qty
from orders as t1 join order_details as t2 on
t1.order_id = t2.order_id
group by t1.date) as t

--Determine the top 3 most ordered pizza types based on revenue

select top 3 t.pizza_type_id,round(sum(t.quantity)*sum(t.price),0) as total_price
from (select t2.pizza_type_id,t1.quantity,t3.price
from order_details as t1 join pizzas as t3 on t1.pizza_id=t3.pizza_id
join pizza_types as t2 on t2.pizza_type_id = t3.pizza_type_id) as t
group by pizza_type_id
order by total_price desc

--Calculate the percentage contribution of each pizza type to total revenue.

select x.pizza_type_id,round((x.total_price/total_revenue)*100,2) as Revenue_per
from (select p.pizza_type_id,p.total_price,sum(p.total_price) over () as total_revenue
from (select t.pizza_type_id,round(sum(t.quantity)*sum(t.price),0) as total_price
from (select t2.pizza_type_id,t1.quantity,t3.price
from order_details as t1 join pizzas as t3 on t1.pizza_id=t3.pizza_id
join pizza_types as t2 on t2.pizza_type_id = t3.pizza_type_id) as t
group by pizza_type_id ) as p) as x
order by Revenue_per desc


--Analyze the cumulative revenue generated over time.


select x.date,round(SUM(x.Revenue),0) as Revenue
from (select t.date,t.order_id,t.pizza_id,t.quantity,t.quantity*t.price as Revenue
from (select t3.date,t1.order_id,t1.pizza_id,t1.quantity,t2.price
from order_details as t1 join pizzas as t2 on t1.pizza_id=t2.pizza_id
join orders as t3 on t1.order_id = t3.order_id) as t) as x
group by x.date
order by x.date desc
