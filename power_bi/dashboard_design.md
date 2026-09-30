# 7-Page Enterprise Logistics Power BI Dashboard Suite

This document defines the architecture, visual configurations, data field bindings, and design system for all **7 dashboard pages** in the Power BI Operations Suite.

---

## 🎨 Design System & Visual Tokens

- **Theme**: Premium Operations Control Tower (Dark Mode)
- **Canvas Dimensions**: 16:9 (`1920 x 1080` or `1280 x 720`)
- **Background**: `#0F172A` (Slate Dark Navy)
- **Visual Card Background**: `#1E293B` (Charcoal Slate) with `#334155` subtle 1px border & 8px corner radius
- **Typography**: `Segoe UI Semibold` (Headers), `Segoe UI` (Data labels / Values)
- **Palette**:
  - Primary Accent (Cyan): `#38BDF8`
  - Success / On-Time (Emerald Green): `#10B981`
  - Warning / Caution (Amber Gold): `#F59E0B`
  - Critical / Delay (Coral Red): `#EF4444`
  - Electric Fleet / Neutral (Indigo Purple): `#818CF8`
  - Text Primary: `#F8FAFC`
  - Text Secondary: `#94A3B8`

---

## 📌 Page Navigation Header Bar (Global Component)
Present at the top of all 7 pages:
- **Left**: Corporate Logo + Project Title: `"LOGISTICS CONTROL TOWER | REAL-TIME OPERATIONS"`
- **Center**: Navigation Buttons (Page 1 through 7) configured via **Action -> Page Navigation**
- **Right**: Current System Timestamp + Active Filter Summary Badge

---

## 📊 DASHBOARD 1: Executive Overview & Logistics Control Tower
**Target Persona**: Chief Supply Chain Officer & VP of Logistics  
**Business Goal**: Macro-level visibility into fulfillment health, operational volume, and SLA adherence.

### 1. KPI Metric Strip (Top Row)
1. **Total Volume**: `[Total Shipments]` | Subtitle: *All time orders dispatched*
2. **Delivered**: `[Delivered Shipments]` | Color: `#10B981`
3. **Active in Transit**: `[In Transit Shipments]` | Color: `#38BDF8`
4. **Delayed Shipments**: `[Delayed Shipments]` | Color: `#EF4444`
5. **On-Time Delivery %**: `[On-Time Delivery %]` | Goal: `> 85.0%` | Color: Dynamic conditional formatting
6. **Total Logistics Cost**: `[Total Logistics Cost]` | Currency Format: `₹`

### 2. Core Visuals
- **Visual 1 (Donut Chart)**: *Shipments by Operational Status*
  - Legend: `FactShipments[Shipment_Status]`
  - Values: `[Total Shipments]`
- **Visual 2 (Line & Clustered Column Chart)**: *Daily Shipment Volume vs On-Time Delivery %*
  - X-Axis: `DimDate[DateKey]`
  - Column Values: `[Total Shipments]`
  - Line Values: `[On-Time Delivery %]`
- **Visual 3 (Filled Map / Azure Map)**: *Logistics Fulfillment Corridor Network*
  - Location: `DimLocation[City]`
  - Latitude: `DimLocation[Latitude]`, Longitude: `DimLocation[Longitude]`
  - Bubble Size: `[Total Shipments]`
  - Tooltip: `City`, `State`, `Total Shipments`, `On-Time Delivery %`
- **Visual 4 (Table / Matrix Visual)**: *High Priority Active Watchlist*
  - Filter: `FactShipments[Shipment_Status] IN {"In Transit", "Delayed"}`
  - Columns: `Shipment_ID`, `Driver_Name`, `Destination_City`, `Expected_Delivery_Time`, `Delay_Category`

---

## 🛰️ DASHBOARD 2: Real-Time Fleet Telemetry & Live IoT Operations
**Target Persona**: Dispatch Control Center & IoT Telemetry Engineers  
**Business Goal**: Track live GPS positions, detect speeding, monitor engine status, and safeguard in-transit cargo.

### 1. KPI Metric Strip
1. **Active Pinging Vehicles**: `[Active Pinging Vehicles]`
2. **Average Speed**: `[Average Speed KMH]` (KM/H)
3. **Fleet Fuel Level**: `[Average Fleet Fuel Level]` (%)
4. **Vehicles with Running Engines**: Count of `FactVehicleLocations[Engine_Status] = "Running"`

### 2. Core Visuals
- **Visual 1 (ArcGIS / Azure Map Visual)**: *Real-Time Vehicle GPS Ping Trail*
  - Latitude: `FactVehicleLocations[Latitude]`
  - Longitude: `FactVehicleLocations[Longitude]`
  - Size: `FactVehicleLocations[Speed_KMH]`
  - Color / Category: `FactVehicleLocations[Engine_Status]` (Green = Running, Red = Idle/Stopped)
- **Visual 2 (Gauge Visual)**: *Fleet Average Speed Radar*
  - Value: `[Average Speed KMH]`
  - Min: `0`, Max: `100`, Target: `55`
- **Visual 3 (Histogram / Column Chart)**: *Vehicle Speed Distribution Brackets*
  - X-Axis: Speed Bins (`0-20`, `20-40`, `40-60`, `60-80`, `80+` KM/H)
  - Values: `COUNT(Location_Record_ID)`
- **Visual 4 (Live Streaming Telemetry Feed Table)**:
  - Columns: `Vehicle_ID`, `Timestamp`, `Latitude`, `Longitude`, `Speed_KMH`, `Fuel_Level`, `Engine_Status`
  - Sort: `Timestamp` Descending

---

## ⏱️ DASHBOARD 3: Delivery Performance & SLA Delay Analytics
**Target Persona**: SLA Operations Managers & Corridor Leads  
**Business Goal**: Identify delay root causes, evaluate delay severity, and isolate underperforming transit corridors.

### 1. KPI Metric Strip
1. **On-Time Delivery %**: `[On-Time Delivery %]`
2. **Average Delivery Time**: `[Average Delivery Time]` (Hours)
3. **Average Delay Hours**: `[Average Delay Hours]` (Hours late)
4. **Max Recorded Delay**: `MAX(FactShipments[Delay_Hours])`

### 2. Core Visuals
- **Visual 1 (Stacked Bar Chart)**: *Shipments by Delay Severity Bucket*
  - Y-Axis: `FactShipments[Delay_Category]` (`On Time`, `0-2h Late`, `2-6h Late`, `6-12h Late`, `12h+ Late`)
  - X-Axis: `[Total Shipments]`
  - Data Labels: Percentage of total
- **Visual 2 (Clustered Bar Chart)**: *Delay Percentage by Priority Tier*
  - Y-Axis: `FactOrders[Priority]` (`Urgent`, `Same Day`, `Express`, `Standard`)
  - X-Axis: `[On-Time Delivery %]`
- **Visual 3 (Horizontal Ranked Bar Chart)**: *Top 10 Most Delayed Corridors*
  - Y-Axis: `Origin_City -> Destination_City`
  - X-Axis: Delay Rate %
- **Visual 4 (Matrix Visual)**: *Delay Root Cause Breakdown*
  - Rows: `Delivery_Events[Remarks]` (e.g., Highway congestion, monsoon rain, mechanical breakdown)
  - Values: `Count of Events`, `Average Delay Duration`

---

## 🚛 DASHBOARD 4: Fleet Utilization & Maintenance Management
**Target Persona**: Fleet Asset Directors & Maintenance Supervisors  
**Business Goal**: Prevent asset wear-and-tear, balance mileage across vehicles, and optimize electric vs diesel deployment.

### 1. KPI Metric Strip
1. **Total Fleet Size**: `[Total Vehicles]`
2. **Active Vehicles**: `[Active Vehicles]`
3. **Vehicle Utilization %**: `[Vehicle Utilization %]`
4. **Avg Distance per Vehicle**: `[Average Distance per Vehicle]` (KM)

### 2. Core Visuals
- **Visual 1 (Donut Chart)**: *Fleet Operational Status*
  - Categories: `Active`, `In Maintenance`, `Retired`
  - Values: `[Total Vehicles]`
- **Visual 2 (Clustered Column Chart)**: *Total Mileage by Vehicle Type*
  - X-Axis: `DimVehicle[Vehicle_Type]`
  - Values: `SUM(FactShipments[Distance_KM])`
- **Visual 3 (Scatter Plot)**: *Vehicle Efficiency vs Mileage Correlation*
  - X-Axis: `Total Distance Traveled (KM)`
  - Y-Axis: `Fuel Efficiency (KM/L)`
  - Legend: `Fuel_Type` (Diesel, Electric)
  - Tooltip: `Vehicle_Number`, `Capacity_KG`
- **Visual 4 (Table Visual)**: *Asset Utilization & Maintenance Roster*
  - Columns: `Vehicle_ID`, `Vehicle_Number`, `Vehicle_Type`, `Fuel_Type`, `Total Trips`, `Total KM`, `Registration_Date`

---

## 👨‍✈️ DASHBOARD 5: Driver Performance & Safety Scorecards
**Target Persona**: Driver Operations Leads & HR Safety Managers  
**Business Goal**: Objective driver scorecard evaluating SLA compliance, trip experience, and safety ratings.

### 1. KPI Metric Strip
1. **Total Drivers**: `[Total Drivers]`
2. **Active Drivers**: `[Active Drivers]`
3. **Average Driver Rating**: `[Average Driver Rating]` (Out of 5.0)
4. **Fleet Driver On-Time %**: `[Driver On-Time %]`

### 2. Core Visuals
- **Visual 1 (Ranked Table Visual)**: *Driver Performance Leaderboard*
  - Columns: `Driver_Name`, `License_Type`, `Experience_Years`, `Trips_Completed`, `Driver_On-Time %`, `Baseline_Rating`
  - Sort: `Driver_On-Time %` Descending
  - Conditional Formatting: Color scale on `Driver_On-Time %`
- **Visual 2 (Scatter Plot)**: *Driver Experience vs SLA Adherence*
  - X-Axis: `Experience_Years`
  - Y-Axis: `Driver On-Time %`
  - Size: `Completed Trips`
- **Visual 3 (Clustered Column Chart)**: *Trip Volume by License Category*
  - X-Axis: `DimDriver[License_Type]` (Heavy Transport, Commercial, Light Commercial)
  - Values: `[Total Shipments]`

---

## 💰 DASHBOARD 6: Freight Cost & Financial Unit Economics
**Target Persona**: CFO, Financial Controllers & Procurement Directors  
**Business Goal**: Deconstruct freight spending, fuel expenditures, corridor profitability, and unit economics per KM.

### 1. KPI Metric Strip
1. **Total Freight Cost**: `[Total Shipping Cost]`
2. **Total Diesel/Fuel Cost**: `[Total Fuel Cost]`
3. **Total Logistics Cost**: `[Total Logistics Cost]`
4. **Cost per KM**: `[Cost per KM]` (₹/KM)
5. **Cost per Shipment**: `[Cost per Shipment]` (₹/Shipment)

### 2. Core Visuals
- **Visual 1 (Area / Stacked Column Chart)**: *Monthly Freight vs Fuel Cost Trend*
  - X-Axis: `DimDate[Month Year]`
  - Values: `[Total Shipping Cost]`, `[Total Fuel Cost]`
- **Visual 2 (Clustered Bar Chart)**: *Cost per KM by Vehicle Type*
  - Y-Axis: `DimVehicle[Vehicle_Type]`
  - Values: `[Cost per KM]` (Demonstrates cost savings of Electric Delivery Vans)
- **Visual 3 (Treemap Visual)**: *Logistics Expenditure by Corridor*
  - Group: `Origin_City`
  - Details: `Destination_City`
  - Values: `[Total Logistics Cost]`
- **Visual 4 (Scatter Plot)**: *Shipment Weight vs Shipping Cost (Tariff Verification)*
  - X-Axis: `Weight_KG`
  - Y-Axis: `Shipping_Cost`
  - Tooltip: `Shipment_ID`, `Distance_KM`

---

## 📦 DASHBOARD 7: Customer & Order Demand Analytics
**Target Persona**: Chief Commercial Officer & Regional Demand Planners  
**Business Goal**: Analyze customer purchasing patterns, fulfillment priority demand, and revenue collection.

### 1. KPI Metric Strip
1. **Total Order Value**: `[Total Order Value]` (₹)
2. **Average Order Value**: `[Average Order Value]` (₹)
3. **Total Freight Weight**: `[Total Freight Weight KG]` (KG)
4. **Payment Collection Rate**: `[Payment Success Rate %]`

### 2. Core Visuals
- **Visual 1 (Donut Chart)**: *Order Volume by Customer Segment*
  - Categories: `Enterprise`, `Retail`, `E-Commerce`, `Wholesale`
  - Values: `[Total Shipments]`
- **Visual 2 (Clustered Column Chart)**: *Revenue by Order Priority*
  - X-Axis: `FactOrders[Priority]` (`Urgent`, `Express`, `Standard`, `Same Day`)
  - Values: `[Total Order Value]`
- **Visual 3 (Filled Map)**: *Regional Demand by State / City*
  - Location: `DimCustomer[City]`
  - Values: `[Total Order Value]`
- **Visual 4 (Treemap / Bar Chart)**: *Payment Settlement Method Breakdown*
  - Category: `FactPayments[Payment_Method]` (`UPI`, `Net Banking`, `Credit Card`, `COD`, `Cheque`)
  - Values: `SUM(FactPayments[Amount])`

---

## 🔄 Interactivity, Cross-Filtering & Drill-Through Rules

1. **Global Slicers**:
   - Every page features top slicers for: `Date Range`, `Origin City`, `Destination City`, and `Priority`.
2. **Cross-Filtering**:
   - Selecting a city on any map filters all charts on the page to display metrics specific to that logistics hub.
3. **Drill-Through**:
   - Right-clicking any shipment row on Dashboard 1 or Dashboard 3 provides **"Drill Through -> Shipment Lifecycle Detail"**, showing the exact chronological events from order creation to ePOD signature.
