create database dany;
use dany;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),

  ('B', '2021-01-09');
  select * from members;
  select * from sales;
  select * from menu;
  
  -- What is the total amount each customer spent at the restaurant?
  select customer_id,sum(price)as amount from sales s inner join menu m on s.product_id=m.product_id group by customer_id;
  
  -- How many days has each customer visited the restaurant?
    select customer_id,count(distinct(order_date))as days from sales group by customer_id;
    
    -- What was the first item from the menu purchased by each customer?
   with cte as( select sales.customer_id,menu.product_name,sales.order_date,dense_rank() over (partition by sales.customer_id order by sales.order_date)as rankk 
   from menu inner join sales using(product_id) group by sales.customer_id,menu.product_name,sales.order_date )
   select customer_id,product_name from cte where rankk=1;
   
   -- What is the most purchased item on the menu and how many times was it purchased by all customers?
   
   select product_name,count(product_name)as times from sales inner join menu using(product_id) group by product_name order by times desc limit 1;
   
   -- Which item was the most popular for each customer?
   
  with cte as (select sales.customer_id,menu.product_name,count(product_id)as countt ,dense_rank()over(partition by customer_id order by count(product_name) desc)as rankk from  sales 
  inner join menu using(product_id) group by sales.customer_id,menu.product_id,menu.product_name)
  select customer_id,product_name,countt from cte where rankk=1;
   
   --  Which item was purchased first by the customer after they became a member?
   
  with cte as( select customer_id,product_name,order_date ,dense_rank() over(partition by customer_id order by order_date)as rankk from members inner join sales using(customer_id) inner join menu using(product_id) where sales.order_date>=members.join_date)
 select   customer_id,product_name,order_date from cte where rankk=1;
 
 -- Which item was purchased just before the customer became a member?
   with cte as( select customer_id,product_name,order_date ,dense_rank() over(partition by customer_id order by order_date)as rankk from members inner join sales using(customer_id) inner join menu using(product_id) where sales.order_date<members.join_date)
 select   customer_id,product_name,order_date from cte where rankk=1;
 
 -- What is the total items and amount spent for each member before they became a member?
 select customer_id,count(product_id)as total_items,sum(price)as amount from members inner join sales using(customer_id) inner join menu using(product_id) where sales.order_date<members.join_date group by customer_id order by customer_id;
 
 --  If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
with cte as(select *,case when product_id=1 then price*20 else price*10 end as points from menu)
select customer_id,sum(points)as points from sales inner join cte using(product_id) group by customer_id;
-- In the first week after a customer joins the program (including their join date) they earn 2x
-- points on all items, not just sushi — how many points do customer A and B have at the end of January? 

SELECT ADDDATE("2017-06-15", INTERVAL 10 DAY);
with dates as(select *,adddate(join_date,interval 6 Day)as valid_date from members)
select customer_id,sum(case when product_id=1 then price*20 when order_date between join_date and valid_date then price*20 else price*10 end)as points from dates inner join
sales using(customer_id) inner join menu using(product_id) where order_date<('2021-01-31') group by customer_id order by points desc;


