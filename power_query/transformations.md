# Power Query ETL Architecture & Transformation Guide

## 1. ETL Architecture: Where Transformations Belong & Why

In enterprise Business Intelligence, performing transformations at the correct architectural layer preserves query performance, enables Query Folding, and prevents redundant memory overhead.

| Transformation | Recommended Layer | Justification |
| :--- | :--- | :--- |
| **Data Type Casting** (e.g., Dates, Decimals, Keys) | **SQL / Power Query** | Strong types ensure relational integrity and minimize Power BI VertiPaq memory footprint. |
| **Text Standardization** (e.g., Proper Case, Trimming) | **SQL / Power Query** | Standardizes strings before indexing; folds back to database server if done early. |
| **Handling Nulls / Missing Values** | **Power Query** | Replaces null foreign keys with default placeholder keys (e.g., `-1` or `'UNKNOWN'`) to maintain star schema referential integrity. |
| **Delay Buckets & Distance Tiers** | **Power Query (M)** | Static categorization attributes belong in Dimension/Fact tables to allow slicing and dicing in visuals without DAX calculation overhead. |
| **Date / Calendar Dimension Generation** | **Power Query (M)** | Generating `DimDate` via M script ensures continuous calendar coverage regardless of missing dates in transactional fact tables. |
| **Aggregations & Ratios** (e.g., On-Time %, Cost/KM) | **DAX** | Must remain dynamic to respond instantly to slicers, cross-filtering, and visual drill-downs. |

---

## 2. Power Query Data Cleaning Checklist

When connecting Power BI to the MySQL `logistics_db`:
1. **Remove Duplicates**: Verify primary keys on `DimCustomer` (`Customer_ID`), `DimDriver` (`Driver_ID`), `DimVehicle` (`Vehicle_ID`), and `DimLocation` (`Location_ID`).
2. **Text Standardization**:
   - `Text.Trim` and `Text.Clean` on all names, cities, and statuses.
   - Standardize city names (`Text.Proper(City)`).
3. **Data Type Enforcement**:
   - Currency / Cost: `Currency` or `Fixed Decimal Number` (`Decimal.Type`).
   - Distance / Lat / Lon: `Decimal Number` (`Double.Type`).
   - Timestamps: `DateTime` (`DateTime.Type`).
   - Dates: `Date` (`Date.Type`).
   - Keys / IDs: `Text` (`Text.Type`).
4. **Handling Nulls**:
   - `Actual_Delivery_Time`: In-transit shipments will have null delivery dates. Do NOT replace with a dummy date; preserve `null` for duration calculations.
   - `Driver_ID` in `Vehicles`: Replace `null` with `'UNASSIGNED'`.

---

## 3. Power Query Calculated Columns (M Transformations)

### A. Delivery Delay Hours
Calculates the operational delay in hours for completed shipments:
```powerquery
Duration.TotalHours([Actual_Delivery_Time] - [Expected_Delivery_Time])
```

### B. Delivery Delay Category
Classifies shipment punctuality into 5 business tiers:
```powerquery
if [Actual_Delivery_Time] = null then "In Transit"
else if [Actual_Delivery_Time] <= [Expected_Delivery_Time] then "On Time"
else
    let
        delayHours = Duration.TotalHours([Actual_Delivery_Time] - [Expected_Delivery_Time])
    in
        if delayHours <= 2 then "0-2 Hours Late"
        else if delayHours <= 6 then "2-6 Hours Late"
        else if delayHours <= 12 then "6-12 Hours Late"
        else "12+ Hours Late"
```

### C. Distance Category
Segments transit corridors into logistical mileage tiers:
```powerquery
if [Distance_KM] < 150 then "Local (<150 KM)"
else if [Distance_KM] < 400 then "Regional (150-400 KM)"
else if [Distance_KM] < 800 then "Long Haul (400-800 KM)"
else "Inter-State (800+ KM)"
```

### D. Vehicle Age (Years)
Calculates asset age relative to the operational date:
```powerquery
Number.RoundDown(Duration.TotalDays(DateTime.Date(DateTime.LocalNow()) - [Registration_Date]) / 365.25)
```

### E. Date Dimension Attributes (Order & Delivery)
- **Order Month**: `Date.ToText([Order_Date], "MMM yyyy")`
- **Order Month Number**: `Date.Month([Order_Date])`
- **Order Year**: `Date.Year([Order_Date])`
- **Order Day of Week**: `Date.DayOfWeekName([Order_Date])`
