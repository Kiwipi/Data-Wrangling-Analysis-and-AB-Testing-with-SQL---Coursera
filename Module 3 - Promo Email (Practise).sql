Exercise 1:
Create the right subtable for recently viewed events using the view_item_events table.

    SELECT 
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC ) AS view_number,
        event_id, 
        event_time, 
        item_id,
        user_id
    FROM dsv1069.view_item_events

Exercise 2: Check your joins. Join your tables together recent_views, users, items
Starter Code: The result from Ex1

    SELECT *
    FROM 
        dsv1069.users
    JOIN
    (
        SELECT ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC ) AS view_number,
        event_id, 
        event_time, 
        item_id,
        user_id
        FROM dsv1069.view_item_events
    ) recent_views
    ON 
        recent_views.user_id = users.id 
    JOIN 
        dsv1069.items 
    ON 
        items.id = recent_views.item_id


Exercise 3: Clean up your columns. The goal of all this is to return all of the information we’ll
need to send users an email about the item they viewed more recently. Clean up this query
outline from the outline in EX2 and pull only the columns you need. Make sure they are named
appropriately so that another human can read and understand their contents.
Starter Code: Code from Ex2

    SELECT 
        recent_views.view_number,
        COALESCE(parent_user_id, users.id) AS user_id,
        users.email_address AS email, 
        items.id AS item_id,
        items.category AS items_category,
        items.name
    FROM 
        dsv1069.users
    JOIN
        (
            SELECT ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC ) AS view_number,
            event_id, 
            event_time, 
            item_id,
            user_id
            FROM dsv1069.view_item_events
        ) recent_views
    ON 
        recent_views.user_id = users.id 
    JOIN 
        dsv1069.items 
    ON 
        items.id = recent_views.item_id


Exercise 4: Consider any edge cases. If we sent an email to everyone in the results of this
query, what would we want to filter out. Add in any extra filtering that you think would make this
email better. For example should we include deleted users? Should we send this email to users
who already ordered the item they viewed most recently?

    SELECT 
        recent_views.view_number,
        recent_views.event_time, 
        COALESCE(parent_user_id, users.id) AS user_id,
        users.email_address, 
        items.id AS item_id,
        items.category AS items_category,
        items.name AS items_name
    FROM 
        dsv1069.users
    JOIN
        (
        SELECT 
            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC ) AS view_number,
            event_id, 
            event_time, 
            item_id,
            user_id
        FROM 
            dsv1069.view_item_events
        WHERE 
            event_time > '2018-01-01'
        ORDER BY 
            event_time DESC
        ) recent_views
    ON 
        recent_views.user_id = users.id 
    JOIN 
        dsv1069.items 
    ON 
        items.id = recent_views.item_id
    LEFT JOIN 
        dsv1069.orders
    ON 
        orders.user_id = users.id
    AND 
        orders.item_id = recent_views.item_id
    WHERE 
        users.deleted_at IS NULL
    AND 
        users.id <> users.parent_user_id 
    AND 
        orders.item_id IS NULL 
