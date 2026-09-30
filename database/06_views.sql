-- =============================================================================
-- Script 06: Analytical SQL Views (MySQL Syntax)
-- Project: Real-Time Logistics & Delivery Performance Analytics
-- Purpose: Pre-aggregated business views for high-performance reporting & Power BI
-- =============================================================================

USE logistics_db;

-- -----------------------------------------------------------------------------
-- View 1: vw_shipment_kpis
-- Purpose: Provides high-level operational shipment volumes and status breakdown.
-- Joins: Aggregates directly on Shipments table.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_shipment_kpis AS
SELECT
    COUNT(Shipment_ID) AS Total_Shipments,
    SUM(CASE WHEN Shipment_Status = 'Delivered' THEN 1 ELSE 0 END) AS Delivered_Shipments,
    SUM(CASE WHEN Shipment_Status = 'In Transit' THEN 1 ELSE 0 END) AS In_Transit_Shipments,
    SUM(CASE WHEN Shipment_Status = 'Dispatched' THEN 1 ELSE 0 END) AS Dispatched_Shipments,
    SUM(CASE WHEN Shipment_Status = 'Delayed' OR (Actual_Delivery_Time > Expected_Delivery_Time) THEN 1 ELSE 0 END) AS Delayed_Shipments,
    SUM(CASE WHEN Shipment_Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Shipments,
    SUM(CASE WHEN Shipment_Status = 'Delivered' AND Actual_Delivery_Time <= Expected_Delivery_Time THEN 1 ELSE 0 END) AS On_Time_Shipments
FROM Shipments;

-- -----------------------------------------------------------------------------
-- View 2: vw_delivery_performance
-- Purpose: Analyzes on-time delivery percentages, cycle times, and delay metrics.
-- Filtering: Calculates delay only for completed deliveries (Actual_Delivery_Time NOT NULL).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    ROUND(
        (SUM(CASE WHEN Actual_Delivery_Time <= Expected_Delivery_Time THEN 1 ELSE 0 END) / 
        NULLIF(COUNT(CASE WHEN Actual_Delivery_Time IS NOT NULL THEN 1 END), 0)) * 100, 
        2
    ) AS On_Time_Delivery_Percentage,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, Dispatch_Time, Actual_Delivery_Time) / 60.0), 2) AS Avg_Delivery_Time_Hours,
    ROUND(AVG(CASE 
        WHEN Actual_Delivery_Time > Expected_Delivery_Time 
        THEN TIMESTAMPDIFF(MINUTE, Expected_Delivery_Time, Actual_Delivery_Time) / 60.0 
        ELSE 0 
    END), 2) AS Avg_Delay_Hours,
    ROUND(MAX(CASE 
        WHEN Actual_Delivery_Time > Expected_Delivery_Time 
        THEN TIMESTAMPDIFF(MINUTE, Expected_Delivery_Time, Actual_Delivery_Time) / 60.0 
        ELSE 0 
    END), 2) AS Max_Delay_Hours,
    ROUND(AVG(Distance_KM), 2) AS Avg_Distance_KM
FROM Shipments
WHERE Shipment_Status = 'Delivered';

-- -----------------------------------------------------------------------------
-- View 3: vw_vehicle_utilization
-- Purpose: Evaluates fleet operational readiness and mileage per vehicle.
-- Joins: Vehicles LEFT JOIN Shipments to account for idle vehicles with 0 trips.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_vehicle_utilization AS
SELECT
    v.Vehicle_ID,
    v.Vehicle_Number,
    v.Vehicle_Type,
    v.Capacity_KG,
    v.Fuel_Type,
    v.Vehicle_Status,
    COUNT(s.Shipment_ID) AS Total_Trips_Assigned,
    COALESCE(SUM(s.Distance_KM), 0.00) AS Total_Distance_Traveled_KM,
    COALESCE(SUM(s.Fuel_Cost), 0.00) AS Total_Fuel_Expenditure,
    CASE 
        WHEN COUNT(s.Shipment_ID) > 0 THEN 'Utilized'
        ELSE 'Idle'
    END AS Utilization_Category
FROM Vehicles v
LEFT JOIN Shipments s ON v.Vehicle_ID = s.Vehicle_ID
GROUP BY 
    v.Vehicle_ID, 
    v.Vehicle_Number, 
    v.Vehicle_Type, 
    v.Capacity_KG, 
    v.Fuel_Type, 
    v.Vehicle_Status;

-- -----------------------------------------------------------------------------
-- View 4: vw_driver_scorecard
-- Purpose: Compiles objective performance metrics per driver.
-- Joins: Drivers LEFT JOIN Shipments.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_driver_scorecard AS
SELECT
    d.Driver_ID,
    d.Driver_Name,
    d.License_Type,
    d.Experience_Years,
    d.Rating AS Baseline_Rating,
    d.Driver_Status,
    COUNT(s.Shipment_ID) AS Total_Assigned_Shipments,
    SUM(CASE WHEN s.Shipment_Status = 'Delivered' THEN 1 ELSE 0 END) AS Completed_Deliveries,
    ROUND(
        (SUM(CASE WHEN s.Shipment_Status = 'Delivered' AND s.Actual_Delivery_Time <= s.Expected_Delivery_Time THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN s.Shipment_Status = 'Delivered' THEN 1 ELSE 0 END), 0)) * 100, 
        2
    ) AS Driver_On_Time_Percentage,
    ROUND(AVG(CASE WHEN s.Shipment_Status = 'Delivered' THEN TIMESTAMPDIFF(MINUTE, s.Dispatch_Time, s.Actual_Delivery_Time) / 60.0 END), 2) AS Avg_Trip_Duration_Hours
FROM Drivers d
LEFT JOIN Shipments s ON d.Driver_ID = s.Driver_ID
GROUP BY
    d.Driver_ID,
    d.Driver_Name,
    d.License_Type,
    d.Experience_Years,
    d.Rating,
    d.Driver_Status;

-- -----------------------------------------------------------------------------
-- View 5: vw_cost_operations
-- Purpose: Financial KPIs breaking down freight costs, fuel costs, and unit economics.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_cost_operations AS
SELECT
    COUNT(Shipment_ID) AS Total_Shipments,
    ROUND(SUM(Shipping_Cost), 2) AS Total_Shipping_Cost,
    ROUND(SUM(Fuel_Cost), 2) AS Total_Fuel_Cost,
    ROUND(SUM(Shipping_Cost + Fuel_Cost), 2) AS Total_Logistics_Cost,
    ROUND(AVG(Shipping_Cost + Fuel_Cost), 2) AS Avg_Cost_Per_Shipment,
    ROUND(SUM(Shipping_Cost + Fuel_Cost) / NULLIF(SUM(Distance_KM), 0), 2) AS Cost_Per_KM,
    ROUND(SUM(Fuel_Cost) / NULLIF(SUM(Distance_KM), 0), 2) AS Fuel_Cost_Per_KM
FROM Shipments
WHERE Shipment_Status != 'Cancelled';

-- -----------------------------------------------------------------------------
-- View 6: vw_route_performance
-- Purpose: Evaluates corridor logistics between pickup and delivery hubs.
-- Joins: Shipments -> Orders -> Locations (Pickup) & Locations (Delivery).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_route_performance AS
SELECT
    CONCAT(loc_origin.City, ' -> ', loc_dest.City) AS Route_Name,
    loc_origin.City AS Origin_City,
    loc_dest.City AS Destination_City,
    loc_origin.State AS Origin_State,
    loc_dest.State AS Destination_State,
    COUNT(s.Shipment_ID) AS Total_Shipments,
    ROUND(AVG(s.Distance_KM), 1) AS Avg_Distance_KM,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.Dispatch_Time, s.Actual_Delivery_Time) / 60.0), 2) AS Avg_Transit_Hours,
    SUM(CASE WHEN s.Actual_Delivery_Time > s.Expected_Delivery_Time THEN 1 ELSE 0 END) AS Total_Delayed_Shipments,
    ROUND(
        (SUM(CASE WHEN s.Shipment_Status = 'Delivered' AND s.Actual_Delivery_Time <= s.Expected_Delivery_Time THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN s.Shipment_Status = 'Delivered' THEN 1 ELSE 0 END), 0)) * 100,
        2
    ) AS Route_On_Time_Percentage,
    ROUND(SUM(s.Shipping_Cost + s.Fuel_Cost), 2) AS Total_Route_Expenditure
FROM Shipments s
INNER JOIN Orders o ON s.Order_ID = o.Order_ID
INNER JOIN Locations loc_origin ON o.Pickup_Location_ID = loc_origin.Location_ID
INNER JOIN Locations loc_dest ON o.Delivery_Location_ID = loc_dest.Location_ID
GROUP BY
    loc_origin.City,
    loc_dest.City,
    loc_origin.State,
    loc_dest.State;

SELECT 'All 6 analytical SQL views created successfully!' AS status_message;
