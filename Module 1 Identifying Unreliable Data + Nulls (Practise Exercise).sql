Exercise 1: Using any methods you like determine if you can you trust this events table.
    SELECT DATE(event_time) AS DAY, count(*) 
    FROM dsv1069.events_201701
    GROUP BY DATE(event_time)
    ORDER BY DATE(event_time)
    --This is the data set for specific month - Jan 2017


Exercise 2:
Using any methods you like, determine if you can you trust this events table. (HINT: When did
we start recording events on mobile)

    SELECT DATE(event_time),  platform , COUNT(*)
    FROM dsv1069.events_ex2
    group by  DATE(event_time), platform
    --Not Trusted dataset as it's exercise, and mobile web maybe not recorded earlier


Exercise 3: Imagine that you need to count item views by day. You found this table
item_views_by_category_temp - should you use it to answer your questiuon?

    SELECT * 
    FROM dsv1069.item_views_by_category_temp
    -- There is no date columns, no way to check by day.


Exercise 5: Is this the right way to join orders to users? Is this the right way this join.
    SELECT *
    FROM dsv1069.users
    LEFT JOIN dsv1069.orders
    ON COALESCE(users.parent_user_id, id)= orders.user_id
