CREATE SCHEMA pizza_runner;


DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time DATETIME -- Change the data type to DATETIME
);


INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, '', '', '2021-01-01 18:05:02'),
  (2, 101, 1, '', '', '2021-01-01 19:00:52'),
  (3, 102, 1, '', '', '2021-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2021-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2021-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2021-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2021-01-04 13:23:46'),
  (5, 104, 1, null, '1', '2021-01-08 21:00:29'),
  (6, 101, 2, null, null, '2021-01-08 21:03:13'),
  (7, 105, 2, null, '1', '2021-01-08 21:20:29'),
  (8, 102, 1, null, null, '2021-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2021-01-10 11:22:59'),
  (10, 104, 1, null, null, '2021-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2021-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time TIMESTAMP,
  distance FLOAT,
  duration INTEGER,
  cancellation VARCHAR(23)
);

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time DATETIME, 
  distance FLOAT, 
  duration INTEGER,
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2021-01-01 18:15:34', 20, 32, ''),
  (2, 1, '2021-01-01 19:10:54', 20, 27, ''),
  (3, 1, '2021-01-03 00:12:37', 13.4, 20, NULL),
  (4, 2, '2021-01-04 13:53:03', 23.4, 40, NULL),
  (5, 3, '2021-01-08 21:10:57', 10, 15, NULL),
  (6, 3, null, null, null, 'Restaurant Cancellation'),
  (7, 2, '2021-01-08 21:30:45', 25, 25, NULL),
  (8, 2, '2021-01-10 00:15:02', 23.4, 15, NULL),
  (9, 2, null, null, null, 'Customer Cancellation'),
  (10, 1, '2021-01-11 18:50:20', 10, 10, NULL);


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meat Lovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


  --resolving the null values in customer_orders and runner_orders tables
 UPDATE customer_orders
SET exclusions = COALESCE(exclusions, 'NULL'),
    extras = COALESCE(extras, 'UNKNOWN');

--question 1. How many pizzas were ordered?

SELECT COUNT(*) AS total_pizzas_ordered
FROM customer_orders;

--question 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS total_unique_orders
FROM customer_orders;

--question 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

--question 4. How many of each type of pizza was delivered?

SELECT pizza_id, COUNT(*) AS total_deliveries
FROM customer_orders
GROUP BY pizza_id;

--question 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT co.customer_id, CAST(pn.pizza_name AS VARCHAR(50)) AS pizza_name, COUNT(*) AS total_orders
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id, CAST(pn.pizza_name AS VARCHAR(50));

--question 6. What was the maximum number of pizzas delivered in a single order?

SELECT MAX(pizza_count) AS max_pizzas_delivered
FROM (
    SELECT order_id, COUNT(*) AS pizza_count
    FROM customer_orders
    GROUP BY order_id
) AS order_counts;

-- question 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
    customer_id,
    SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS no_changes,
    SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS with_changes
FROM customer_orders
GROUP BY customer_id;

-- question 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS pizzas_with_both_exclusions_and_extras
FROM customer_orders
WHERE exclusions IS NOT NULL AND exclusions <> ''
  AND extras IS NOT NULL AND extras <> '';

  -- question 9. What was the total volume of pizzas ordered for each hour of the day?

  SELECT 
    DATEPART(HOUR, order_time) AS order_hour,
    COUNT(*) AS total_pizzas_ordered
FROM customer_orders
GROUP BY DATEPART(HOUR, order_time)
ORDER BY order_hour;

--question 10. What was the volume of orders for each day of the week?

SELECT 
    DATEPART(WEEKDAY, order_time) AS day_of_week,
    COUNT(*) AS total_orders
FROM customer_orders
GROUP BY DATEPART(WEEKDAY, order_time)
ORDER BY day_of_week;

--B. Runner and Customer Experience
--question 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
    DATEPART(WEEK, registration_date) AS week_number,
    COUNT(*) AS total_runners
FROM runners
GROUP BY DATEPART(WEEK, registration_date)
ORDER BY week_number;


--question 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT 
    runner_id,
    AVG(DATEDIFF(MINUTE, CONVERT(DATETIME, duration), CONVERT(DATETIME, pickup_time))) AS average_pickup_time_minutes
FROM runner_orders
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

--question 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH OrderedOrders AS (
    SELECT
        customer_id,
        order_id,
        order_time,
        LEAD(order_time) OVER (PARTITION BY customer_id ORDER BY order_time) AS next_order_time
    FROM customer_orders
)
SELECT
    customer_id,
    order_id,
    DATEDIFF(MINUTE, order_time, next_order_time) AS preparation_time_minutes
FROM OrderedOrders
WHERE next_order_time IS NOT NULL;

--question 4. What was the average distance travelled for each customer?

SELECT
    co.customer_id,
    AVG(CAST(REPLACE(ro.distance, 'km', '') AS FLOAT)) AS average_distance_km
FROM customer_orders co
INNER JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;

--question 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
    DATEDIFF(MINUTE, MIN(pickup_time), MAX(pickup_time)) AS time_difference_minutes
FROM runner_orders
WHERE cancellation IS NULL;

--question 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT
    ro.runner_id,
    ro.order_id,
    ro.distance,
    ro.duration,
    CAST(REPLACE(ro.distance, 'km', '') AS FLOAT) / CAST(REPLACE(ro.duration, 'minutes', '') AS FLOAT) AS average_speed_km_per_minute
FROM runner_orders ro
WHERE ro.cancellation IS NULL;

--question 7. What is the successful delivery percentage for each runner?

SELECT
    ro.runner_id,
    COUNT(CASE WHEN ro.cancellation IS NULL THEN 1 ELSE NULL END) AS successful_deliveries,
    COUNT(ro.order_id) AS total_deliveries,
    (COUNT(CASE WHEN ro.cancellation IS NULL THEN 1 ELSE NULL END) * 100.0) / COUNT(ro.order_id) AS successful_delivery_percentage
FROM runner_orders ro
GROUP BY ro.runner_id;

--C. Ingredient Optimisation
--question 1. What are the standard ingredients for each pizza?
-- question 2. What was the most commonly added extra?
SELECT TOP 1
    TRIM(value) AS extra,
    COUNT(*) AS count
FROM customer_orders
CROSS APPLY STRING_SPLIT(extras, ',')
WHERE extras IS NOT NULL AND extras <> 'null'
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;

--question 3. What was the most common exclusion?

SELECT TOP 1
    TRIM(value) AS exclusion,
    COUNT(*) AS count
FROM customer_orders
CROSS APPLY STRING_SPLIT(exclusions, ',')
WHERE exclusions IS NOT NULL AND exclusions <> 'null'
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;

--question 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

SELECT
    co.order_id,
    CONCAT(
        pn.pizza_name,
        CASE WHEN co.exclusions IS NOT NULL THEN ' - Exclude ' + co.exclusions ELSE '' END,
        CASE WHEN co.extras IS NOT NULL THEN ' - Extra ' + co.extras ELSE '' END
    ) AS order_item
FROM
    customer_orders co
LEFT JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id;


--question 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"


--question 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

SELECT
    pt.topping_name,
    SUM(CASE
        WHEN CHARINDEX(pt.topping_name, co.exclusions) = 0 AND CHARINDEX(pt.topping_name, co.extras) = 0 THEN 1
        ELSE 0
    END) AS total_quantity
FROM
    customer_orders co
JOIN
    pizza_toppings pt ON CHARINDEX(pt.topping_name, co.exclusions) = 0 AND CHARINDEX(pt.topping_name, co.extras) = 0
GROUP BY
    pt.topping_name
ORDER BY
    total_quantity DESC;

---D. Pricing and Ratings
--question 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT
    SUM(CASE
        WHEN CONVERT(VARCHAR, pn.pizza_name) = 'Meatlovers' THEN 12
        WHEN CONVERT(VARCHAR, pn.pizza_name) = 'Vegetarian' THEN 10
        ELSE 0
    END) AS total_earnings
FROM
    customer_orders co
JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id;

	--question 2. What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra

SELECT
    SUM(CASE
        WHEN CONVERT(VARCHAR, pn.pizza_name) = 'Meatlovers' THEN 12 + COALESCE(EXTRAS_COUNT, 0)
        WHEN CONVERT(VARCHAR, pn.pizza_name) = 'Vegetarian' THEN 10 + COALESCE(EXTRAS_COUNT, 0)
        ELSE 0
    END) AS total_earnings
FROM
    customer_orders co
JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id
LEFT JOIN (
    SELECT
        pizza_id,
        COUNT(*) * 1 AS EXTRAS_COUNT
    FROM
        customer_orders
    WHERE
        extras LIKE '%Cheese%'
    GROUP BY
        pizza_id
) AS extras ON co.pizza_id = extras.pizza_id;

--question 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

--question 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas

--question 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?


SELECT
    SUM(CASE
        WHEN co.pizza_id = 1 THEN 12
        WHEN co.pizza_id = 2 THEN 10
        ELSE 0
    END) AS total_revenue,
    SUM(ro.distance * 0.30) AS total_expenses,
    SUM(CASE
        WHEN co.pizza_id = 1 THEN 12
        WHEN co.pizza_id = 2 THEN 10
        ELSE 0
    END) - COALESCE(SUM(ro.distance * 0.30), 0) AS net_profit
FROM
    customer_orders co
LEFT JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    co.order_time IS NOT NULL;


---E. Bonus Questions
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

-- Step 1: Add the new pizza to the menu table
INSERT INTO menu (pizza_name)
VALUES ('Supreme');

-- Step 2: Get the pizza_id of the newly added pizza
DECLARE @new_pizza_id INT;
SET @new_pizza_id = SCOPE_IDENTITY();

-- Step 3: Insert the toppings for the new "Supreme" pizza into the pizza_toppings table
-- Assuming the topping_ids for all the toppings in the "Supreme" pizza are 1, 2, 3, 4, 5, 6, 7, 8, 9, and 10
INSERT INTO pizza_toppings (pizza_id, topping_id)
VALUES
    (@new_pizza_id, 1), -- Topping 1
    (@new_pizza_id, 2), -- Topping 2
    (@new_pizza_id, 3), -- Topping 3
    (@new_pizza_id, 4), -- Topping 4
    (@new_pizza_id, 5), -- Topping 5
    (@new_pizza_id, 6), -- Topping 6
    (@new_pizza_id, 7), -- Topping 7
    (@new_pizza_id, 8), -- Topping 8
    (@new_pizza_id, 9), -- Topping 9
    (@new_pizza_id, 10); -- Topping 10

-- Step 4: Insert an order for the new "Supreme" pizza in the customer_orders table
-- Assuming the customer_id and order_id for the new order are 1001 and 10001 respectively
INSERT INTO customer_orders (order_id, customer_id, pizza_id, order_time)
VALUES (10001, 1001, @new_pizza_id, '2023-07-31 12:15:00');

-- Step 5: Insert the runner order for the delivery of the new "Supreme" pizza in the runner_orders table
-- Assuming the runner_id and the runner_order_id for the new delivery are 101 and 5001 respectively
INSERT INTO runner_orders (runner_order_id, order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES (5001, 10001, 101, '2023-07-31 12:30:00', 10.5, 20, NULL);









 
  
   























































































