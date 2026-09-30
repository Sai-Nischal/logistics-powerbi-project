-- =============================================================================
-- Script 04: Performance Indexing (MySQL Syntax)
-- Project: Real-Time Logistics & Delivery Performance Analytics
-- =============================================================================

USE logistics_db;

-- -----------------------------------------------------------------------------
-- 1. Indexing Frequently Queried Foreign Keys & Filter Columns
-- -----------------------------------------------------------------------------

-- Orders table lookup optimization
CREATE INDEX idx_orders_customer ON Orders(Customer_ID);
CREATE INDEX idx_orders_pickup ON Orders(Pickup_Location_ID);
CREATE INDEX idx_orders_delivery ON Orders(Delivery_Location_ID);
CREATE INDEX idx_orders_status ON Orders(Order_Status);
CREATE INDEX idx_orders_date ON Orders(Order_Date);

-- Shipments table lookup optimization (High-volume querying in BI)
CREATE INDEX idx_shipments_order ON Shipments(Order_ID);
CREATE INDEX idx_shipments_vehicle ON Shipments(Vehicle_ID);
CREATE INDEX idx_shipments_driver ON Shipments(Driver_ID);
CREATE INDEX idx_shipments_status ON Shipments(Shipment_Status);
CREATE INDEX idx_shipments_dispatch ON Shipments(Dispatch_Time);

-- Delivery Events lifecycle lookup optimization
CREATE INDEX idx_events_shipment ON Delivery_Events(Shipment_ID);
CREATE INDEX idx_events_time ON Delivery_Events(Event_Time);
CREATE INDEX idx_events_type ON Delivery_Events(Event_Type);

-- Telemetry table (High write volume & real-time range query optimization)
CREATE INDEX idx_telemetry_vehicle_time ON Vehicle_Locations(Vehicle_ID, Timestamp DESC);
CREATE INDEX idx_telemetry_timestamp ON Vehicle_Locations(Timestamp);

-- Payments lookup index
CREATE INDEX idx_payments_order ON Payments(Order_ID);
CREATE INDEX idx_payments_status ON Payments(Payment_Status);
