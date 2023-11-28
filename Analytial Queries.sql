BQ 1: Location/Sales class summary for job quantity and amount

CREATE VIEW view_location_sales_class_summary AS
SELECT
     A.location_id
    ,B.location_name
    ,D.time_year AS contract_year
    ,D.time_month AS contract_month
    ,A.sales_class_id
    ,C.sales_class_desc
    ,C.base_price
    ,SUM(A.quantity_ordered) AS sum_quantity_ordered
    ,SUM(A.quantity_ordered * C.base_price) AS sum_job_amount
FROM 
    w_job_f A 
JOIN 
    w_location_d B ON A.location_id = B.location_id
JOIN 
    w_sales_class_d C ON A.sales_class_id = C.sales_class_id
JOIN
    w_time_d D ON A.contract_date = D.time_id
GROUP BY
     A.location_id
    ,B.location_name
    ,D.time_year
    ,D.time_month
    ,A.sales_class_id
    ,C.sales_class_desc
    ,C.base_price
ORDER BY
    A.location_id, contract_year ,contract_month ,A.sales_class_id;

BQ 2: Location invoice revenue summary

CREATE VIEW view_location_invoice_revenue_summary AS
SELECT
     A.location_id
    ,E.location_name
    ,F.time_year AS contract_year
    ,F.time_month AS contract_month
    ,A.job_id
    ,A.unit_price
    ,A.quantity_ordered
    ,SUM(D.invoice_amount) AS sum_invoice_amount
    ,SUM(D.invoice_quantity) AS sum_invoice_quantity
FROM
    w_job_f A
JOIN
    w_sub_job_f B ON A.job_id = B.job_id
JOIN
    w_job_shipment_f C ON B.sub_job_id = C.sub_job_id
JOIN
    w_invoiceline_f D ON C.invoice_id = D.invoice_id
JOIN
    w_location_d E ON A.location_id = E.location_id
JOIN
    w_time_d F ON A.contract_date = F.time_id
GROUP BY
     A.location_id
    ,E.location_name
    ,F.time_year
    ,F.time_month
    ,A.job_id
    ,A.unit_price
    ,A.quantity_ordered
ORDER BY
    A.location_id, F.time_year, F.time_month, A.job_id;

BQ 3: Location subjob cost summary
CREATE VIEW view_location_subjob_cost_summary AS
SELECT
    A.location_id,
    B.location_name,
    D.time_year AS contract_year,
    D.time_month AS contract_month,
    A.job_id,
    COUNT(A.job_id) AS NoSubJob,
    SUM(A.cost_labor) AS sum_cost_labor,
    SUM(A.cost_material) AS sum_cost_material,
    SUM(A.machine_hours * E.rate_per_hour) AS sum_cost_machine,
    SUM(A.cost_overhead) AS sum_cost_overhead,
    (SUM(A.cost_labor) + SUM(A.cost_material) + SUM(A.machine_hours * E.rate_per_hour) + SUM(A.cost_overhead)) AS sum_total,
    SUM(A.quantity_produced) AS sum_quantity_produced,
    ROUND((SUM(A.cost_labor) + SUM(A.cost_material) + SUM(A.machine_hours * E.rate_per_hour) + SUM(A.cost_overhead)) / SUM(A.quantity_produced), 2) AS unit_cost
FROM
    w_sub_job_f A
JOIN
    w_location_d B ON A.location_id = B.location_id
JOIN
    w_job_f C ON A.job_id = C.job_id
JOIN
    w_time_d D ON C.contract_date = D.time_id
JOIN
    w_machine_type_d E ON A.machine_type_id = E.machine_type_id
GROUP BY
    A.location_id,
    B.location_name,
    D.time_year,
    D.time_month,
    A.job_id
ORDER BY
    A.location_id,
    contract_year,
    contract_month;

BQ 4: Returns by location and sales class
CREATE VIEW view_returns_by_sales_location_class AS
SELECT
     A.location_id
    ,B.location_name
    ,D.time_year AS invoice_sent_year
    ,D.time_month AS invoice_sent_month
    ,C.sales_class_id
    ,C.sales_class_desc
    ,SUM(A.quantity_shipped - A.invoice_quantity) AS sum_quantity_returned
    ,SUM(A.invoice_amount) AS sum_amount_return
FROM 
    w_invoiceline_f A
JOIN 
    w_location_d B ON A.location_id = B.location_id
JOIN 
    w_sales_class_d C ON A.sales_class_id = C.sales_class_id
JOIN 
    w_time_d D ON A.invoice_sent_date = D.time_id
GROUP BY
     A.location_id
    ,B.location_name
    ,invoice_sent_year
    ,invoice_sent_month
    ,C.sales_class_id
    ,C.sales_class_desc
ORDER BY
     A.location_id
    ,invoice_sent_year
    ,invoice_sent_month
    ,C.sales_class_id;

BQ5: Last shipment delays involving date promised

CREATE VIEW view_last_shipment_delays_involving_date_promised AS
SELECT
     A.location_id
    ,D.location_name
    ,E.sales_class_id
    ,E.sales_class_desc
    ,C.job_id
    ,C.date_promised
    ,MAX(A.actual_ship_date) AS last_shipment_date
    ,SUM(A.actual_quantity) AS sum_delay_ship_qty
    ,C.quantity_ordered
    ,GETBUSDAYSDIFF(MAX(A.actual_ship_date), C.date_promised) AS days_diff_last_shipment_promised
FROM w_job_shipment_f A
JOIN w_sub_job_f B ON A.sub_job_id = B.sub_job_id
JOIN w_job_f C ON B.job_id = C.job_id
JOIN w_location_d D ON A.location_id = D.location_id
JOIN w_sales_class_d E ON A.sales_class_id = E.sales_class_id
WHERE A.actual_ship_date > C.date_promised
GROUP BY
    A.location_id
    ,D.location_name
    ,E.sales_class_id
    ,E.sales_class_desc
    ,C.job_id
    ,C.date_promised
    ,C.quantity_ordered
ORDER BY
     A.location_id
    ,E.sales_class_id;

BQ 6: First shipment delays involving shipped by date

CREATE VIEW view_first_shipment_delays_involving_shipped_by_date AS
SELECT
     A.location_id
    ,D.location_name
    ,E.sales_class_id
    ,E.sales_class_desc
    ,C.job_id
    ,MIN(A.actual_ship_date) AS first_shipment_date
    ,C.date_ship_by
    ,GETBUSDAYSDIFF(C.date_ship_by, MIN(A.actual_ship_date)) AS days_diff_first_shipment_ship_by
FROM w_job_shipment_f A
JOIN w_sub_job_f B ON A.sub_job_id = B.sub_job_id
JOIN w_job_f C ON B.job_id = C.job_id
JOIN w_location_d D ON A.location_id = D.location_id
JOIN w_sales_class_d E ON A.sales_class_id = E.sales_class_id
GROUP BY
     A.location_id
    ,D.location_name
    ,E.sales_class_id
    ,E.sales_class_desc
    ,C.job_id
    ,C.date_ship_by
ORDER BY
     A.location_id
    ,E.sales_class_id;


AQ 1: Cumulative quantity for locations

SELECT
     location_name
    ,contract_year
    ,contract_month
    ,sum_job_amount
    ,SUM(sum_job_amount) 
         OVER (PARTITION BY location_name, contract_year 
               ORDER BY contract_month 
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sum_job_amount 
FROM 
    view_location_sales_class_summary;

AQ2: Moving average of average amount ordered for locations

SELECT location_name
      ,contract_year
      ,contract_month 
	  ,ROUND(AVG(sum_job_amount) 
           OVER (PARTITION BY location_name 
                 ORDER BY contract_year, contract_month 
                 ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 2) AS moving_avg_avg_job_amount
from view_location_sales_class_summary;

AQ3: Rank locations by descending sum of annual profit

SELECT
     A.location_name
    ,A.contract_year
    ,A.contract_month
    ,SUM(A.sum_invoice_amount - B.sum_total) AS sum_of_profit
    ,RANK() OVER(PARTITION BY A.location_name, A.contract_year ORDER BY SUM(A.sum_invoice_amount - B.sum_total) DESC) AS rank
FROM
    view_location_invoice_revenue_summary A
JOIN
    view_location_subjob_cost_summary B ON A.job_id = B.job_id
GROUP BY
    A.location_name
    ,A.contract_year
    ,A.contract_month;

AQ4: Rank locations by descending annual profit margin

SELECT
     A.location_name
    ,A.contract_year
    ,A.contract_month
    ,ROUND(SUM((A.sum_invoice_amount - B.sum_total) / A.sum_invoice_amount), 2) AS profit_margin
    ,RANK() OVER(PARTITION BY A.location_name, A.contract_year ORDER BY SUM(A.sum_invoice_amount - B.sum_total) DESC) AS rank
FROM
    view_location_invoice_revenue_summary A
JOIN
    view_location_subjob_cost_summary B ON A.job_id = B.job_id
GROUP BY
     A.location_name
    ,A.contract_year
    ,A.contract_month;

AQ5: Percent rank of job profit margins for locations

CREATE VIEW view_aq5_percent_rank_of_job_profit_margin AS
SELECT
     A.location_name
    ,A.contract_year
    ,A.contract_month
    ,A.job_id
    ,SUM((A.sum_invoice_amount - B.sum_total) / A.sum_invoice_amount) AS profit_margin
    ,PERCENT_RANK() OVER(ORDER BY ROUND(SUM((A.sum_invoice_amount - B.sum_total) / A.sum_invoice_amount), 2)) AS percent_rank_profit_margin
FROM
    view_location_invoice_revenue_summary A
JOIN
    view_location_subjob_cost_summary B ON A.job_id = B.job_id
GROUP BY
     A.location_name
    ,A.contract_year
    ,A.contract_month
    ,A.job_id;

AQ6: Top 5% performers of percent rank of job profit margins for locations

SELECT * FROM view_aq5_percent_rank_of_job_profit_margin
WHERE percent_rank_profit_margin >= 0.95;

AQ7: Rank sales class by return quantities for each year

SELECT
     sales_class_desc
    ,invoice_sent_year
    ,SUM(sum_quantity_returned) AS total_sum_quantity_returned
    ,RANK() OVER (PARTITION BY sales_class_desc, invoice_sent_year ORDER BY SUM(sum_quantity_returned) DESC) AS rank
FROM
    view_returns_by_sales_location_class
GROUP BY
     sales_class_desc
    ,invoice_sent_year;

AQ8: Ratio to report of return quantities for sales classes by year

SELECT
    sales_class_desc,
    invoice_sent_year,
    SUM(sum_quantity_returned) AS total_sum_quantity_returned,
    ROUND(SUM(sum_quantity_returned) / SUM(SUM(sum_quantity_returned)) OVER (PARTITION BY sales_class_desc), 3) AS ratio_to_report
FROM view_returns_by_sales_location_class
GROUP BY sales_class_desc, invoice_sent_year
ORDER BY sales_class_desc, invoice_sent_year;

AQ9: Rank locations by sum of business days delayed for the job shipped by date

SELECT
    A.location_name
    ,B.time_year AS year_of_date_ship_by
    ,SUM(A.days_diff_first_shipment_ship_by)
    ,RANK() OVER (PARTITION BY A.location_name ORDER BY SUM(A.days_diff_first_shipment_ship_by) DESC) AS rank
FROM view_first_shipment_delays_involving_shipped_by_date A
JOIN w_time_d B ON A.date_ship_by = B.time_id
GROUP BY A.location_name, year_of_date_ship_by;

AQ10: Rank locations by delay rate for jobs delayed on the last shipment date

SELECT
    A.location_name,
    B.time_year AS year_of_date_promised,
    COUNT(A.job_id) AS count_delayed_job,
    SUM(A.days_diff_last_shipment_promised) AS sum_diff_last_shipment_promised,
    RANK() OVER (PARTITION BY A.location_name ORDER BY SUM(A.days_diff_last_shipment_promised) DESC) AS rank
FROM view_bq5_last_shipment_delays_involving_date_promised A
JOIN w_time_d B ON A.date_promised = B.time_id
GROUP BY A.location_name, B.time_year;