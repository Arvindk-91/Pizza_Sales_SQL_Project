select * from pizza_order ;
select * from pizza_order_details ;
select * from pizza_types;
select * from pizzas ;

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS Total_number_of_orders
FROM
    pizza_order;

-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(pizza_order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    pizza_order_details
        JOIN
    pizzas ON pizza_order_details.pizza_id = pizzas.pizza_id;
    
    
-- 3.Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price AS Highest_priced
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(pizza_order_details.order_details_id) AS ordered
FROM
    pizzas
        JOIN
    pizza_order_details ON pizzas.pizza_id = pizza_order_details.pizza_id
GROUP BY size
ORDER BY ordered DESC
LIMIT 1;

-- '-- 5. List the top 5 most ordered pizza types along with their quantities.'
SELECT 
    pizza_types.name,
    SUM(pizza_order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_order_details ON pizza_order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5	;


-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(pizza_order_details.quantity) AS Total_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_order_details ON pizza_order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY Total_Quantity DESC;

-- 7.Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS count
FROM
    pizza_order
GROUP BY hour;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS count
FROM
    pizza_types
GROUP BY category;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS Per_day_order
FROM
    (SELECT 
        pizza_order.order_date,
            SUM(pizza_order_details.quantity) AS quantity
    FROM
        pizza_order
    JOIN pizza_order_details ON pizza_order.order_id = pizza_order_details.order_id
    GROUP BY order_date) AS order_day;

-- 10.Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(pizza_order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_order_details ON pizza_order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;  

-- 11.Calculate the percentage contribution of each pizza category to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(pizza_order_details.quantity * pizzas.price) / (SELECT 
                    SUM(pizza_order_details.quantity * pizzas.price)
                FROM
                    pizza_order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = pizza_order_details.pizza_id)) * 100,
            2) AS revenue_percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    pizza_order_details ON pizza_order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

-- 12.Analyze the cumulative revenue generated over time.

SELECT 
    order_date,
    revenue,
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT 
        pizza_order.order_date,
        ROUND(SUM(pizza_order_details.quantity * pizzas.price), 2) AS revenue
    FROM pizza_order_details
    JOIN pizzas ON pizzas.pizza_id = pizza_order_details.pizza_id
    JOIN pizza_order ON pizza_order.order_id = pizza_order_details.order_id
    GROUP BY pizza_order.order_date
) AS sales;

-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    name,
    category,
    revenue
FROM (
    SELECT 
        category,
        name,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT 
            pizza_types.category, 
            pizza_types.name,
            SUM(pizza_order_details.quantity * pizzas.price) AS revenue
        FROM pizza_types 
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN pizza_order_details ON pizza_order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rn <= 3;





