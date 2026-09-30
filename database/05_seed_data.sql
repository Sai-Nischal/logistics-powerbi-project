-- =============================================================================
-- Script 05: Seed Master Reference Data (MySQL Syntax)
-- Project: Real-Time Logistics & Delivery Performance Analytics
-- Purpose: Populates foundational dimension master data (Locations, Drivers, Vehicles)
-- =============================================================================

USE logistics_db;

-- -----------------------------------------------------------------------------
-- 1. Master Logistics Locations (Hubs, Warehouses, Distribution Centers in India)
-- Accurate Geographic Coordinates for mapping & routing
-- -----------------------------------------------------------------------------
INSERT INTO Locations (Location_ID, Location_Name, City, State, Latitude, Longitude, Location_Type) VALUES
('LOC_CHN_01', 'Chennai Central Fulfillment Hub', 'Chennai', 'Tamil Nadu', 13.082680, 80.270718, 'Warehouse'),
('LOC_CHN_02', 'Sriperumbudur Industrial DC', 'Chennai', 'Tamil Nadu', 12.969188, 79.948293, 'Distribution Center'),
('LOC_BLR_01', 'Bengaluru South Logistics Park', 'Bengaluru', 'Karnataka', 12.839939, 77.677003, 'Warehouse'),
('LOC_BLR_02', 'Peenya Industrial Logistics Hub', 'Bengaluru', 'Karnataka', 13.028543, 77.519572, 'Distribution Center'),
('LOC_HYD_01', 'Hyderabad Shamshabad Cargo Hub', 'Hyderabad', 'Telangana', 17.240263, 78.429385, 'Hub'),
('LOC_HYD_02', 'Secunderabad Gateway Center', 'Hyderabad', 'Telangana', 17.439930, 78.498274, 'Distribution Center'),
('LOC_CBE_01', 'Coimbatore Avinashi Freight Hub', 'Coimbatore', 'Tamil Nadu', 11.016844, 76.955832, 'Distribution Center'),
('LOC_MDU_01', 'Madurai Ring Road Cargo Terminal', 'Madurai', 'Tamil Nadu', 9.925201, 78.119775, 'Hub'),
('LOC_TRZ_01', 'Tiruchirappalli Central Transit Hub', 'Tiruchirappalli', 'Tamil Nadu', 10.790483, 78.704672, 'Hub'),
('LOC_SLM_01', 'Salem Junction Logistics Yard', 'Salem', 'Tamil Nadu', 11.664325, 78.146014, 'Distribution Center'),
('LOC_VLR_01', 'Vellore Ranipet Industrial DC', 'Vellore', 'Tamil Nadu', 12.916517, 79.132499, 'Warehouse'),
('LOC_TPT_01', 'Tirupati Renigunta Cargo Hub', 'Tirupati', 'Andhra Pradesh', 13.628756, 79.419179, 'Hub'),
('LOC_BOM_01', 'Bhiwandi Mega Logistics Park', 'Mumbai', 'Maharashtra', 19.296537, 73.063121, 'Warehouse'),
('LOC_BOM_02', 'JNPT Port Container Terminal', 'Mumbai', 'Maharashtra', 18.949887, 72.951111, 'Hub'),
('LOC_PNQ_01', 'Pune Chakan Auto Corridor Hub', 'Pune', 'Maharashtra', 18.760611, 73.863611, 'Distribution Center'),
('LOC_DEL_01', 'Delhi NCR Okhla Logistics Center', 'Delhi', 'Delhi', 28.535516, 77.273178, 'Warehouse'),
('LOC_JAI_01', 'Jaipur VKI Transport Terminal', 'Jaipur', 'Rajasthan', 26.985472, 75.772583, 'Distribution Center'),
('LOC_CCU_01', 'Kolkata Dankuni Freight Hub', 'Kolkata', 'West Bengal', 22.684126, 88.291771, 'Warehouse'),
('LOC_AMD_01', 'Ahmedabad Sanand Freight Depot', 'Ahmedabad', 'Gujarat', 22.986752, 72.381467, 'Distribution Center'),
('LOC_COK_01', 'Kochi Vallarpadam Container Terminal', 'Kochi', 'Kerala', 9.981636, 76.249870, 'Hub')
ON DUPLICATE KEY UPDATE Location_Name = VALUES(Location_Name);

-- -----------------------------------------------------------------------------
-- 2. Master Driver Roster (Sample Seed Baseline)
-- -----------------------------------------------------------------------------
INSERT INTO Drivers (Driver_ID, Driver_Name, License_Type, Experience_Years, Phone, Rating, Employment_Date, Driver_Status) VALUES
('DRV_0001', 'Rajesh Sharma', 'Heavy Transport', 12, '+91-9876543210', 4.85, '2021-03-15', 'Active'),
('DRV_0002', 'Karthik Raman', 'Commercial', 8, '+91-9876543211', 4.90, '2021-06-01', 'Active'),
('DRV_0003', 'Suresh Kumar', 'Heavy Transport', 15, '+91-9876543212', 4.70, '2020-01-10', 'Active'),
('DRV_0004', 'Manoj Patil', 'Commercial', 6, '+91-9876543213', 4.45, '2022-04-18', 'Active'),
('DRV_0005', 'Arunachalam S', 'Heavy Transport', 10, '+91-9876543214', 4.80, '2021-08-20', 'Active'),
('DRV_0006', 'Venkatesh Rao', 'Commercial', 5, '+91-9876543215', 4.60, '2022-11-05', 'Active'),
('DRV_0007', 'Amit Singh', 'Heavy Transport', 9, '+91-9876543216', 4.75, '2021-02-12', 'Active'),
('DRV_0008', 'Dinesh Verma', 'Light Commercial', 4, '+91-9876543217', 4.30, '2023-01-15', 'Active'),
('DRV_0009', 'Praveen Nair', 'Commercial', 7, '+91-9876543218', 4.65, '2022-07-25', 'Active'),
('DRV_0010', 'Gurpreet Singh', 'Heavy Transport', 14, '+91-9876543219', 4.92, '2020-05-19', 'Active')
ON DUPLICATE KEY UPDATE Driver_Name = VALUES(Driver_Name);

-- -----------------------------------------------------------------------------
-- 3. Master Vehicle Fleet (Sample Seed Baseline)
-- -----------------------------------------------------------------------------
INSERT INTO Vehicles (Vehicle_ID, Vehicle_Number, Vehicle_Type, Capacity_KG, Fuel_Type, Fuel_Efficiency, Driver_ID, Vehicle_Status, Registration_Date) VALUES
('VEH_0001', 'TN-01-AB-1234', 'Heavy Multi-Axle Truck', 25000.00, 'Diesel', 3.80, 'DRV_0001', 'Active', '2021-04-10'),
('VEH_0002', 'KA-03-CD-5678', 'Medium Duty Truck', 12000.00, 'Diesel', 5.50, 'DRV_0002', 'Active', '2021-07-15'),
('VEH_0003', 'MH-04-EF-9012', 'Heavy Multi-Axle Truck', 28000.00, 'Diesel', 3.50, 'DRV_0003', 'Active', '2020-02-20'),
('VEH_0004', 'TS-09-GH-3456', 'Light Commercial Vehicle', 4500.00, 'Diesel', 8.20, 'DRV_0004', 'Active', '2022-05-12'),
('VEH_0005', 'TN-09-IJ-7890', 'Medium Duty Truck', 10000.00, 'Diesel', 5.80, 'DRV_0005', 'Active', '2021-09-08'),
('VEH_0006', 'DL-01-KL-2345', 'Electric Delivery Van', 2500.00, 'Electric', 12.00, 'DRV_0008', 'Active', '2023-02-01'),
('VEH_0007', 'GJ-01-MN-6789', 'Heavy Multi-Axle Truck', 24000.00, 'Diesel', 3.90, 'DRV_0007', 'Active', '2021-03-14'),
('VEH_0008', 'WB-02-OP-0123', 'Medium Duty Truck', 14000.00, 'Diesel', 5.20, 'DRV_0010', 'Active', '2020-06-30')
ON DUPLICATE KEY UPDATE Vehicle_Number = VALUES(Vehicle_Number);

SELECT 'Master reference seed data inserted successfully!' AS status_message;
