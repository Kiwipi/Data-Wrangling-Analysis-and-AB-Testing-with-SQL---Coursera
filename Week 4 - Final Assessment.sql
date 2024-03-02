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

--FROM KAT

 SELECT 
  item_id,
  test_a       AS test_assignment, 
  'test_a'     AS test_number, 
  '2020-01-01' AS test_start_date
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

 -- FROM KAT
SELECT
  test_assignment,
  COUNT(item_id) as items,
  SUM(order_binary_30d) AS ordered_items_30d
FROM
(
  SELECT 
   fa.test_assignment,
   fa.item_id, 
   MAX(CASE WHEN orders.created_at > fa.test_start_date THEN 1 ELSE 0 END)  AS order_binary_30d
  FROM 
    dsv1069.final_assignments fa
    
  LEFT OUTER JOIN
    dsv1069.orders
  ON 
    fa.item_id = orders.item_id 
  AND 
    orders.created_at >= fa.test_start_date
  AND 
    DATE_PART('day', orders.created_at - fa.test_start_date ) <= 30
  WHERE 
    fa.test_number= 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
) item_level
GROUP BY test_assignment
        
4. Use the final_assignments table to calculate the view binary, and average views for the 30 day window after the test assignment for item_test_2. (You may include the day the test started)
-- Use this table to 
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

 SELECT  
  test_assignment,
  COUNT(item_id) AS total_items,
  SUM(view_30d_binary) AS viewed_items,
  SUM(views) AS total_views,
  CAST (100*SUM(view_30d_binary)/ COUNT(item_id) AS FLOAT) AS viewed_percentage,
  SUM(views)/COUNT(item_id) AS avg_views_per_item
FROM
(
  SELECT 
      final_assignments.item_id,
      final_assignments.test_assignment,
      COUNT(view_item.event_id) AS views,
      MAX(CASE WHEN view_item.event_time >= final_assignments.test_start_date 
                THEN 1
                ELSE 0
                END ) AS view_30d_binary
    FROM 
      dsv1069.final_assignments 
  LEFT JOIN 
  (  
      SELECT 
        event_id,
        event_time,
        (CASE WHEN parameter_name= 'item_id' THEN CAST (parameter_value AS INT) ELSE NULL END ) AS item_id
      FROM 
        dsv1069.events 
      WHERE 
        event_name = 'view_item'
  ) view_item
  ON 
    view_item.item_id = final_assignments.item_id
  AND 
    view_item.event_time >= final_assignments.test_start_date 
  AND 
    DATE_part('day', view_item.event_time - final_assignments.test_start_date ) <=30
  WHERE
    final_assignments.test_number = 'item_test_2'
  GROUP BY 
    final_assignments.item_id,
    final_assignments.test_assignment
) view_binary
GROUP BY 
  test_assignment

0	1130	918	1916	81	1.6956
1	1068	890	1862	83	1.7434


 --FROM KAT
 SELECT
test_assignment,
COUNT(item_id) AS items,
SUM(view_binary_30d) AS viewed_items,
CAST(100*SUM(view_binary_30d)/COUNT(item_id) AS FLOAT) AS viewed_percent,
SUM(views) AS views,
SUM(views)/COUNT(item_id) AS average_views_per_item
FROM 
(
 SELECT 
   fa.test_assignment,
   fa.item_id, 
   MAX(CASE WHEN views.event_time > fa.test_start_date THEN 1 ELSE 0 END)  AS view_binary_30d,
   COUNT(views.event_id) AS views
  FROM 
    dsv1069.final_assignments fa
    
  LEFT OUTER JOIN 
    (
    SELECT 
      event_time,
      event_id,
      CAST(parameter_value AS INT) AS item_id
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    AND 
      parameter_name = 'item_id'
    ) views
  ON 
    fa.item_id = views.item_id
  AND 
    views.event_time >= fa.test_start_date
  AND 
    DATE_PART('day', views.event_time - fa.test_start_date ) <= 30
  WHERE 
    fa.test_number= 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
) item_level
GROUP BY 
 test_assignment
 
5. Use the https://thumbtack.github.io/abba/demo/abba.html
 to compute the lifts in metrics and the p-values for the binary metrics ( 30 day order binary and 30 day view binary) using a interval 95% confidence. 

SELECT 
  test_assignment,
  COUNT(item_id) AS total_items,
  SUM(view_binary) AS viewed_items,
  SUM(orderS_30d_binary) AS orders_30d
FROM 
(
    SELECT 
      test_assignment,
      view_binary.item_id,
      view_binary, 
      MAX(CASE WHEN orders.created_at >= view_binary.test_start_date 
              THEN 1
              ELSE 0
              END) AS orderS_30d_binary
    FROM 
    (
      SELECT 
          final_assignments.item_id,
          final_assignments.test_assignment,
          final_assignments.test_number,
          final_assignments.test_start_date,
          MAX (CASE 
                WHEN view_item.event_time > final_assignments.test_start_date 
              THEN 1 
              ELSE 0 
              END )AS view_binary
        FROM 
          dsv1069.final_assignments 
      LEFT JOIN 
      (  
          SELECT 
            event_id,
            event_time,
            (CASE WHEN parameter_name= 'item_id' THEN CAST (parameter_value AS INT) ELSE NULL END ) AS item_id
          FROM 
            dsv1069.events 
          WHERE 
            event_name = 'view_item'
      ) view_item
      ON 
        view_item.item_id = final_assignments.item_id
      AND view_item.event_time >= final_assignments.test_start_date 
      AND DATE_PART('day', view_item.event_time - final_assignments.test_start_date ) <30
      WHERE
        final_assignments.test_number = 'item_test_2'
      GROUP BY 
        final_assignments.item_id,
        final_assignments.test_assignment,
        final_assignments.test_number,
        final_assignments.test_start_date
      ORDER BY 
        final_assignments.item_id 
        ) view_binary
    LEFT JOIN 
      dsv1069.orders
    ON orders.item_id = view_binary.item_id
    AND orders.created_at >= view_binary.test_start_date 
    AND DATE_PART('day', orders.created_at - view_binary.test_start_date  ) <30
    WHERE view_binary.test_number = 'item_test_2'
    GROUP BY 
      test_assignment,
      view_binary.item_id,
      view_binary 
) view_N_order_binary
GROUP BY 
  test_assignment

0	1130	909	332
1	1068	878	297


 --FROM KAT 
SELECT
test_assignment,
COUNT(item_id) AS items,
SUM(view_binary_30d) AS viewed_items
FROM 
(
 SELECT 
   fa.test_assignment,
   fa.item_id, 
   MAX(CASE WHEN views.event_time > fa.test_start_date THEN 1 ELSE 0 END)  AS view_binary_30d
  FROM 
    dsv1069.final_assignments fa
    
  LEFT OUTER JOIN 
    (
    SELECT 
      event_time, 
      CAST(parameter_value AS INT) AS item_id
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    AND 
      parameter_name = 'item_id'
    ) views
  ON 
    fa.item_id = views.item_id
  AND 
    views.event_time >= fa.test_start_date
  AND 
    DATE_PART('day', views.event_time - fa.test_start_date ) <= 30
  WHERE 
    fa.test_number= 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
) item_level
GROUP BY 
 test_assignment
        
 
6. Use Mode’s Report builder feature to write up the test. Your write-up should include a title, a graph for each of the two binary metrics you’ve calculated. The lift and p-value (from the AB test calculator) for each of the two metrics, and a complete sentence to interpret the significance of each of the results.
 
My answers: 
After analyzing the results of the AB Testing tool for item_test_2 view metric, the obtained P-value of 0.29 indicates insufficient evidence to reject NULL hypothesis.
The success rates for Variant groups is 2% higner than Control Group, the improvement rate of Treament geoup is -1.9% - 6.2%, it seems the new change will bring a great positive impact to bring more viewers. 

 
