Exercise 1: Create a subtable of orders per day. Make sure you decide whether you are
counting invoices or line items.

    SELECT 
        DATE(paid_at) AS day, 
        COUNT(DISTINCT invoice_id) AS order_num,  
        COUNT(DISTINCT line_item_id) AS line_item_count
    FROM 
        dsv1069.orders
    GROUP BY day
    ORDER BY day

Exercise 2: “Check your joins”. We are still trying to count orders per day. In this step join the
sub table from the previous exercise to the dates rollup table so we can get a row for every
date. Check that the join works by just running a “select *” query

    SELECT *
    FROM dsv1069.dates_rollup  
    LEFT JOIN 
        (
            SELECT 
                DATE(paid_at) AS day, 
                COUNT(DISTINCT invoice_id) AS order_num,  
                COUNT(DISTINCT line_item_id) AS line_item_count
            FROM dsv1069.orders
            GROUP BY day
            ORDER BY day
        ) orders
    ON orders.day = dates_rollup.date

Exercise 3: “Clean up your Columns” In this step be sure to specify the columns you actually
want to return, and if necessary do any aggregation needed to get a count of the orders made
per day.

    SELECT 
        DATE(dates_rollup.date) AS everyday, 
        SUM(orders.order_num) AS orders,
        SUM(orders.line_item_count) AS line_items_ordered
    FROM 
        dsv1069.dates_rollup  
    LEFT JOIN 
        (
            SELECT 
                DATE(paid_at) AS day, 
                COUNT(DISTINCT invoice_id) AS order_num,  
                COUNT(DISTINCT line_item_id) AS line_item_count
            FROM dsv1069.orders
            GROUP BY day
            ORDER BY day
        ) orders
    ON orders.day = DATE(dates_rollup.date)
    GROUP BY DATE(dates_rollup.date)

Exercise 4: Weekly Rollup. Figure out which parts of the JOIN condition need to be edited
create 7 day rolling orders table.
Starter Code: Result from EX2 or EX3

    SELECT 
        DATE(dates_rollup.date) AS everyday,
        DATE(dates_rollup.d7_ago) AS aweek_ago,
        COALESCE(SUM(orders.order_num), 0) AS orders,
        COALESCE(SUM(orders.line_item_count), 0) AS line_items_ordered,
        COUNT(*) AS rows_count
    FROM 
        dsv1069.dates_rollup  
    LEFT JOIN 
        (
        SELECT 
            DATE(paid_at) AS day, 
            COUNT(DISTINCT invoice_id) AS order_num,  
            COUNT(DISTINCT line_item_id) AS line_item_count
            FROM dsv1069.orders
            GROUP BY day
            ORDER BY day
        ) orders
    ON orders.day <= DATE(dates_rollup.date)
    AND orders.day > DATE(dates_rollup.d7_ago)
    GROUP BY DATE(dates_rollup.date), DATE(dates_rollup.d7_ago)


Exercise 5: Column Cleanup. Finish creating the weekly rolling orders table, by performing
any aggregation steps and naming your columns appropriately.

    SELECT 
        DATE(dates_rollup.date) AS everyday,
        COALESCE(SUM(orders.order_num), 0) AS orders,
        COALESCE(SUM(orders.line_item_count), 0) AS line_items_ordered
    FROM dsv1069.dates_rollup  
    LEFT JOIN 
        (
        SELECT 
            DATE(paid_at) AS day, 
            COUNT(DISTINCT invoice_id) AS order_num,  
            COUNT(DISTINCT line_item_id) AS line_item_count
        FROM dsv1069.orders
        GROUP BY day
        ORDER BY day
        ) orders
    ON orders.day <= DATE(dates_rollup.date)
    AND orders.day > DATE(dates_rollup.d7_ago)
    GROUP BY DATE(dates_rollup.date)
    ORDER BY DATE(dates_rollup.date)

