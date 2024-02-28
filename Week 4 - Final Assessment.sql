We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ. Please follow the steps below and good luck!

--We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ.
--Compare this table to the assignment events we captured for user_level_testing.
--Does this table have everything you need to compute metrics like 30-day view-binary?
1. Compare the final_assignments_qa table to the assignment events we captured for user_level_testing. Write an answer to the following question: Does this table have everything you need to compute metrics like 30-day view-binary?

 SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa

 
 --Reformat the final_assignments_qa to look like the final_assignments table, filling in any missing values with a placeholder of the appropriate data type.
 2. Write a query and table creation statement to make final_assignments_qa look like the final_assignments table. If you discovered something missing in part 1, you may fill in the value with a place holder of the appropriate data type. 

SELECT 
  item_id,
  test_a AS test_assignment,
  (CASE WHEN test_a IS NOT NULL THEN 'test_a' ELSE NULL END ) AS test_number,
  (CASE WHEN test_a IS NOT NULL THEN '2013-01-05' ELSE NULL END ) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION 
SELECT 
  item_id,
  test_b AS test_assignment,
  (CASE WHEN test_b IS NOT NULL THEN 'test_b' ELSE NULL END ) AS test_number,
  (CASE WHEN test_b IS NOT NULL THEN '2013-01-05' ELSE NULL END ) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION 
SELECT 
  item_id,
  test_c AS test_assignment,
  (CASE WHEN test_c IS NOT NULL THEN 'test_c' ELSE NULL END ) AS test_number,
  (CASE WHEN test_c IS NOT NULL THEN '2013-01-05' ELSE NULL END ) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION 
SELECT 
  item_id,
  test_d AS test_assignment,
  (CASE WHEN test_d IS NOT NULL THEN 'test_d' ELSE NULL END ) AS test_number,
  (CASE WHEN test_d IS NOT NULL THEN '2013-01-05' ELSE NULL END ) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION 
SELECT 
  item_id,
  test_e AS test_assignment,
  (CASE WHEN test_e IS NOT NULL THEN 'test_e' ELSE NULL END ) AS test_number,
  (CASE WHEN test_e IS NOT NULL THEN '2013-01-05' ELSE NULL END ) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION 
SELECT 
  item_id,
  test_f AS test_assignment,
  (CASE WHEN test_f IS NOT NULL THEN 'test_f' ELSE NULL END ) AS test_number,
  (CASE WHEN test_f IS NOT NULL THEN '2013-01-05' ELSE NULL END ) AS test_start_date
FROM 
  dsv1069.final_assignments_qa


3. Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2 (You may include the day the test started)
-- Use this table to 
-- compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT 
test_assignment,
COUNT (DISTINCT item_id) AS items_count,
SUM(order_binary) AS orders_after_tested
FROM
(
  SELECT 
    item_id,
    test_assignment,
    MAX (CASE WHEN created_at > test_start_date AND 
               DATE_PART('day', created_at - test_start_date) <=30
               THEN 1 ELSE 0 END ) AS order_binary
FROM 
(
    SELECT 
      final_assignments.item_id, 
      final_assignments.test_assignment, 
      final_assignments.test_start_date,
      orders.created_at 
    FROM 
      dsv1069.final_assignments
    LEFT JOIN 
      dsv1069.orders
    ON 
      orders.item_id = final_assignments.item_id
    WHERE 
      final_assignments.test_number = 'item_test_2'
) all_item_2
GROUP BY 
    item_id,
    test_assignment
) order_binary
GROUP BY 
test_assignment

 Results: 
0	1130	341
1	1068	319

 -- Don't know why the result figures are not the same, anyone who can explain this?

4. Use the final_assignments table to calculate the view binary, and average views for the 30 day window after the test assignment for item_test_2. (You may include the day the test started)
-- Use this table to 
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT 
  test_assignment,
  COUNT(DISTINCT item_id) AS total_items,
  SUM (view_binary ) AS total_views,
  AVG(view_binary ) AS avg_views
FROM 
(
  SELECT 
      final_assignments.item_id,
      final_assignments.test_assignment,
      final_assignments.test_number,
      MAX (CAST(CASE 
          WHEN (view_item.event_time > final_assignments.test_start_date AND 
                  DATE_PART('day', view_item.event_time - final_assignments.test_start_date) <=30 )
          THEN 1 
          ELSE 0 
          END AS INT) )AS view_binary
    FROM 
      dsv1069.final_assignments 
  LEFT JOIN 
  (  
      SELECT 
        event_time,
        (CASE WHEN parameter_name= 'item_id' THEN CAST (parameter_value AS INT) ELSE NULL END ) AS item_id
      FROM 
        dsv1069.events 
      WHERE 
        event_name = 'view_item'
  ) view_item
  ON 
    view_item.item_id = final_assignments.item_id
  WHERE
    final_assignments.test_number = 'item_test_2'
  GROUP BY 
    final_assignments.item_id,
    final_assignments.test_assignment,
    final_assignments.test_number
  ORDER BY 
    final_assignments.item_id 
    ) view_binary
GROUP BY 
  test_assignment

 RESULTS:
0	1130	918	0.8124
1	1068	890	0.8333


5. Use the https://thumbtack.github.io/abba/demo/abba.html
 to compute the lifts in metrics and the p-values for the binary metrics ( 30 day order binary and 30 day view binary) using a interval 95% confidence. 

 SELECT 
  test_number,
  test_assignment,
  COUNT(DISTINCT item_id) AS total_items,
  SUM(view_30d_binary) AS view_binary,
  SUM (order_binary) AS orders_binary
FROM 
(
  SELECT 
    order_30d_binary.item_id,
    order_30d_binary.test_assignment,
    order_30d_binary.test_number,
    order_30d_binary.order_binary AS order_binary,
    MAX (CASE WHEN view_item_events.event_time > order_30d_binary.test_start_date AND 
                    DATE_PART('day', view_item_events.event_time - order_30d_binary.test_start_date) <= 30 
                    THEN 1 
                    ELSE 0 
                    END ) AS view_30d_binary
  FROM 
      (
      SELECT 
        final_assignments.item_id,
        final_assignments.test_assignment,
        final_assignments.test_number,
        final_assignments.test_start_date,
        orders.created_at,
        MAX (CASE WHEN orders.created_at > final_assignments.test_start_date AND 
                       DATE_PART('day', orders.created_at - final_assignments.test_start_date) <= 30 
                       THEN 1 
                       ELSE 0 
                       END ) AS order_binary
      FROM 
        dsv1069.final_assignments
      LEFT JOIN 
        dsv1069.orders
      ON 
        orders.item_id = final_assignments.item_id 
      GROUP BY  
        final_assignments.item_id,
        final_assignments.test_assignment,
        final_assignments.test_number,
        final_assignments.test_start_date,
        orders.created_at
      ) order_30d_binary
  LEFT JOIN 
    dsv1069.view_item_events
  ON 
    view_item_events.item_id = order_30d_binary.item_id
  GROUP BY 
    order_30d_binary.item_id,
    order_30d_binary.test_assignment,
    order_30d_binary.test_number,
    order_30d_binary.order_binary
  ) view_binary
GROUP by 
  test_number,
  test_assignment
ORDER BY 
  test_number ASC 

RESULTS:
1	item_test_1	0	1112	0	0
2	item_test_1	1	1086	0	0
3	item_test_2	0	1130	1262	341
4	item_test_2	1	1068	1211	319
5	item_test_3	0	1075	1312	364
6	item_test_3	1	1123	1336	348


6. Use Mode’s Report builder feature to write up the test. Your write-up should include a title, a graph for each of the two binary metrics you’ve calculated. The lift and p-value (from the AB test calculator) for each of the two metrics, and a complete sentence to interpret the significance of each of the results.
 
My answers: 
After analyzing the results of the AB Testing tool for item_test_2, the obtained P-value of 0.88 indicates insufficient evidence to support a successful impact from the test assignment. 
The success rates for both Control and Variant groups are nearly identical, standing at 28%-33% for the Control group and 27%-33% for the Variant group. 
Unfortunately, the Variant group's success rate doesn't show a significant improvement over the Control group, suggesting minimal real-world impact.

Considering the range of improvement rates from -14% to 12%, it becomes apparent that the negative impact could potentially outweigh any positive effects. 
 In my opinion, the data does not advocate for implementing a change.

Similar findings are observed for item_test_3, where there is no substantial evidence indicating an increase in orders post-testing. 
Therefore, the conclusion drawn is that no change is needed.

However, I didn't get the right figures of view binary matric, so I can't make any comment on this.Please comment and give any suggestion. Thank you!
 
