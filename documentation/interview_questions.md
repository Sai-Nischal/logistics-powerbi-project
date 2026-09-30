# Technical Interview Preparation Guide

This guide contains project-specific technical questions designed for Data Engineer, BI Developer, and Analytics Architect interviews.

---

## 🎙️ "Tell Me About Your Project" (Elevator Pitch)

> *"In my project, **Real-Time Logistics & Delivery Performance Analytics**, I designed and built an end-to-end operational control tower that monitors fulfillment performance, driver metrics, fleet utilization, and freight costs across major logistics corridors in India.*
> 
> *Architecturally, I engineered a normalized relational database in **MySQL** containing 9 tables with strict foreign keys, indexing, and analytical views. I built a **Python simulation engine** that generated over 50,000 realistic orders and shipments—simulating route distances, monsoon delays, and fuel consumption based on vehicle efficiency—as well as a streaming simulator producing continuous IoT GPS telemetry pings.*
> 
> *On the BI side, I used **Power Query (M)** to clean and structure the data into an enterprise **Star Schema**, handling nulls and creating operational delay buckets. In **Power BI**, I engineered over 25 **DAX measures** covering SLA adherence, fleet utilization, and time intelligence (MoM/YoY growth), presenting them in a 4-page executive dashboard with drill-through navigation and root-cause analysis.*
> 
> *The project highlights my ability to take raw business requirements, design a scalable database, model data using dimensional best practices, and deliver actionable insights for supply chain decision-makers."*

---

## 1. SQL Interview Questions (20 Questions)

#### Q1: Why did you normalize the database to 3NF rather than keeping everything in one flat table?
- **Strong Answer**: A normalized transactional database prevents update anomalies, data redundancy, and lock contention during high-frequency inserts. Storing drivers and vehicles separately allows their statuses and assignments to change without modifying historical shipment records.
- **Project Tie-in**: Tables `Drivers`, `Vehicles`, and `Customers` exist as independent entities referenced by foreign keys.

#### Q2: What is the difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()` in your driver scorecard query?
- **Strong Answer**: `ROW_NUMBER()` assigns a distinct sequential integer to every row regardless of ties. `RANK()` leaves gaps in ranking when values tie (e.g., 1, 2, 2, 4). `DENSE_RANK()` assigns the same rank to ties without skipping numbers (e.g., 1, 2, 2, 3), which is essential for accurate leaderboard rankings.
- **Project Tie-in**: Used in `07_analysis_queries.sql` (Query 5) to rank driver on-time delivery percentages.

#### Q3: How did you retrieve only the most recent GPS ping for each vehicle in Query 1?
- **Strong Answer**: I used a Common Table Expression (CTE) combined with the window function `ROW_NUMBER() OVER (PARTITION BY Vehicle_ID ORDER BY Timestamp DESC) AS rn` and filtered where `rn = 1`. This avoids an expensive correlated subquery.
- **Project Tie-in**: Query 1 in `07_analysis_queries.sql`.

#### Q4: Why did you use `LEFT JOIN` instead of `INNER JOIN` when calculating vehicle utilization?
- **Strong Answer**: An `INNER JOIN` would drop vehicles that have never been assigned a trip, distorting fleet utilization KPIs. A `LEFT JOIN` ensures 100% of fleet assets are counted, returning 0 trips for idle vehicles.
- **Project Tie-in**: View `vw_vehicle_utilization`.

#### Q5: How do you prevent divide-by-zero errors in SQL aggregations?
- **Strong Answer**: By wrapping denominators in `NULLIF(expression, 0)`. When the expression equals 0, `NULLIF` converts it to `NULL`, causing the division to safely evaluate to `NULL` rather than throwing an exception.
- **Project Tie-in**: Used in all percentage and cost-per-km calculations across `06_views.sql`.

#### Q6: What indexes did you create and why?
- **Strong Answer**: I indexed all foreign keys (`Customer_ID`, `Vehicle_ID`, `Driver_ID`), frequently filtered columns (`Shipment_Status`, `Order_Date`), and created a composite index on `Vehicle_Locations(Vehicle_ID, Timestamp DESC)` to optimize telemetry range lookups.
- **Project Tie-in**: Script `04_indexes.sql`.

#### Q7: How does query performance change when filtering on an unindexed column vs an indexed column?
- **Strong Answer**: Without an index, the database engine must execute a Full Table Scan (O(N)), reading every page from disk. With a B-Tree index, lookup complexity drops to O(log N).

#### Q8: What is the purpose of `ON DUPLICATE KEY UPDATE` in your seed scripts?
- **Strong Answer**: It provides idempotent upsert behavior. If the primary key already exists, MySQL updates the existing record rather than failing with a duplicate key constraint violation.
- **Project Tie-in**: Used in `05_seed_data.sql`.

#### Q9: What is Query Folding in Power BI, and how does your SQL view design support it?
- **Strong Answer**: Query Folding is the ability of Power Query to translate M transformations back into native SQL queries executed on the database server. Pre-aggregating data in SQL views guarantees server-side execution.
- **Project Tie-in**: Script `06_views.sql`.

#### Q10: How did you compute Month-over-Month (MoM) growth in SQL?
- **Strong Answer**: By grouping by month and using the `LAG(Total_Cost, 1) OVER (ORDER BY Shipment_Month)` window function to access the previous month's metric.
- **Project Tie-in**: Query 7 in `07_analysis_queries.sql`.

*(Questions 11 to 20 cover indexing strategies, transactions, ACID properties, execution plans, foreign key cascading, and stored procedures.)*

---

## 2. Power Query (M) Interview Questions (15 Questions)

#### Q1: What is the difference between adding a calculated column in Power Query vs DAX?
- **Strong Answer**: Power Query calculated columns are evaluated once during data refresh and stored in compressed memory by the VertiPaq engine, improving DAX query speed. DAX calculated columns recalculate upon model refresh and consume RAM.

#### Q2: How did you generate the continuous calendar table (`DimDate`)?
- **Strong Answer**: Using `List.Dates(StartDate, NumberOfDays, #duration(1, 0, 0, 0))` in M code, converting it to a table, and extracting year, month, quarter, and weekday attributes.
- **Project Tie-in**: Script `power_query/m_code_examples.txt`.

#### Q3: Why is query folding important for large datasets?
- **Strong Answer**: It offloads heavy filtering, joins, and sorting to the database server, minimizing the volume of raw data transferred over the network into Power BI.

#### Q4: How did you handle null values in `Actual_Delivery_Time`?
- **Strong Answer**: In-transit shipments legitimately have null actual delivery dates. Rather than inserting dummy dates (which would skew averages), I kept them null and used conditional M logic to label their delay category as "In Transit".
- **Project Tie-in**: `power_query/transformations.md`.

#### Q5: What is the function of `Table.Buffer` in M?
- **Strong Answer**: `Table.Buffer` loads an entire table into local memory, preventing multiple calls to the underlying data source during complex merges.

---

## 3. Power BI Data Modeling Interview Questions (20 Questions)

#### Q1: Why did you choose a Star Schema over a Snowflake Schema?
- **Strong Answer**: Star schemas minimize relationship joins, optimize VertiPaq column store compression, and make DAX measures significantly simpler and faster to evaluate compared to deeply nested snowflake schemas.
- **Project Tie-in**: `power_bi/data_model.md`.

#### Q2: How do you handle role-playing dimensions like `Pickup Location` and `Delivery Location`?
- **Strong Answer**: Both foreign keys point to `DimLocation`. One relationship is set as Active, while the other is Inactive. In DAX, the inactive relationship is dynamically activated using `USERELATIONSHIP()`.

#### Q3: What is cardinality, and what cardinalities exist in your model?
- **Strong Answer**: Cardinality describes the uniqueness of values on both sides of a relationship. Our model uses 1-to-Many (`1:*`) relationships from Dimension tables to Fact tables.

#### Q4: Why should bidirectional cross-filtering be avoided in enterprise models?
- **Strong Answer**: Bidirectional relationships can cause ambiguous filter paths, unexpected metric calculation results, and degrade report performance. Single-directional filtering ensures predictable filter propagation.

#### Q5: What is the VertiPaq engine and how does it compress data?
- **Strong Answer**: VertiPaq is Power BI's in-memory columnar database engine. It uses Dictionary encoding, Run-Length Encoding (RLE), Bit-packing, and Value encoding to compress columnar data up to 10x.

---

## 4. DAX Interview Questions (20 Questions)

#### Q1: What is the difference between Row Context and Filter Context?
- **Strong Answer**: Row context knows only about the current row (e.g., in a calculated column or iterator like `SUMX`). Filter context consists of all active filters applied to the data model by visuals, slicers, row headers, and page filters.

#### Q2: How does `CALCULATE()` modify filter context?
- **Strong Answer**: `CALCULATE()` is the only DAX function that can alter, override, or transition row context into filter context. It evaluates its arguments in a newly modified filter context.

#### Q3: Why did you use `DIVIDE()` instead of the standard `/` operator?
- **Strong Answer**: `DIVIDE(numerator, denominator, alternateResult)` automatically guards against division by zero errors, cleanly returning `0` or `BLANK()` without breaking visual rendering.
- **Project Tie-in**: Measure `[On-Time Delivery %]`.

#### Q4: What is Context Transition?
- **Strong Answer**: When `CALCULATE()` is invoked inside a row context (such as an iterator or calculated column), it transforms the current row context into an equivalent filter context.

#### Q5: How did you implement Month-over-Month (MoM) growth in DAX?
- **Strong Answer**: Using `DATEADD(DimDate[DateKey], -1, MONTH)` inside `CALCULATE()` to retrieve previous month figures, then applying `DIVIDE(Current - Previous, Previous, 0)`.
- **Project Tie-in**: Measure `[MoM Growth %]`.

---

## 5. Logistics Domain & System Architecture Questions (15 Questions)

#### Q1: Why is this project described as "Simulated Real-Time" rather than "True Real-Time"?
- **Strong Answer**: True real-time requires sub-second streaming pipelines (e.g., Kafka / Azure Event Hubs into Power BI Streaming Datasets). In this architecture, Python generates live telemetry into a relational database, and Power BI displays the updates upon refresh. Transparently calling it simulated real-time demonstrates technical honesty.

#### Q2: How does distance impact logistics cost beyond simple fuel consumption?
- **Strong Answer**: Distance impacts driver wages, vehicle wear-and-tear (maintenance depreciation), highway toll charges, and regulatory rest constraints. Our model reflects this via composite shipping and fuel cost algorithms.

#### Q3: Why is it bad practice to label a driver or vehicle as "best" based on a single metric?
- **Strong Answer**: A driver with a 100% on-time record who only completed 2 local trips cannot be compared directly to a long-haul driver with a 92% record across 80 interstate trips. Multi-metric evaluation with minimum activity thresholds prevents misleading operational conclusions.
