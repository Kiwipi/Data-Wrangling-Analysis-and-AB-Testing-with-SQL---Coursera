Exercise 1: We’ll be using the users table to answer the question “How many new users are
added each day?“. Start by making sure you understand the columns in the table
Exercise 2: WIthout worrying about deleted user or merged users, count the number of users
added each day.

    SELECT 
        DATE(created_at) AS day, 
        count(*) AS daily_added_users
    FROM 
        dsv1069.users
    GROUP BY 
        DATE(created_at)
    ORDER BY 
        DATE(created_at)

Exercise 3: Consider the following query. Is this the right way to count merged or deleted
users? If all of our users were deleted tomorrow what would the result look like?

    SELECT 
        DATE(created_at) AS day, count(*) AS daily_added_users
    FROM 
        dsv1069.users
    WHERE 
        deleted_at IS NULL 
    AND 
        (id <> parent_user_id OR parent_user_id IS NULL)
    GROUP BY 
        DATE(created_at)
    ORDER BY 
        DATE(created_at)


Exercise 4: Count the number of users deleted each day. Then count the number of users
removed due to merging in a similar way

--daily_deleted_users counting
    SELECT 
        date(deleted_at) AS day, count(*) AS daily_deleted_users
    FROM 
        dsv1069.users
    WHERE 
        deleted_at IS NOT NULL 
    GROUP BY 
        DATE(deleted_at)
    ORDER BY 
        DATE(deleted_at)

--daily_merged_user counting
    SELECT 
        DATE(merged_at) AS day, count(*) AS daily_merged_user
    FROM 
        dsv1069.users
    WHERE 
        merged_at IS NOT NULL 
    GROUP BY 
        DATE(merged_at)
    ORDER BY    
        DATE(merged_at)
    ) merged_users_table

Exercise 5: Use the pieces you’ve built as subtables and create a table that has a column for
the date, the number of users created, the number of users deleted and the number of users
merged that day

    SELECT 
        new_users_table.day, new_users_table.daily_added_users, deleted_users_table.daily_deleted_users, merged_users_table.daily_merged_user
    FROM
    (
        SELECT DATE(created_at) AS day, count(*) AS daily_added_users
        FROM dsv1069.users
        WHERE deleted_at IS NULL 
        AND (id <> parent_user_id OR parent_user_id IS NULL)
        GROUP BY DATE(created_at)
        ORDER BY DATE(created_at)
    ) new_users_table
    LEFT JOIN 
    (
        SELECT date(deleted_at) AS day, count(*) AS daily_deleted_users
        FROM dsv1069.users
        WHERE deleted_at IS NOT NULL 
        GROUP BY DATE(deleted_at)
        ORDER BY DATE(deleted_at)
    ) deleted_users_table
    ON 
        new_users_table.day= deleted_users_table.day 
    LEFT JOIN 
    (
        SELECT DATE(merged_at) AS day, count(*) AS daily_merged_user
        FROM dsv1069.users
        WHERE id <> parent_user_id
        AND merged_at IS NOT NULL 
        GROUP BY DATE(merged_at)
        ORDER BY DATE(merged_at)
    ) merged_users_table
    ON 
        merged_users_table.day = new_users_table.day

Exercise 6: Refine your query from #5 to have informative column names and so that null
columns return 0.

SELECT 
new_users_table.day, 
new_users_table.daily_added_users, 
COALESCE(deleted_users_table.daily_deleted_users, 0) AS deleted_users, 
COALESCE(merged_users_table.daily_merged_user, 0) AS Merged_users,
(new_users_table.daily_added_users - COALESCE(deleted_users_table.daily_deleted_users, 0) - COALESCE(merged_users_table.daily_merged_user, 0)) AS final_added_users
FROM
(
    SELECT DATE(created_at) AS day, count(*) AS daily_added_users
    FROM dsv1069.users
    WHERE deleted_at IS NULL 
    AND (id <> parent_user_id OR parent_user_id IS NULL)
    GROUP BY DATE(created_at)
    ORDER BY DATE(created_at)
) new_users_table
LEFT JOIN 
(
    SELECT date(deleted_at) AS day, count(*)AS daily_deleted_users
    FROM dsv1069.users
    WHERE deleted_at IS NOT NULL 
    GROUP BY DATE(deleted_at)
    ORDER BY DATE(deleted_at)
) deleted_users_table
ON 
    new_users_table.day= deleted_users_table.day 
LEFT JOIN 
(
    SELECT DATE(merged_at) AS day, count(*) AS daily_merged_user
    FROM dsv1069.users
    WHERE id <> parent_user_id
    OR merged_at IS NOT NULL 
    GROUP BY DATE(merged_at)
    ORDER BY DATE(merged_at)
) merged_users_table
ON 
    merged_users_table.day = new_users_table.day


Exercise 7:
What if there were days where no users were created, but some users were deleted or merged.
Does the previous query still work? No, it doesn’t. Use the dates_rollup as a backbone for this
query, so that we won’t miss any dates.

    SELECT 
    dates_rollup.date, 
    COALESCE(new_users_table.daily_added_users, 0) AS added_users,
    COALESCE(deleted_users_table.daily_deleted_users, 0) AS deleted_users, 
    COALESCE(merged_users_table.daily_merged_user, 0) AS Merged_users,
    (COALESCE(new_users_table.daily_added_users, 0) - COALESCE(deleted_users_table.daily_deleted_users, 0) - COALESCE(merged_users_table.daily_merged_user, 0)) AS net_added_users
    FROM
        dsv1069.dates_rollup
    LEFT JOIN 
    (
        SELECT DATE(created_at) AS day, count(*) AS daily_added_users
        FROM dsv1069.users
        WHERE deleted_at IS NULL 
        AND (id <> parent_user_id OR parent_user_id IS NULL)
        GROUP BY DATE(created_at)
        ORDER BY DATE(created_at)
    ) new_users_table
    ON 
        dates_rollup.date = new_users_table.day
    LEFT JOIN 
    (
        SELECT date(deleted_at) AS day, count(*)AS daily_deleted_users
        FROM dsv1069.users
        WHERE deleted_at IS NOT NULL 
        GROUP BY DATE(deleted_at)
        ORDER BY DATE(deleted_at)
    ) deleted_users_table
    ON 
        new_users_table.day= deleted_users_table.day 
    LEFT JOIN 
    (
        SELECT DATE(merged_at) AS day, count(*) AS daily_merged_user
        FROM dsv1069.users
        WHERE id <> parent_user_id
        OR merged_at IS NOT NULL 
        GROUP BY DATE(merged_at)
        ORDER BY DATE(merged_at)
    ) merged_users_table
    ON 
        merged_users_table.day = dates_rollup.date
