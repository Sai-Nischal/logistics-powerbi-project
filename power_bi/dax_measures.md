# Analytical DAX Measures Library

Organize all calculations inside a dedicated table named `_Measures`.

---

## 1. Shipment Volume Measures

### Total Shipments
```dax
Total Shipments = COUNTROWS(FactShipments)
```
- **Filter Context**: Evaluates the count of rows in `FactShipments` under the current visual slicer context.

### Delivered Shipments
```dax
Delivered Shipments = 
CALCULATE(
    [Total Shipments],
    FactShipments[Shipment_Status] = "Delivered"
)
```
- **Filter Context**: Overrides or adds filter where `Shipment_Status` equals "Delivered".

### In Transit Shipments
```dax
In Transit Shipments = 
CALCULATE(
    [Total Shipments],
    FactShipments[Shipment_Status] IN {"In Transit", "Dispatched"}
)
```

### Delayed Shipments
```dax
Delayed Shipments = 
CALCULATE(
    [Total Shipments],
    FactShipments[Actual_Delivery_Time] > FactShipments[Expected_Delivery_Time]
        || FactShipments[Shipment_Status] = "Delayed"
)
```

### Cancelled Shipments
```dax
Cancelled Shipments = 
CALCULATE(
    [Total Shipments],
    FactShipments[Shipment_Status] = "Cancelled"
)
```

---

## 2. Delivery Performance & SLA Metrics

### On-Time Shipments
```dax
On-Time Shipments = 
CALCULATE(
    [Total Shipments],
    FactShipments[Shipment_Status] = "Delivered",
    FactShipments[Actual_Delivery_Time] <= FactShipments[Expected_Delivery_Time]
)
```

### On-Time Delivery % (OTD %)
```dax
On-Time Delivery % = 
DIVIDE(
    [On-Time Shipments],
    [Delivered Shipments],
    0
)
```
- **Formatting**: Percentage (`0.0%`). Uses `DIVIDE` to avoid divide-by-zero errors.

### Average Delivery Time (Hours)
```dax
Average Delivery Time = 
AVERAGEX(
    FILTER(FactShipments, FactShipments[Shipment_Status] = "Delivered"),
    FactShipments[Transit_Hours]
)
```

### Average Delay Hours
```dax
Average Delay Hours = 
AVERAGEX(
    FILTER(FactShipments, FactShipments[Delay_Hours] > 0),
    FactShipments[Delay_Hours]
)
```

---

## 3. Fleet & Asset Utilization Metrics

### Total Vehicles
```dax
Total Vehicles = DISTINCTCOUNT(DimVehicle[Vehicle_ID])
```

### Active Vehicles
```dax
Active Vehicles = 
CALCULATE(
    [Total Vehicles],
    DimVehicle[Vehicle_Status] = "Active"
)
```

### Vehicle Utilization %
```dax
Vehicle Utilization % = 
DIVIDE(
    DISTINCTCOUNT(FactShipments[Vehicle_ID]),
    [Active Vehicles],
    0
)
```

### Average Distance per Vehicle (KM)
```dax
Average Distance per Vehicle = 
DIVIDE(
    SUM(FactShipments[Distance_KM]),
    DISTINCTCOUNT(FactShipments[Vehicle_ID]),
    0
)
```

---

## 4. Driver Scorecard Metrics

### Total Drivers
```dax
Total Drivers = DISTINCTCOUNT(DimDriver[Driver_ID])
```

### Active Drivers
```dax
Active Drivers = 
CALCULATE(
    [Total Drivers],
    DimDriver[Driver_Status] = "Active"
)
```

### Average Driver Rating
```dax
Average Driver Rating = AVERAGE(DimDriver[Rating])
```

### Driver On-Time %
```dax
Driver On-Time % = 
VAR DriverDelivered = CALCULATE([Total Shipments], FactShipments[Shipment_Status] = "Delivered")
VAR DriverOnTime = CALCULATE([On-Time Shipments])
RETURN
    DIVIDE(DriverOnTime, DriverDelivered, 0)
```

---

## 5. Logistics Cost & Financial Unit Economics

### Total Base Shipping Cost
```dax
Total Shipping Cost = SUM(FactShipments[Shipping_Cost])
```

### Total Fuel Cost
```dax
Total Fuel Cost = SUM(FactShipments[Fuel_Cost])
```

### Total Logistics Cost
```dax
Total Logistics Cost = [Total Shipping Cost] + [Total Fuel Cost]
```

### Cost per Shipment
```dax
Cost per Shipment = 
DIVIDE(
    [Total Logistics Cost],
    [Total Shipments],
    0
)
```

### Cost per KM
```dax
Cost per KM = 
DIVIDE(
    [Total Logistics Cost],
    SUM(FactShipments[Distance_KM]),
    0
)
```

---

## 6. Time Intelligence Metrics (Calendar-Aware)

### Current Month Shipments
```dax
Current Month Shipments = 
TOTALMTD([Total Shipments], DimDate[DateKey])
```

### Previous Month Shipments
```dax
Previous Month Shipments = 
CALCULATE(
    [Total Shipments],
    DATEADD(DimDate[DateKey], -1, MONTH)
)
```

### MoM Shipment Growth %
```dax
MoM Growth % = 
VAR CurrentM = [Total Shipments]
VAR PrevM = [Previous Month Shipments]
RETURN
    DIVIDE(CurrentM - PrevM, PrevM, 0)
```

### Current Year Shipments
```dax
Current Year Shipments = 
TOTALYTD([Total Shipments], DimDate[DateKey])
```

### Previous Year Shipments
```dax
Previous Year Shipments = 
CALCULATE(
    [Total Shipments],
    SAMEPERIODLASTYEAR(DimDate[DateKey])
)
```

### YoY Shipment Growth %
```dax
YoY Growth % = 
VAR CurrentY = [Total Shipments]
VAR PrevY = [Previous Year Shipments]
RETURN
    DIVIDE(CurrentY - PrevY, PrevY, 0)
```

---

## 7. IoT Telemetry & Real-Time Tracking Metrics

### Active Pinging Vehicles
```dax
Active Pinging Vehicles = DISTINCTCOUNT(FactVehicleLocations[Vehicle_ID])
```

### Average Vehicle Speed (KM/H)
```dax
Average Speed KMH = AVERAGE(FactVehicleLocations[Speed_KMH])
```

### Average Fleet Fuel Level %
```dax
Average Fleet Fuel Level = AVERAGE(FactVehicleLocations[Fuel_Level])
```

---

## 8. Customer Demand & Revenue Analytics

### Total Order Value
```dax
Total Order Value = SUM(FactOrders[Order_Value])
```

### Average Order Value (AOV)
```dax
Average Order Value = AVERAGE(FactOrders[Order_Value])
```

### Total Freight Weight (KG)
```dax
Total Freight Weight KG = SUM(FactOrders[Weight_KG])
```

### Total Payments Collected
```dax
Total Payments Collected = 
CALCULATE(
    SUM(FactPayments[Amount]),
    FactPayments[Payment_Status] = "Completed"
)
```

### Payment Success Rate %
```dax
Payment Success Rate % = 
DIVIDE(
    CALCULATE(COUNTROWS(FactPayments), FactPayments[Payment_Status] = "Completed"),
    COUNTROWS(FactPayments),
    0
)
```
