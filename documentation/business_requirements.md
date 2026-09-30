# Business Requirements Document (BRD)

## Project Title
**Real-Time Logistics & Delivery Performance Analytics**

---

## 1. Executive Summary
Logistics and supply chain management require end-to-end visibility across order fulfillment, vehicle telemetry, delivery performance, driver safety, and operational costs. This project establishes an enterprise-grade analytics control tower to monitor key operational metrics, pinpoint delivery bottlenecks, optimize transportation expenditures, and track vehicle/driver performance in real-time and across historical timelines.

---

## 2. Core Business Objectives

1. **Improve Delivery Reliability**: Target and track On-Time Delivery (OTD) percentage across priority levels, routes, and geographic hubs.
2. **Reduce Delivery Bottlenecks**: Categorize delay types and identify specific high-friction corridors (e.g., Chennai → Bengaluru).
3. **Fleet Efficiency & Utilization**: Measure active vs. idle fleet capacity, total distance traveled per vehicle, and fuel efficiency metrics.
4. **Driver Performance Scorecard**: Evaluate driver efficiency, total completed shipments, and on-time percentages without biased ratings.
5. **Cost Optimization**: Track overall shipping cost, fuel expense per kilometer, and cost per shipment volume.
6. **Near Real-Time Operations Monitoring**: Monitor vehicle GPS telemetry and live delivery state updates via a simulated real-time pipeline.

---

## 3. Key Operational Questions Answered

| # | Business Question | Target KPI / Visual |
|---|-------------------|---------------------|
| 1 | How many shipments are currently in transit, delayed, or delivered? | Summary Cards & Status Breakdown |
| 2 | What percentage of shipments are delivered on time? | On-Time Delivery % (Target > 95%) |
| 3 | Which transport routes suffer from the highest delivery delays? | Route Bottleneck Matrix & Delay Heatmap |
| 4 | Which cities handle the highest shipment volumes? | Geographic Volume Distribution |
| 5 | What is the total transportation cost per kilometer? | Cost/KM KPI & Fuel Efficiency Trend |
| 6 | Which vehicles are underutilized or exceed normal mileage limits? | Vehicle Utilization & Mileage Bar Chart |
| 7 | How do delivery delays vary across order priority levels (Express vs Standard)? | Delay distribution by Priority Slicer |
| 8 | How has logistics cost evolved month-over-month? | Time Series Cost Analysis (MoM / YoY) |

---

## 4. Operational Entities & Data Domain Scope

- **Customers**: Retail and enterprise buyers placing shipment requests.
- **Orders**: Commercial requests detailing pickup/delivery locations, weight, value, and priority.
- **Shipments**: Operational execution of orders assigned to vehicles and drivers.
- **Drivers**: Fleet personnel executing transport runs.
- **Vehicles**: Transportation assets (Trucks, Vans, Cargo Containers).
- **Locations**: Origin/Destination hubs, warehouses, and customer addresses across major Indian logistics corridors.
- **Delivery Events**: Lifecycle milestones (`Order Created` -> `Picked Up` -> `In Transit` -> `Out for Delivery` -> `Delivered` / `Delayed`).
- **Vehicle Telemetry**: High-frequency GPS pings tracking latitude, longitude, speed, and fuel level.
- **Payments**: Financial records matching order values and payment statuses.
