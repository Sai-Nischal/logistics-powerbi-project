-- =============================================================================
-- Script 02: Create Core Tables (MySQL Syntax)
-- Project: Real-Time Logistics & Delivery Performance Analytics
-- Engine: InnoDB (Supports Foreign Keys, Transactions, and Row-level locking)
-- =============================================================================

USE logistics_db;

-- -----------------------------------------------------------------------------
-- 1. Customers Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Customers (
    Customer_ID VARCHAR(20) NOT NULL,
    Customer_Name VARCHAR(100) NOT NULL,
    Customer_Type VARCHAR(20) NOT NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Postal_Code VARCHAR(10) NULL,
    Registration_Date DATE NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (Customer_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. Drivers Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Drivers (
    Driver_ID VARCHAR(20) NOT NULL,
    Driver_Name VARCHAR(100) NOT NULL,
    License_Type VARCHAR(20) NOT NULL,
    Experience_Years INT NOT NULL DEFAULT 0,
    Phone VARCHAR(20) NULL,
    Rating DECIMAL(3,2) NULL DEFAULT 5.00,
    Employment_Date DATE NOT NULL,
    Driver_Status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_drivers PRIMARY KEY (Driver_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. Vehicles Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Vehicles (
    Vehicle_ID VARCHAR(20) NOT NULL,
    Vehicle_Number VARCHAR(20) NOT NULL,
    Vehicle_Type VARCHAR(30) NOT NULL,
    Capacity_KG DECIMAL(10,2) NOT NULL,
    Fuel_Type VARCHAR(20) NOT NULL,
    Fuel_Efficiency DECIMAL(5,2) NOT NULL,
    Driver_ID VARCHAR(20) NULL,
    Vehicle_Status VARCHAR(20) NOT NULL DEFAULT 'Active',
    Registration_Date DATE NOT NULL,
    CONSTRAINT pk_vehicles PRIMARY KEY (Vehicle_ID),
    CONSTRAINT uk_vehicle_number UNIQUE (Vehicle_Number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. Locations Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Locations (
    Location_ID VARCHAR(20) NOT NULL,
    Location_Name VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Latitude DECIMAL(9,6) NOT NULL,
    Longitude DECIMAL(9,6) NOT NULL,
    Location_Type VARCHAR(30) NOT NULL,
    CONSTRAINT pk_locations PRIMARY KEY (Location_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. Orders Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Orders (
    Order_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Order_Date DATETIME NOT NULL,
    Pickup_Location_ID VARCHAR(20) NOT NULL,
    Delivery_Location_ID VARCHAR(20) NOT NULL,
    Priority VARCHAR(20) NOT NULL DEFAULT 'Standard',
    Order_Value DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    Weight_KG DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    Expected_Delivery_Date DATETIME NOT NULL,
    Order_Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT pk_orders PRIMARY KEY (Order_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. Shipments Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Shipments (
    Shipment_ID VARCHAR(20) NOT NULL,
    Order_ID VARCHAR(20) NOT NULL,
    Vehicle_ID VARCHAR(20) NOT NULL,
    Driver_ID VARCHAR(20) NOT NULL,
    Dispatch_Time DATETIME NOT NULL,
    Expected_Delivery_Time DATETIME NOT NULL,
    Actual_Delivery_Time DATETIME NULL,
    Distance_KM DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Shipment_Status VARCHAR(20) NOT NULL DEFAULT 'Dispatched',
    Shipping_Cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Fuel_Cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_shipments PRIMARY KEY (Shipment_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. Delivery_Events Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Delivery_Events (
    Event_ID BIGINT NOT NULL AUTO_INCREMENT,
    Shipment_ID VARCHAR(20) NOT NULL,
    Event_Time DATETIME NOT NULL,
    Event_Type VARCHAR(30) NOT NULL,
    Location_ID VARCHAR(20) NULL,
    Remarks TEXT NULL,
    CONSTRAINT pk_delivery_events PRIMARY KEY (Event_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. Vehicle_Locations Table (Real-Time Telemetry Pings)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Vehicle_Locations (
    Location_Record_ID BIGINT NOT NULL AUTO_INCREMENT,
    Vehicle_ID VARCHAR(20) NOT NULL,
    Timestamp DATETIME NOT NULL,
    Latitude DECIMAL(9,6) NOT NULL,
    Longitude DECIMAL(9,6) NOT NULL,
    Speed_KMH DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    Fuel_Level DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    Engine_Status VARCHAR(20) NOT NULL DEFAULT 'Running',
    CONSTRAINT pk_vehicle_locations PRIMARY KEY (Location_Record_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 9. Payments Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Payments (
    Payment_ID VARCHAR(20) NOT NULL,
    Order_ID VARCHAR(20) NOT NULL,
    Payment_Date DATETIME NOT NULL,
    Payment_Method VARCHAR(30) NOT NULL,
    Payment_Status VARCHAR(20) NOT NULL DEFAULT 'Completed',
    Amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_payments PRIMARY KEY (Payment_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
