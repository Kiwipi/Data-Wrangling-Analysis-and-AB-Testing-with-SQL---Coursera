Exercise 1:
--Using the table from Exercise 4.3 and compute a metric that measures
--Whether a user created an order after their test assignment
--Requirements: Even if a user had zero orders, we should have a row that counts
-- their number of orders as zero
--If the user is not in the experiment they should not be included

        SELECT 
            test_assignment.user_id,
            test_id, 
            test_assignment,
            MAX(CASE WHEN orders.paid_at > event_time THEN invoice_id ELSE NULL END ) AS invoice_id,
            MAX(CASE WHEN orders.paid_at > event_time THEN 1 ELSE 0 END ) AS orders_after_binary
        FROM 
            (
            SELECT 
            event_id,
            event_time, 
            MAX(CASE WHEN parameter_name = 'test_id' THEN CAST (parameter_value AS INT) ELSE NULL END ) AS test_id,
            MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value ELSE NULL END ) AS test_assignment,
            user_id
            FROM dsv1069.events 
            WHERE event_name = 'test_assignment'
            GROUP BY 
            event_id,
            event_time, 
            user_id
            ) test_assignment
        LEFT JOIN 
            dsv1069.orders
        ON 
            orders.user_id = test_assignment.user_id 
        GROUP BY 
            test_assignment.user_id,
            test_id, 
            test_assignment

Exercise 2:
--Using the table from the previous exercise, add the following metrics
--1) the number of orders/invoices
--2) the number of items/line-items ordered
--3) the total revenue from the order after treatment

        SELECT 
            test_assignment.user_id,
            test_id, 
            test_assignment,
            COUNT (DISTINCT (CASE WHEN orders.paid_at > event_time THEN invoice_id ELSE NULL END )) AS invoice_ordered,
            COUNT(DISTINCT (CASE WHEN orders.paid_at > event_time THEN line_item_id ELSE NULL END )) AS line_items_ordered, 
            SUM (CASE WHEN orders.paid_at > event_time THEN price ELSE 0 END ) total_revenue
        FROM 
            (
            SELECT 
            event_id,
            event_time, 
            MAX(CASE WHEN parameter_name = 'test_id' THEN CAST (parameter_value AS INT) ELSE NULL END ) AS test_id,
            MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value ELSE NULL END ) AS test_assignment,
            user_id
            FROM dsv1069.events 
            WHERE event_name = 'test_assignment'
            GROUP BY 
            event_id,
            event_time, 
            user_id
            ) test_assignment
        LEFT JOIN 
            dsv1069.orders
        ON 
            orders.user_id = test_assignment.user_id 
        GROUP BY 
            test_assignment.user_id,
            test_id, 
            test_assignment
