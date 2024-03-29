Exercise 1:
Goal: Here we use users table to pull a list of user email addresses. Edit the query to pull email
addresses, but only for non-deleted users.
    
    SELECT 
        id, email_address
    FROM 
        dsv1069.users
    WHERE 
        deleted_at IS NULL;



Exercise 2:
--Goal: Use the items table to count the number of items for sale in each category
Starter Code: (none)

    SELECT 
        category, count(id) AS sold_item_num
    FROM 
        dsv1069.items
    GROUP BY 
        category



Exercise 3:
--Goal: Select all of the columns from the result when you JOIN the users table to the orders
table

    SELECT *
    FROM dsv1069.users u 
    JOIN dsv1069.orders o 
    ON o.user_id=u.id


Exercise 4:
--Goal: Check out the query below. This is not the right way to count the number of viewed_item
events. Determine what is wrong and correct the error.

    SELECT COUNT(DISTINCT event_id)
    FROM dsv1069.events 
    WHERE event_name= 'view_item'


Exercise 5:
--Goal:Compute the number of items in the items table which have been ordered. The query
below runs, but it isn’t right. Determine what is wrong and correct the error or start from scratch.

    SELECT COUNT(DISTINCT id) AS item_count
    FROM dsv1069.items 


Exercise 6:
--Goal: For each user figure out IF a user has ordered something, and when their first purchase
was. The query below doesn’t return info for any of the users who haven’t ordered anything.

    SELECT u.id, MIN(o.paid_at) AS first_purchase_day
    FROM dsv1069.users u 
    LEFT JOIN dsv1069.orders o 
    ON u.id=o.user_id 
    GROUP BY u.id

Exercise 7:
--Goal: Figure out what percent of users have ever viewed the user profile page, but this query
isn’t right. Check to make sure the number of users adds up, and if not, fix the query

    SELECT 
    (CASE WHEN first_view_table.first_view IS NULL THEN false ELSE true END) AS has_view_profile, COUNT(First_view_table.id)
    FROM
        (
        SELECT u.id, MIN(e.event_time) AS first_view
        FROM dsv1069.users u 
        LEFT JOIN dsv1069.events e 
        ON u.id=e.user_id
        AND e.event_name='view_user_profile'
        GROUP BY u.id 
        ) First_view_table
    group by has_view_profile
