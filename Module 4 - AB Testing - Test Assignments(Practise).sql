AB TESTING 

# Case Study 1  - User Welcome Email
Goals -  update the designs to include images and links to our top selling items
Eligibility - users who’ve created an account recently with a valid email address
Diversion point - when the automated email is scheduled to be sent
Control - Get the existing emails
Treatment - Get new email with images top sellers

Engagement Metrics:
Email opens
Email clicks
Orders placed
Total number of orders placed
Revenue 

# Case Study 2 - Push Notification to Mobile Users
Goals - Push notification to users with items in their carts, have not completed order after 24 hours, only if they haven’t received a push notification in last 2 weeks
Eligibility - User with a view_item event on a mobile device, who have added items to their carts in the last 24 hours, but havn't received any recent push notifications.
Control - No push notification
Treament - Personalised push about items in the cart

Engagement Metrics:
Push notification opens
Mobile app visits
Items views
Orders completed 
Total orders placed
Revenue 


Exercise 1: Figure out how many tests we have running right now

  SELECT 
      COUNT(DISTINCT parameter_value) AS tests
  FROM 
      dsv1069.events
  WHERE 
      event_name= 'test_assignment'
  AND 
      parameter_name = 'test_id'
Results: Total 4 tests running now.


Exercise 2: Check for potential problems with test assignments. For example Make sure there is no data obviously missing (This is an open ended question)

There is no dates missing during testing for each test id from below data.
    SELECT 
          DATE(event_time), 
          parameter_value AS test_id,
          COUNT(*) AS event_times
    FROM 
        dsv1069.events
    WHERE 
        event_name= 'test_assignment'
    AND 
        parameter_name = 'test_id'
    GROUP BY 
        DATE(event_time), test_id


Exercise 3: Write a query that returns a table of assignment events.Please include all of the relevant parameters as columns (Hint: A previous exercise as a template)

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

Exercise 4: Check for potential assignment problems with test_id 5. Specifically, make sure users are assigned only one treatment group. 

    SELECT 
        user_id,
        COUNT(DISTINCT test_assignment) AS assignments
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
        ORDER BY date(event_time)
        ) test_table
    WHERE 
        test_table.test_id =5
    GROUP BY 
        user_id
    ORDER BY 
        assignments DESC
