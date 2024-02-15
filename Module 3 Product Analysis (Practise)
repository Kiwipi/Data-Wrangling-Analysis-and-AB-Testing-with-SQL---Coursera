Exercise 0: Count how many users we have

    SELECT 
        COUNT(DISTINCT id) AS users_num
    FROM 
        dsv1069.users


Exercise 1: Find out how many users have ever ordered

        SELECT 
            COUNT(DISTINCT users.id) AS users_num_have_ordered
        FROM 
            dsv1069.users
        JOIN 
            dsv1069.orders
        ON 
            users.id = orders.user_id


Exercise 2:
--Goal find how many users have reordered the same item

    SELECT 
        COUNT(DISTINCT user_id) AS users_num_who_have_reordered
    FROM 
        (
        SELECT 
            user_id, item_id, item_category, COUNT(DISTINCT line_item_id) AS times_ordered
        FROM 
            dsv1069.orders
        GROUP BY 
            user_id, item_id, item_category
        ) 
        times_ordered_table
    WHERE 
        times_ordered_table.times_ordered >1

Exercise 3:
--Do users even order more than once?

    SELECT 
        COUNT(user_id) AS users_num_ordered_multiple_times
    FROM 
        (
        SELECT 
            user_id, COUNT(DISTINCT invoice_id) AS order_num
        FROM 
            dsv1069.orders
        GROUP BY 
            user_id
        ) order_num_table
    WHERE 
        order_num_table.order_num >1


Exercise 4:
--Orders per item

        SELECT 
            item_id, COUNT(DISTINCT line_item_id) AS order_times
        FROM 
            dsv1069.orders
        GROUP BY 
            item_id
        ORDER BY 
            order_times DESC

Exercise 5:
--Orders per category

        SELECT 
            DISTINCT item_category, COUNT(item_category) AS category_items
        FROM 
            dsv1069.orders
        GROUP BY 
            item_category
        ORDER BY 
            category_items DESC

Exercise 6:
--Goal: Do user order multiple things from the same category?

        Yes, there are total AVERAGE more than 1300 users have ordered multiple things from the same category, average 3 items have been ordered in the same catagory:

        SELECT 
            item_category, COUNT(DISTINCT user_id) AS users_num, AVG(line_item_category_table.line_items_ordered) AS avg_ordered_times_per_category
        FROM 
            (
            SELECT 
                user_id, item_category, COUNT(DISTINCT line_item_id) AS line_items_ordered
            FROM 
                dsv1069.orders
            GROUP BY 
                user_id, item_category
            )  line_item_category_table
        WHERE 
                line_item_category_table.line_items_ordered >1 
        GROUP BY 
                item_category


Exercise 7:
--Goal: Find the average time between orders
--Decide if this analysis is necessary

        The result shows there is no consistant patern of days difference, so I think there is no need to investigate further the dataset.

        SELECT 
            first_order_table.user_id,
            DATE(first_order_table.paid_at) AS first_paid,
            DATE(second_order_table.paid_at) AS second_paid,
            DATE(second_order_table.paid_at) - DATE(first_order_table.paid_at) AS different_days
        FROM 
            (
            SELECT 
                user_id, invoice_id, paid_at, DENSE_RANK() OVER (PARTITION BY user_id ORDER BY paid_at ) as order_num
            FROM 
                dsv1069.orders
            ) first_order_table
            JOIN 
            (
            SELECT 
                user_id, invoice_id, paid_at, DENSE_RANK() OVER (PARTITION BY user_id ORDER BY paid_at ) as order_num
            FROM 
                dsv1069.orders
            ) second_order_table
        ON 
            first_order_table.user_id =  second_order_table.user_id 
        WHERE 
            second_order_table.order_num =2
        AND 
            first_order_table.order_num=1


