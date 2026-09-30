-- =============================================================================
-- Script 01: Create Database & User Permissions (MySQL Syntax)
-- Project: Real-Time Logistics & Delivery Performance Analytics
-- =============================================================================

-- 1. Create Database Schema
CREATE DATABASE IF NOT EXISTS logistics_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2. Use Database Context
USE logistics_db;

-- 3. (Optional) Create Application Service User
-- CREATE USER IF NOT EXISTS 'logistics_user'@'%' IDENTIFIED BY 'LogisticsSecurePass123!';
-- GRANT ALL PRIVILEGES ON logistics_db.* TO 'logistics_user'@'%';
-- FLUSH PRIVILEGES;

SELECT 'Database logistics_db created successfully!' AS status_message;
