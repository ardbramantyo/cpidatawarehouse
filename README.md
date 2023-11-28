## End-to-End Enterprise Data Warehouse Development for CPI Card Group
### Company Overview
CPI Card Group is a prominent figure in the payment card production realm, boasting over three decades of expertise. Their global presence and allegiance to leading payment brands underscore their significance. From VISA to MasterCard, American Express, Discover, and Interac, CPI's repertoire includes a diverse array of consumer plastic cards, including cutting-edge contactless smart cards. Anchored by a secure production network spanning North America, CPI stands as a go-to for financial institutions and prepaid debit card programs alike.

### Business Problem
Within their triumphant journey, CPI faces the complex intricacies of their operations. A labyrinthine manufacturing process intertwines with data from ERP, CRM, and finance, resulting in reporting bottlenecks. The reliance on IT for reports hampers swift decision-making. In response, CPI seeks a robust data warehouse solution to streamline operations and catapult them into a future-ready stance.

## Proposed Scenario for Data Warehouse Solution:

### Data Collection
 - Extract comprehensive data from the Enterprise Resource Planning (ERP), covering card production, sales, and financials.
 - Source marketing data from the marketing department, including leads, quotes, and success rates.
 - Collect financial data from the accounting department, encompassing costs, invoices, and sales summaries.

![image](https://github.com/ardbramantyo/cpidatawarehouse/assets/37673834/6eaaf87b-db52-4634-88f0-1b02b5ccf540)

_Picture 1. Data Sources at the CPI Card Group Data Warehouse_

### Data Modeling
 - Design a constellation schema ERD for the data warehouse.
 - Identify key dimensions like time, location, sales class, and customers, anchoring them to a central fact table capturing holistic business metrics.

![image](https://github.com/ardbramantyo/xyzdatawarehouse/assets/37673834/891e8b63-5377-47d6-b484-98e0e6bed93a)

_Picture 2. ERD Design for CPI Card Group_

### ETL Process with Pentaho
- Utilize Pentaho Data Integration for seamless ETL processes.
![image](https://github.com/ardbramantyo/cpidatawarehouse/assets/37673834/75421afb-fc73-4fbe-826b-bfbfb63abccf)

_Picture 3. Integration scenario_

- Extract, transform, and load marketing data into the central fact table, ensuring data consistency and accuracy.
![image](https://github.com/ardbramantyo/xyzdatawarehouse/assets/37673834/902d0dc7-79c8-4696-b8d9-0a682a89598b)

_Picture 4. Data Integration process with Pentaho_

### Advanced Analytical Queries
- Develop view tables for revenue, job summarization insights.
```
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
FROM w_job_f A
JOIN w_sub_job_f B ON A.job_id = B.job_id
JOIN w_job_shipment_f C ON B.sub_job_id = C.sub_job_id
JOIN w_invoiceline_f D ON C.invoice_id = D.invoice_id
JOIN w_location_d E ON A.location_id = E.location_id
JOIN w_time_d F ON A.contract_date = F.time_id
GROUP BY
    A.location_id
   ,E.location_name
   ,F.time_year
   ,F.time_month
   ,A.job_id
   ,A.unit_price
   ,A.quantity_ordered
ORDER BY
    A.location_id
   ,F.time_year
   ,F.time_month
   ,A.job_id;
```
![image](https://github.com/ardbramantyo/cpidatawarehouse/assets/37673834/fb3c91ce-8f1b-4da9-94b2-752bfb49dc6e)

_Picture 5. Rank locations by sum of business days delayed for the job shipped by date_

- Analyze trends over time using Analytical queries.
```
SELECT
     A.location_name
    ,B.time_year AS year_of_date_ship_by
    ,SUM(A.days_diff_first_shipment_ship_by)
    ,RANK() OVER(PARTITION BY A.location_name ORDER BY SUM(A.days_diff_first_shipment_ship_by) DESC) AS rank
FROM view_first_shipment_delays_involving_shipped_by_date A
JOIN w_time_d B ON A.date_ship_by = B.time_id
GROUP BY A.location_name, year_of_date_ship_by;
```
![image](https://github.com/ardbramantyo/cpidatawarehouse/assets/37673834/e905e8df-9047-45f2-b756-ec8d34a32153)

_Picture 6. Location invoice revenue summary_

- Evaluate financial performance, gross margins, and profitability by location and product.
```
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
```
![image](https://github.com/ardbramantyo/cpidatawarehouse/assets/37673834/adb40c83-4b72-4d22-91bd-ec2a478b2e72)

_Picture 7. Rank locations by descending annual profit margin_

### MicroStrategy Dossier Creation
- Use MicroStrategy to craft advanced dashboards.
- Develop interactive visualizations highlighting key performance indicators, revenue trends, and cost breakdowns.
- Include drill-down features for detailed analysis.
![image](https://github.com/ardbramantyo/xyzdatawarehouse/assets/37673834/46f00991-6053-4a9e-b21d-1f7a0c17c455)

_Picture 7. Job and Shipment Trend Dashboard_

![image](https://github.com/ardbramantyo/xyzdatawarehouse/assets/37673834/a7089b84-98c5-4a38-8650-2b68f188ab64)

_Picture 8. Invoice Trend Dashboard_

![image](https://github.com/ardbramantyo/xyzdatawarehouse/assets/37673834/e6dc8b5f-ef5d-421b-9379-e6291e4a9422)

_Picture 9. Financial Performance Dashboard_

### Actionable Outputs
- Identify high-performing sales agents and locations for targeted strategies.
- Optimize production timelines by analyzing production and shipment trends.
- Improve financial forecasting based on cost variations and challenging-to-budget products.

### Benefits for the Company
- __Improved Decision-Making:__ Enable business analysts for informed decisions with self-service reporting, responding rapidly to market changes.
- __Cost Optimization:__ Identify cost-effective machine types and streamline production based on historical data, reducing operational expenses.
- __Enhanced Sales Strategies:__ Target marketing efforts effectively based on historical data, aligning with successful leads and converted jobs.
- __Scalability and Future Growth:__ Design a scalable solution for growing data volumes and reporting needs, positioning for future growth.
- __User Empowerment:__ Empower business analysts with self-service reporting tools and user-friendly dashboards, reducing IT reliance.
- __Strategic Insights:__ Provide executives with strategic insights into market trends, customer preferences, and industry benchmarks.

## Conclusion
This end-to-end solution positions CPI Card Group to wield the power of data strategically, optimizing costs, fostering growth, and making informed decisions in the competitive payment industry. The tangible benefits, coupled with user-friendly dashboards, align seamlessly with CPI's strategic objectives.

## Accomplishment
The above project is a Capstone project to get the Data Warehousing for Business Intelligence Specialization certification and to complete the mastery of using MicroStrategy, I took and passed 2 MicroStrategy certifications: Departmental Analyst and Enterprise Analyst.

[<image src="https://github.com/ardbramantyo/cpidatawarehouse/assets/37673834/01f4a6cc-18dd-4e9e-96b3-6d957ea2d09d">](https://www.coursera.org/account/accomplishments/specialization/DZR9THCTSPBR)
[<image src="https://github.com/ardbramantyo/xyzdatawarehouse/assets/37673834/f4291ccd-06ce-47f0-8b73-d808963d4232">](https://www.credential.net/c50f7231-23db-44f5-8c62-1558e836c683#gs.1e25zf)
[<image src="https://github.com/ardbramantyo/cpidatawarehouse/assets/37673834/ddee478e-56f7-4981-b2c8-65ccafbd684a">](https://www.credential.net/781b7bd4-409d-40fb-9b5a-073b623ebf01#gs.1i831a)

