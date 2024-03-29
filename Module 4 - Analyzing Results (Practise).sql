Exercise 1: Use the order_binary metric from the previous exercise, count the number of users per treatment group for test_id = 7, 
and count the number of users with orders (for test_id 7)

        SELECT 
        test_assignment,
        COUNT(DISTINCT user_id) AS users,
        SUM (orders_after_binary) AS users_with_orders
        FROM 
                (
                SELECT 
                    test_assignment.user_id,
                    test_id, 
                    test_assignment,
                    MAX(CASE WHEN orders.created_at > event_time THEN invoice_id ELSE NULL END ) AS invoice_id,
                    MAX(CASE WHEN orders.created_at > event_time THEN 1 ELSE 0 END ) AS orders_after_binary
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
                ) order_binary
        WHERE 
            test_id=7
        GROUP BY 
            test_assignment

Results:
AB testing tool show p-value is 0.059 which is good!
0	19376	2522
1	19271	2634

Exercise 2: Create a new tem view binary metric. Count the number of users per treatment group, and count the number of users with views (for test_id 7)

        SELECT 
        test_assignment,
        COUNT(DISTINCT user_id) AS users,
        SUM (view_after_binary) AS users_with_views
        FROM 
                (
                SELECT 
                    test_assignment.user_id,
                    test_id, 
                    test_assignment,
                    MAX(CASE WHEN test_assignment.event_time < view_item_table.event_time THEN 1 ELSE 0 END ) AS view_after_binary
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
                    (
                    SELECT *
                    FROM dsv1069.events
                    WHERE event_name = 'view_item'
                    ) view_item_table
                ON 
                    view_item_table.user_id = test_assignment.user_id 
                GROUP BY 
                    test_assignment.user_id,
                    test_id, 
                    test_assignment
                ) view_binary
        WHERE 
            test_id=7
        GROUP BY 
            test_assignment

Results: 
NOT GOOD
The P-Value is 0.463 Hence, your results are NOT statistically significant!
0	19376	10290
1	19271	10271


Exercise 3: Alter the result from EX 2, to compute the users who viewed an item WITHIN 30
days of their treatment event

                SELECT 
                        test_assignment,
                        COUNT(user_id) AS users,
                        SUM (view_after_binary) AS users_with_views,
                        SUM (view_within_30d) AS users_with_views_winth_30d
                FROM
                (
                        SELECT 
                            test_assignment.user_id,
                            test_id, 
                            test_assignment,
                            MAX(CASE WHEN view_item_table.event_time > test_assignment.event_time THEN 1 ELSE 0 END ) AS view_after_binary,
                            MAX(CASE WHEN view_item_table.event_time > test_assignment.event_time AND 
                                          DATE_PART ('day', view_item_table.event_time - test_assignment.event_time) <=30
                                          THEN 1 ELSE 0 END ) AS view_within_30d
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
                (
                SELECT *
                FROM dsv1069.events
                WHERE event_name = 'view_item'
                ) view_item_table
            ON 
                view_item_table.user_id = test_assignment.user_id 
            GROUP BY 
                test_assignment.user_id,
                test_id, 
                test_assignment
            ) view_binary
    WHERE 
        test_id=7
    GROUP BY 
        test_assignment

Results:
The P-Value is 0.38 Hence, your results are not statistically significant!
0	19376	10290	245
1	19271	10271	237


Exercise 4:
Create the metric invoices (this is a mean metric, not a binary metric) and for test_id = 7
----The count of users per treatment group
----The average value of the metric per treatment group
----The standard deviation of the metric per treatment group

        SELECT 
        test_assignment,
        COUNT(DISTINCT user_id) AS users,
        SUM (invoices_count) AS total_invoices, 
        AVG(invoices_count) AS avg_orders,
        STDDEV_SAMP (invoices_count) AS std_orders_sam
        FROM 
        (   
            SELECT 
                test_assignment_table.user_id,
                test_assignment_table.test_assignment,
                test_assignment_table.test_id,
                COUNT (DISTINCT (CASE WHEN test_assignment_table.event_time < orders.paid_at THEN orders.invoice_id ELSE NULL END)) AS invoices_count
            FROM 
            (
                SELECT 
                    event_id, 
                    event_name,
                    event_time,
                    MAX(CASE WHEN parameter_name = 'test_assignment' THEN CAST (parameter_value AS INT ) ELSE NULL END)  AS test_assignment, 
                    MAX(CASE WHEN parameter_name = 'test_id' THEN CAST (parameter_value AS INT ) ELSE NULL END)  AS test_id, 
                    platform,
                    user_id
                FROM     
                    dsv1069.events
                WHERE 
                    event_name= 'test_assignment'
                GROUP BY 
                    event_id, 
                    event_name,
                    event_time,
                    platform,
                    user_id
            ) test_assignment_table
            LEFT JOIN 
                dsv1069.orders
            ON 
                orders.user_id = test_assignment_table.user_id
            GROUP BY 
                test_assignment_table.user_id,
                test_assignment_table.test_assignment,
                test_assignment_table.test_id
        ) invoice_count_table
        WHERE 
            test_id = 7
        GROUP BY 
            test_assignment,
            test_id
