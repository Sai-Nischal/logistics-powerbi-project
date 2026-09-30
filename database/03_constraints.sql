-- =============================================================================
-- Script 03: Foreign Key Relationships & Business Constraints (MySQL Syntax)
-- Project: Real-Time Logistics & Delivery Performance Analytics
-- =============================================================================

USE logistics_db;

-- -----------------------------------------------------------------------------
-- 1. Foreign Key Constraints
-- -----------------------------------------------------------------------------

-- Vehicles -> Drivers
ALTER TABLE Vehicles
    ADD CONSTRAINT fk_vehicles_driver
    FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Orders -> Customers
ALTER TABLE Orders
    ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- Orders -> Locations (Pickup Node)
ALTER TABLE Orders
    ADD CONSTRAINT fk_orders_pickup_location
    FOREIGN KEY (Pickup_Location_ID) REFERENCES Locations(Location_ID)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- Orders -> Locations (Delivery Node)
ALTER TABLE Orders
    ADD CONSTRAINT fk_orders_delivery_location
    FOREIGN KEY (Delivery_Location_ID) REFERENCES Locations(Location_ID)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- Shipments -> Orders
ALTER TABLE Shipments
    ADD CONSTRAINT fk_shipments_order
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Shipments -> Vehicles
ALTER TABLE Shipments
    ADD CONSTRAINT fk_shipments_vehicle
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicles(Vehicle_ID)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- Shipments -> Drivers
ALTER TABLE Shipments
    ADD CONSTRAINT fk_shipments_driver
    FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- Delivery_Events -> Shipments
ALTER TABLE Delivery_Events
    ADD CONSTRAINT fk_delivery_events_shipment
    FOREIGN KEY (Shipment_ID) REFERENCES Shipments(Shipment_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Delivery_Events -> Locations
ALTER TABLE Delivery_Events
    ADD CONSTRAINT fk_delivery_events_location
    FOREIGN KEY (Location_ID) REFERENCES Locations(Location_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Vehicle_Locations -> Vehicles
ALTER TABLE Vehicle_Locations
    ADD CONSTRAINT fk_vehicle_locations_vehicle
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicles(Vehicle_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Payments -> Orders
ALTER TABLE Payments
    ADD CONSTRAINT fk_payments_order
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- -----------------------------------------------------------------------------
-- 2. Check Constraints (Supported in MySQL 8.0+)
-- -----------------------------------------------------------------------------

ALTER TABLE Drivers
    ADD CONSTRAINT chk_driver_rating CHECK (Rating >= 1.00 AND Rating <= 5.00),
    ADD CONSTRAINT chk_driver_experience CHECK (Experience_Years >= 0);

ALTER TABLE Vehicles
    ADD CONSTRAINT chk_vehicle_capacity CHECK (Capacity_KG > 0),
    ADD CONSTRAINT chk_fuel_efficiency CHECK (Fuel_Efficiency > 0);

ALTER TABLE Orders
    ADD CONSTRAINT chk_order_value CHECK (Order_Value >= 0),
    ADD CONSTRAINT chk_weight_kg CHECK (Weight_KG > 0);

ALTER TABLE Shipments
    ADD CONSTRAINT chk_distance_km CHECK (Distance_KM >= 0),
    ADD CONSTRAINT chk_shipping_cost CHECK (Shipping_Cost >= 0),
    ADD CONSTRAINT chk_fuel_cost CHECK (Fuel_Cost >= 0);

ALTER TABLE Vehicle_Locations
    ADD CONSTRAINT chk_speed CHECK (Speed_KMH >= 0),
    ADD CONSTRAINT chk_fuel_level CHECK (Fuel_Level >= 0 AND Fuel_Level <= 100);
