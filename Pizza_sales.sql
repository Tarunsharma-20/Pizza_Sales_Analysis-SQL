USE mypizza;


-- Q1) The total number of order place.

SELECT 
    COUNT(DISTINCT order_id) AS total_orders_placed
FROM
    orders;


-- Q2) The total revenue generated from pizza sales.

SELECT 
    CONCAT('$ ',
            ROUND(SUM(p.price * od.quantity), 2)) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id;

    
-- Q3) Identify the highest-priced pizza.

SELECT 
    pt.name, CONCAT('$ ', p.price) AS price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- Q4) Identify the most common pizza size ordered.

SELECT 
    p.size AS common_size,
    COUNT(od.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;


-- Q5) List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- Q6) Find the total quantity of each pizza categories ordered.

SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


-- Q7) Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY order_count DESC;


-- Q8) Find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS name_count
FROM
    pizza_types
GROUP BY category
ORDER BY name_count DESC;


-- Q9) Calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS daily_orders;
    

--   Q10) Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name,
    CONCAT('$ ',
            ROUND(SUM(p.price * od.quantity), 2)) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3;


-- Q11) Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    CONCAT('$ ',
            ROUND(SUM(od.quantity * p.price), 2)) AS revenue,
    CONCAT(ROUND((SUM(od.quantity * p.price) / (SELECT 
                            SUM(od.quantity * p.price)
                        FROM
                            pizzas p
                                 JOIN
                            order_details od ON od.pizza_id = p.pizza_id)) * 100,
                    2),
            '%') AS percentage_contribution
FROM
    pizza_types pt
         JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
         JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY Revenue DESC;


-- Q12) The cumulative revenue generated over time.

SELECT
    sales.order_date,
    CONCAT('$ ', sales.revenue) AS revenue,
    CONCAT('$ ', ROUND(SUM(sales.revenue) OVER (ORDER BY sales.order_date), 2)) AS cum_revenue
FROM
    (SELECT
        o.order_date,
        ROUND(SUM(p.price * od.quantity), 2) AS revenue
    FROM
        pizzas p
    JOIN
        order_details od ON p.pizza_id = od.pizza_id
    JOIN
        orders o ON od.order_id = o.order_id
    GROUP BY
        o.order_date) AS sales;


-- Q13) The top 3 most ordered pizza type based on revenue for each pizza category.

WITH pizza_revenue AS (
    SELECT
        pt.category,
        pt.name AS pizza_type,
        SUM(od.quantity * p.price) AS revenue
    FROM
        pizzas p
    JOIN
        pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    JOIN
        order_details od ON p.pizza_id = od.pizza_id
    GROUP BY
        pt.category, pt.name
),
ranked_pizza_revenue AS (
    SELECT
        category,
        pizza_type,
        revenue,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS r
    FROM
        pizza_revenue
)

SELECT
    category,
    pizza_type,
    CONCAT('$ ', ROUND(revenue, 2)) AS revenue
FROM
    ranked_pizza_revenue
WHERE
    r <= 3
ORDER BY
    category,
    revenue DESC;
