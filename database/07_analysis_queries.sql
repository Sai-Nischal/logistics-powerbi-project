-- =============================================================================
-- Script 07: Business Analysis Queries (MySQL Syntax)
-- Project: Real-Time Logistics & Delivery Performance Analytics
-- Purpose: Advanced analytical queries demonstrating CTEs, Window Functions,
--          Date manipulation, and Multi-table Aggregations.
-- =============================================================================

USE logistics_db;

-- =============================================================================
-- QUERY 1: Active In-Transit Shipments & Current Telemetry Status
-- Business Question: How many shipments are currently in transit, where are they,
--                    and what is the latest ping from the assigned vehicle?
-- Concepts: CTE, Window Function (ROW_NUMBER over partition), LEFT JOIN
-- =============================================================================
WITH LatestVehicleTelemetry AS (
    SELECT 
        Vehicle_ID,
        Timestamp AS Ping_Time,
        Latitude,
        Longitude,
        Speed_KMH,
        Fuel_Level,
        ROW_NUMBER() OVER (PARTITION BY Vehicle_ID ORDER BY Timestamp DESC) AS rn
    FROM Vehicle_Locations
)
SELECT 
    s.Shipment_ID,
    s.Order_ID,
    s.Vehicle_ID,
    d.Driver_Name,
    s.Dispatch_Time,
    s.Expected_Delivery_Time,
    s.Shipment_Status,
    telemetry.Ping_Time AS Last_GPS_Ping,
    telemetry.Latitude AS Current_Latitude,
    telemetry.Longitude AS Current_Longitude,
    telemetry.Speed_KMH,
    telemetry.Fuel_Level
FROM Shipments s
INNER JOIN Drivers d ON s.Driver_ID = d.Driver_ID
LEFT JOIN LatestVehicleTelemetry telemetry ON s.Vehicle_ID = telemetry.Vehicle_ID AND telemetry.rn = 1
WHERE s.Shipment_Status IN ('In Transit', 'Dispatched')
ORDER BY s.Expected_Delivery_Time ASC;

-- =============================================================================
-- QUERY 2: On-Time Delivery Performance by Priority Level
-- Business Question: Does high-priority delivery achieve better SLA adherence?
-- Concepts: JOIN, Conditional Aggregation (CASE WHEN), NULLIF
-- =============================================================================
SELECT 
    o.Priority,
    COUNT(s.Shipment_ID) AS Total_Deliveries,
    SUM(CASE WHEN s.Actual_Delivery_Time <= s.Expected_Delivery_Time THEN 1 ELSE 0 END) AS On_Time_Count,
    SUM(CASE WHEN s.Actual_Delivery_Time > s.Expected_Delivery_Time THEN 1 ELSE 0 END) AS Delayed_Count,
    ROUND(
        (SUM(CASE WHEN s.Actual_Delivery_Time <= s.Expected_Delivery_Time THEN 1 ELSE 0 END) / 
        NULLIF(COUNT(s.Shipment_ID), 0)) * 100, 
        2
    ) AS On_Time_Percentage,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.Dispatch_Time, s.Actual_Delivery_Time) / 60.0), 2) AS Avg_Delivery_Hours
FROM Shipments s
INNER JOIN Orders o ON s.Order_ID = o.Order_ID
WHERE s.Shipment_Status = 'Delivered'
GROUP BY o.Priority
ORDER BY On_Time_Percentage DESC;

-- =============================================================================
-- QUERY 3: Worst Performing Routes by Delay Rate & Volume
-- Business Question: Which routes suffer from the most frequent and severe delays?
-- Concepts: Multi-table JOIN, HAVING filter to exclude low sample sizes, RANK()
-- =============================================================================
WITH RouteStats AS (
    SELECT 
        loc_pickup.City AS Origin_City,
        loc_drop.City AS Destination_City,
        COUNT(s.Shipment_ID) AS Total_Shipments,
        SUM(CASE WHEN s.Actual_Delivery_Time > s.Expected_Delivery_Time THEN 1 ELSE 0 END) AS Delayed_Shipments,
        ROUND(
            (SUM(CASE WHEN s.Actual_Delivery_Time > s.Expected_Delivery_Time THEN 1 ELSE 0 END) / 
            NULLIF(COUNT(s.Shipment_ID), 0)) * 100, 
            2
        ) AS Delay_Rate_Pct,
        ROUND(AVG(CASE 
            WHEN s.Actual_Delivery_Time > s.Expected_Delivery_Time 
            THEN TIMESTAMPDIFF(MINUTE, s.Expected_Delivery_Time, s.Actual_Delivery_Time) / 60.0 
            ELSE 0 
        END), 2) AS Avg_Delay_Hours
    FROM Shipments s
    INNER JOIN Orders o ON s.Order_ID = o.Order_ID
    INNER JOIN Locations loc_pickup ON o.Pickup_Location_ID = loc_pickup.Location_ID
    INNER JOIN Locations loc_drop ON o.Delivery_Location_ID = loc_drop.Location_ID
    WHERE s.Shipment_Status = 'Delivered'
    GROUP BY loc_pickup.City, loc_drop.City
    HAVING COUNT(s.Shipment_ID) >= 10
)
SELECT 
    Origin_City,
    Destination_City,
    Total_Shipments,
    Delayed_Shipments,
    Delay_Rate_Pct,
    Avg_Delay_Hours,
    DENSE_RANK() OVER (ORDER BY Delay_Rate_Pct DESC, Avg_Delay_Hours DESC) AS Delay_Severity_Rank
FROM RouteStats
ORDER BY Delay_Severity_Rank ASC
LIMIT 10;

-- =============================================================================
-- QUERY 4: Fleet Mileage & Utilization Quadrant Analysis
-- Business Question: Which vehicles have excessive mileage vs which are underutilized?
-- Concepts: LEFT JOIN, Aggregation, NTILE(4) quartile distribution
-- =============================================================================
SELECT 
    v.Vehicle_ID,
    v.Vehicle_Number,
    v.Vehicle_Type,
    v.Fuel_Type,
    COUNT(s.Shipment_ID) AS Total_Trips,
    COALESCE(ROUND(SUM(s.Distance_KM), 2), 0.00) AS Total_Distance_KM,
    COALESCE(ROUND(SUM(s.Fuel_Cost), 2), 0.00) AS Total_Fuel_Cost,
    NTILE(4) OVER (ORDER BY COALESCE(SUM(s.Distance_KM), 0) DESC) AS Mileage_Quartile
FROM Vehicles v
LEFT JOIN Shipments s ON v.Vehicle_ID = s.Vehicle_ID
GROUP BY v.Vehicle_ID, v.Vehicle_Number, v.Vehicle_Type, v.Fuel_Type
ORDER BY Total_Distance_KM DESC;

-- =============================================================================
-- QUERY 5: Driver Performance Scorecard with Minimum Trip Threshold
-- Business Question: What are the objective performance metrics for drivers?
-- Concepts: INNER JOIN, HAVING filter (removes bias of 100% on 1 trip), DENSE_RANK
-- =============================================================================
SELECT 
    d.Driver_ID,
    d.Driver_Name,
    d.Experience_Years,
    d.Rating AS System_Rating,
    COUNT(s.Shipment_ID) AS Trips_Completed,
    ROUND(
        (SUM(CASE WHEN s.Actual_Delivery_Time <= s.Expected_Delivery_Time THEN 1 ELSE 0 END) / 
        COUNT(s.Shipment_ID)) * 100, 
        2
    ) AS On_Time_Pct,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.Dispatch_Time, s.Actual_Delivery_Time) / 60.0), 2) AS Avg_Hours_Per_Trip,
    DENSE_RANK() OVER (ORDER BY 
        (SUM(CASE WHEN s.Actual_Delivery_Time <= s.Expected_Delivery_Time THEN 1 ELSE 0 END) / COUNT(s.Shipment_ID)) DESC,
        COUNT(s.Shipment_ID) DESC
    ) AS Performance_Rank
FROM Drivers d
INNER JOIN Shipments s ON d.Driver_ID = s.Driver_ID
WHERE s.Shipment_Status = 'Delivered'
GROUP BY d.Driver_ID, d.Driver_Name, d.Experience_Years, d.Rating
HAVING COUNT(s.Shipment_ID) >= 5
ORDER BY Performance_Rank ASC;

-- =============================================================================
-- QUERY 6: Unit Economics — Cost per KM by Vehicle Type & Fuel Type
-- Business Question: Which vehicle type is the most cost-effective per kilometer?
-- Concepts: JOIN, Multi-level Aggregation, Calculated unit metrics
-- =============================================================================
SELECT 
    v.Vehicle_Type,
    v.Fuel_Type,
    COUNT(s.Shipment_ID) AS Total_Trips,
    ROUND(SUM(s.Distance_KM), 2) AS Total_KM,
    ROUND(SUM(s.Shipping_Cost), 2) AS Total_Base_Shipping_Cost,
    ROUND(SUM(s.Fuel_Cost), 2) AS Total_Fuel_Expenditure,
    ROUND(SUM(s.Shipping_Cost + s.Fuel_Cost), 2) AS Total_Logistics_Cost,
    ROUND(SUM(s.Shipping_Cost + s.Fuel_Cost) / NULLIF(SUM(s.Distance_KM), 0), 2) AS Cost_Per_KM,
    ROUND(SUM(s.Fuel_Cost) / NULLIF(SUM(s.Distance_KM), 0), 2) AS Fuel_Cost_Per_KM
FROM Vehicles v
INNER JOIN Shipments s ON v.Vehicle_ID = s.Vehicle_ID
WHERE s.Shipment_Status = 'Delivered'
GROUP BY v.Vehicle_Type, v.Fuel_Type
ORDER BY Cost_Per_KM ASC;

-- =============================================================================
-- QUERY 7: Monthly Shipment Volume & MoM Growth Analysis
-- Business Question: How has shipment volume and revenue evolved over time?
-- Concepts: DATE_FORMAT, LAG() Window Function for Month-over-Month calculation
-- =============================================================================
WITH MonthlyMetrics AS (
    SELECT 
        DATE_FORMAT(Dispatch_Time, '%Y-%m') AS Shipment_Month,
        COUNT(Shipment_ID) AS Total_Shipments,
        ROUND(SUM(Shipping_Cost + Fuel_Cost), 2) AS Total_Cost
    FROM Shipments
    GROUP BY DATE_FORMAT(Dispatch_Time, '%Y-%m')
)
SELECT 
    Shipment_Month,
    Total_Shipments,
    LAG(Total_Shipments, 1) OVER (ORDER BY Shipment_Month) AS Prev_Month_Shipments,
    ROUND(
        ((Total_Shipments - LAG(Total_Shipments, 1) OVER (ORDER BY Shipment_Month)) / 
        NULLIF(LAG(Total_Shipments, 1) OVER (ORDER BY Shipment_Month), 0)) * 100, 
        2
    ) AS MoM_Shipment_Growth_Pct,
    Total_Cost,
    LAG(Total_Cost, 1) OVER (ORDER BY Shipment_Month) AS Prev_Month_Cost,
    ROUND(
        ((Total_Cost - LAG(Total_Cost, 1) OVER (ORDER BY Shipment_Month)) / 
        NULLIF(LAG(Total_Cost, 1) OVER (ORDER BY Shipment_Month), 0)) * 100, 
        2
    ) AS MoM_Cost_Growth_Pct
FROM MonthlyMetrics
ORDER BY Shipment_Month ASC;
