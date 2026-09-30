"""
Synthetic Data Generation Engine for Logistics & Delivery Performance Analytics.
Generates realistic Indian logistics data (Customers, Drivers, Vehicles, Locations,
Orders, Shipments, Delivery Events, GPS Telemetry, Payments, and Calendar).
Exports to CSV files in data/ for direct Power BI ingestion and optionally loads to MySQL.
"""

import sys
import os
import argparse
import random
import math
from pathlib import Path
from datetime import datetime, timedelta
import pandas as pd
from faker import Faker
import pymysql

# Import configuration helper
from config import get_db_connection, BATCH_INSERT_SIZE

fake = Faker('en_IN')
Faker.seed(42)
random.seed(42)

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

# =============================================================================
# Indian Logistics Hubs & Coordinates
# =============================================================================
MAJOR_CITIES = [
    {"city": "Chennai", "state": "Tamil Nadu", "lat": 13.0827, "lon": 80.2707},
    {"city": "Bengaluru", "state": "Karnataka", "lat": 12.9716, "lon": 77.5946},
    {"city": "Hyderabad", "state": "Telangana", "lat": 17.3850, "lon": 78.4867},
    {"city": "Coimbatore", "state": "Tamil Nadu", "lat": 11.0168, "lon": 76.9558},
    {"city": "Kochi", "state": "Kerala", "lat": 9.9312, "lon": 76.2673},
    {"city": "Madurai", "state": "Tamil Nadu", "lat": 9.9252, "lon": 78.1198},
    {"city": "Tiruchirappalli", "state": "Tamil Nadu", "lat": 10.7905, "lon": 78.7047},
    {"city": "Salem", "state": "Tamil Nadu", "lat": 11.6643, "lon": 78.1460},
    {"city": "Vellore", "state": "Tamil Nadu", "lat": 12.9165, "lon": 79.1325},
    {"city": "Tirupati", "state": "Andhra Pradesh", "lat": 13.6288, "lon": 79.4192},
    {"city": "Mumbai", "state": "Maharashtra", "lat": 19.0760, "lon": 72.8777},
    {"city": "Pune", "state": "Maharashtra", "lat": 18.5204, "lon": 73.8567},
    {"city": "Delhi", "state": "Delhi", "lat": 28.7041, "lon": 77.1025},
    {"city": "Jaipur", "state": "Rajasthan", "lat": 26.9124, "lon": 75.7873},
    {"city": "Kolkata", "state": "West Bengal", "lat": 22.5726, "lon": 88.3639},
    {"city": "Ahmedabad", "state": "Gujarat", "lat": 23.0225, "lon": 72.5714}
]

VEHICLE_CONFIGS = [
    {"type": "Heavy Multi-Axle Truck", "capacity": 25000, "efficiency": 3.8, "fuel": "Diesel"},
    {"type": "Medium Duty Truck", "capacity": 12000, "efficiency": 5.5, "fuel": "Diesel"},
    {"type": "Light Commercial Vehicle", "capacity": 4500, "efficiency": 8.5, "fuel": "Diesel"},
    {"type": "Electric Delivery Van", "capacity": 2200, "efficiency": 12.0, "fuel": "Electric"},
    {"type": "Refrigerated Container Truck", "capacity": 18000, "efficiency": 4.2, "fuel": "Diesel"}
]

PRIORITIES = ["Standard", "Express", "Urgent", "Same Day"]
PRIORITY_WEIGHTS = [0.55, 0.25, 0.15, 0.05]

EVENT_TYPES = [
    "Order Created",
    "Picked Up",
    "In Transit",
    "At Hub",
    "Out for Delivery",
    "Delivered",
    "Delayed",
    "Cancelled"
]

DELAY_REASONS = [
    "Severe highway congestion",
    "Monsoon waterlogging & slow traffic",
    "Vehicle mechanical breakdown & repair",
    "State border toll & RTO inspection check",
    "Driver regulatory rest requirement",
    "Consignee unavailable at delivery address"
]

def haversine_distance(lat1, lon1, lat2, lon2):
    """Calculates approximate driving route distance in kilometers."""
    R = 6371.0  # Earth radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    direct_dist = R * c
    # Road detour factor ~ 1.25x direct geodesic distance
    return max(round(direct_dist * 1.25, 1), 25.0)

def generate_calendar_dim(start_year=2023, end_year=2026):
    """Generates continuous calendar dimension DataFrame."""
    dates = pd.date_range(start=f"{start_year}-01-01", end=f"{end_year}-12-31", freq='D')
    df = pd.DataFrame({"DateKey": dates})
    df["Year"] = df["DateKey"].dt.year
    df["Month Number"] = df["DateKey"].dt.month
    df["Month Name"] = df["DateKey"].dt.strftime("%B")
    df["Month Short"] = df["DateKey"].dt.strftime("%b")
    df["Month Year"] = df["DateKey"].dt.strftime("%b %Y")
    df["Quarter"] = "Q" + df["DateKey"].dt.quarter.astype(str)
    df["Day of Week"] = df["DateKey"].dt.strftime("%A")
    df["Day Number of Week"] = df["DateKey"].dt.dayofweek + 1
    df["Is Weekend"] = df["Day Number of Week"].apply(lambda d: "Weekend" if d >= 6 else "Weekday")
    return df

def generate_dataset(num_customers=5000, num_drivers=200, num_vehicles=150, num_orders=10000, export_csv=True, insert_db=True):
    """Generates synthetic dataset and outputs to CSV & MySQL."""
    conn = None
    cursor = None
    if insert_db:
        try:
            print("[*] Checking MySQL connection...")
            conn = get_db_connection()
            cursor = conn.cursor()
            print("[+] MySQL connection established.")
        except Exception as e:
            print(f"[!] MySQL connection failed ({e}). Proceeding with CSV export mode.")
            insert_db = False

    print(f"[*] Starting Data Generation...")
    print(f"    - Customers: {num_customers}")
    print(f"    - Drivers:   {num_drivers}")
    print(f"    - Vehicles:  {num_vehicles}")
    print(f"    - Orders:    {num_orders}")

    # 1. Locations
    print("[1/8] Generating Locations...")
    location_ids = []
    location_map = {}
    loc_records = []
    loc_counter = 1
    for city_info in MAJOR_CITIES:
        for suffix, ltype in [("North Hub", "Warehouse"), ("South DC", "Distribution Center"), ("Gateway", "Hub")]:
            loc_id = f"LOC_{loc_counter:04d}"
            loc_name = f"{city_info['city']} {suffix}"
            lat_jitter = city_info['lat'] + random.uniform(-0.08, 0.08)
            lon_jitter = city_info['lon'] + random.uniform(-0.08, 0.08)
            loc_records.append({
                "Location_ID": loc_id,
                "Location_Name": loc_name,
                "City": city_info['city'],
                "State": city_info['state'],
                "Latitude": round(lat_jitter, 6),
                "Longitude": round(lon_jitter, 6),
                "Location_Type": ltype
            })
            location_ids.append(loc_id)
            location_map[loc_id] = {"lat": lat_jitter, "lon": lon_jitter, "city": city_info['city']}
            loc_counter += 1

    df_locations = pd.DataFrame(loc_records)
    if export_csv:
        df_locations.to_csv(DATA_DIR / "Locations.csv", index=False)
        print(f"    -> Saved {len(df_locations)} rows to data/Locations.csv")

    if insert_db:
        cursor.executemany("""
            INSERT INTO Locations (Location_ID, Location_Name, City, State, Latitude, Longitude, Location_Type)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE Location_Name=VALUES(Location_Name)
        """, [tuple(x.values()) for x in loc_records])
        conn.commit()

    # 2. Customers
    print("[2/8] Generating Customers...")
    customer_ids = []
    cust_records = []
    for i in range(1, num_customers + 1):
        cid = f"CUST_{i:06d}"
        cname = fake.name()
        ctype = random.choices(["Retail", "Enterprise", "E-Commerce", "Wholesale"], weights=[0.4, 0.3, 0.2, 0.1])[0]
        phone = f"+91-9{random.randint(100000000, 999999999)}"
        email = fake.email()
        city_info = random.choice(MAJOR_CITIES)
        postal = f"{random.randint(110001, 800001)}"
        reg_date = fake.date_between(start_date='-3y', end_date='-60d')
        cust_records.append({
            "Customer_ID": cid,
            "Customer_Name": cname,
            "Customer_Type": ctype,
            "Phone": phone,
            "Email": email,
            "City": city_info['city'],
            "State": city_info['state'],
            "Postal_Code": postal,
            "Registration_Date": reg_date
        })
        customer_ids.append(cid)

    df_customers = pd.DataFrame(cust_records)
    if export_csv:
        df_customers.to_csv(DATA_DIR / "Customers.csv", index=False)
        print(f"    -> Saved {len(df_customers)} rows to data/Customers.csv")

    if insert_db:
        cursor.executemany("""
            INSERT INTO Customers (Customer_ID, Customer_Name, Customer_Type, Phone, Email, City, State, Postal_Code, Registration_Date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE Customer_Name=VALUES(Customer_Name)
        """, [tuple(x.values()) for x in cust_records])
        conn.commit()

    # 3. Drivers
    print("[3/8] Generating Drivers...")
    driver_ids = []
    driver_records = []
    for i in range(1, num_drivers + 1):
        did = f"DRV_{i:04d}"
        dname = fake.name()
        lic = random.choice(["Heavy Transport", "Commercial", "Light Commercial"])
        exp = random.randint(2, 22)
        phone = f"+91-9{random.randint(100000000, 999999999)}"
        rating = round(random.uniform(3.8, 5.0), 2)
        emp_date = fake.date_between(start_date='-4y', end_date='-30d')
        dstatus = random.choices(["Active", "On Leave", "Suspended"], weights=[0.88, 0.08, 0.04])[0]
        driver_records.append({
            "Driver_ID": did,
            "Driver_Name": dname,
            "License_Type": lic,
            "Experience_Years": exp,
            "Phone": phone,
            "Rating": rating,
            "Employment_Date": emp_date,
            "Driver_Status": dstatus
        })
        driver_ids.append(did)

    df_drivers = pd.DataFrame(driver_records)
    if export_csv:
        df_drivers.to_csv(DATA_DIR / "Drivers.csv", index=False)
        print(f"    -> Saved {len(df_drivers)} rows to data/Drivers.csv")

    if insert_db:
        cursor.executemany("""
            INSERT INTO Drivers (Driver_ID, Driver_Name, License_Type, Experience_Years, Phone, Rating, Employment_Date, Driver_Status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE Driver_Name=VALUES(Driver_Name)
        """, [tuple(x.values()) for x in driver_records])
        conn.commit()

    # 4. Vehicles
    print("[4/8] Generating Vehicles...")
    vehicle_ids = []
    vehicle_specs = {}
    veh_records = []
    for i in range(1, num_vehicles + 1):
        vid = f"VEH_{i:04d}"
        vcfg = random.choice(VEHICLE_CONFIGS)
        vnum = f"IN-{random.randint(10, 99)}-{chr(random.randint(65, 90))}{chr(random.randint(65, 90))}-{random.randint(1000, 9999)}"
        assigned_driver = random.choice(driver_ids) if random.random() > 0.1 else None
        vstatus = random.choices(["Active", "In Maintenance", "Retired"], weights=[0.85, 0.10, 0.05])[0]
        vreg = fake.date_between(start_date='-5y', end_date='-90d')
        veh_records.append({
            "Vehicle_ID": vid,
            "Vehicle_Number": vnum,
            "Vehicle_Type": vcfg['type'],
            "Capacity_KG": vcfg['capacity'],
            "Fuel_Type": vcfg['fuel'],
            "Fuel_Efficiency": vcfg['efficiency'],
            "Driver_ID": assigned_driver,
            "Vehicle_Status": vstatus,
            "Registration_Date": vreg
        })
        vehicle_ids.append(vid)
        vehicle_specs[vid] = vcfg

    df_vehicles = pd.DataFrame(veh_records)
    if export_csv:
        df_vehicles.to_csv(DATA_DIR / "Vehicles.csv", index=False)
        print(f"    -> Saved {len(df_vehicles)} rows to data/Vehicles.csv")

    if insert_db:
        cursor.executemany("""
            INSERT INTO Vehicles (Vehicle_ID, Vehicle_Number, Vehicle_Type, Capacity_KG, Fuel_Type, Fuel_Efficiency, Driver_ID, Vehicle_Status, Registration_Date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE Vehicle_Number=VALUES(Vehicle_Number)
        """, [tuple(x.values()) for x in veh_records])
        conn.commit()

    # 5. Orders, Shipments, Events, Payments
    print("[5/8] Generating Orders, Shipments, Delivery Events & Payments...")
    order_records = []
    shipment_records = []
    payment_records = []
    event_records = []
    telemetry_records = []

    start_date = datetime.now() - timedelta(days=365)

    for i in range(1, num_orders + 1):
        order_id = f"ORD_{i:07d}"
        cust_id = random.choice(customer_ids)
        pickup_loc = random.choice(location_ids)
        delivery_loc = random.choice(location_ids)
        while delivery_loc == pickup_loc:
            delivery_loc = random.choice(location_ids)

        order_dt = start_date + timedelta(seconds=random.randint(0, int(360 * 86400)))
        priority = random.choices(PRIORITIES, weights=PRIORITY_WEIGHTS)[0]

        p_lat, p_lon = location_map[pickup_loc]["lat"], location_map[pickup_loc]["lon"]
        d_lat, d_lon = location_map[delivery_loc]["lat"], location_map[delivery_loc]["lon"]
        distance_km = haversine_distance(p_lat, p_lon, d_lat, d_lon)

        base_hours = distance_km / random.uniform(40.0, 52.0)
        lead_hours = 4 if priority == "Same Day" else (12 if priority == "Urgent" else (24 if priority == "Express" else 48))
        expected_delivery = order_dt + timedelta(hours=lead_hours + base_hours)

        order_value = round(random.uniform(500.0, 85000.0), 2)
        weight_kg = round(random.uniform(2.0, 5000.0), 2)

        # Allocate recent orders to simulate live operations
        if i > (num_orders - int(num_orders * 0.08)):
            order_dt = datetime.now() - timedelta(hours=random.uniform(2.0, 48.0))
            order_status = random.choices(["In Transit", "Dispatched", "Pending"], weights=[0.65, 0.25, 0.10])[0]
        else:
            order_dt = start_date + timedelta(seconds=random.randint(0, int(350 * 86400)))
            order_status = random.choices(["Delivered", "Cancelled"], weights=[0.94, 0.06])[0]

        order_records.append({
            "Order_ID": order_id,
            "Customer_ID": cust_id,
            "Order_Date": order_dt.strftime("%Y-%m-%d %H:%M:%S"),
            "Pickup_Location_ID": pickup_loc,
            "Delivery_Location_ID": delivery_loc,
            "Priority": priority,
            "Order_Value": order_value,
            "Weight_KG": weight_kg,
            "Expected_Delivery_Date": expected_delivery.strftime("%Y-%m-%d %H:%M:%S"),
            "Order_Status": order_status
        })

        # Payments
        pay_id = f"PAY_{i:07d}"
        pay_method = random.choices(["UPI", "Net Banking", "Credit Card", "Cash on Delivery", "Corporate Cheque"], weights=[0.4, 0.25, 0.2, 0.1, 0.05])[0]
        pay_status = "Refunded" if order_status == "Cancelled" else "Completed"
        payment_records.append({
            "Payment_ID": pay_id,
            "Order_ID": order_id,
            "Payment_Date": (order_dt + timedelta(minutes=random.randint(5, 30))).strftime("%Y-%m-%d %H:%M:%S"),
            "Payment_Method": pay_method,
            "Payment_Status": pay_status,
            "Amount": order_value
        })

        # Shipments
        if order_status != "Pending":
            shipment_id = f"SHP_{i:07d}"
            vehicle_id = random.choice(vehicle_ids)
            driver_id = random.choice(driver_ids)
            dispatch_time = order_dt + timedelta(hours=random.uniform(1.0, 4.0))

            v_spec = vehicle_specs[vehicle_id]
            fuel_rate = 94.0 if v_spec["fuel"] == "Diesel" else 15.0
            fuel_cost = round((distance_km / max(v_spec["efficiency"], 1.0)) * fuel_rate, 2)
            base_rate_per_km = 18.0 if weight_kg < 500 else 32.0
            shipping_cost = round(distance_km * base_rate_per_km + (weight_kg * 1.5), 2)

            if order_status == "Delivered":
                is_delayed = random.random() < 0.14
                if is_delayed:
                    delay_hours = random.uniform(1.5, 18.0)
                    actual_delivery = expected_delivery + timedelta(hours=delay_hours)
                    shipment_status = "Delivered"
                else:
                    early_hours = random.uniform(0.5, 4.0)
                    actual_delivery = expected_delivery - timedelta(hours=early_hours)
                    if actual_delivery < dispatch_time:
                        actual_delivery = dispatch_time + timedelta(hours=base_hours)
                    shipment_status = "Delivered"
            elif order_status == "Cancelled":
                actual_delivery = None
                shipment_status = "Cancelled"
            else:
                actual_delivery = None
                shipment_status = "In Transit"

            shipment_records.append({
                "Shipment_ID": shipment_id,
                "Order_ID": order_id,
                "Vehicle_ID": vehicle_id,
                "Driver_ID": driver_id,
                "Dispatch_Time": dispatch_time.strftime("%Y-%m-%d %H:%M:%S"),
                "Expected_Delivery_Time": expected_delivery.strftime("%Y-%m-%d %H:%M:%S"),
                "Actual_Delivery_Time": actual_delivery.strftime("%Y-%m-%d %H:%M:%S") if actual_delivery else None,
                "Distance_KM": distance_km,
                "Shipment_Status": shipment_status,
                "Shipping_Cost": shipping_cost,
                "Fuel_Cost": fuel_cost
            })

            # Events
            event_records.append({
                "Shipment_ID": shipment_id,
                "Event_Time": order_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "Event_Type": "Order Created",
                "Location_ID": pickup_loc,
                "Remarks": "Order placed into management system"
            })
            event_records.append({
                "Shipment_ID": shipment_id,
                "Event_Time": dispatch_time.strftime("%Y-%m-%d %H:%M:%S"),
                "Event_Type": "Picked Up",
                "Location_ID": pickup_loc,
                "Remarks": "Freight loaded onto vehicle"
            })

            if shipment_status == "In Transit":
                event_records.append({
                    "Shipment_ID": shipment_id,
                    "Event_Time": (dispatch_time + timedelta(hours=base_hours * 0.4)).strftime("%Y-%m-%d %H:%M:%S"),
                    "Event_Type": "In Transit",
                    "Location_ID": None,
                    "Remarks": "Moving on National Highway corridor"
                })
            elif shipment_status == "Delivered":
                event_records.append({
                    "Shipment_ID": shipment_id,
                    "Event_Time": (dispatch_time + timedelta(hours=base_hours * 0.5)).strftime("%Y-%m-%d %H:%M:%S"),
                    "Event_Type": "In Transit",
                    "Location_ID": None,
                    "Remarks": "Transit checkpoint cleared"
                })
                if is_delayed:
                    event_records.append({
                        "Shipment_ID": shipment_id,
                        "Event_Time": expected_delivery.strftime("%Y-%m-%d %H:%M:%S"),
                        "Event_Type": "Delayed",
                        "Location_ID": None,
                        "Remarks": random.choice(DELAY_REASONS)
                    })
                event_records.append({
                    "Shipment_ID": shipment_id,
                    "Event_Time": (actual_delivery - timedelta(hours=1)).strftime("%Y-%m-%d %H:%M:%S"),
                    "Event_Type": "Out for Delivery",
                    "Location_ID": delivery_loc,
                    "Remarks": "Vehicle arrived at destination hub"
                })
                event_records.append({
                    "Shipment_ID": shipment_id,
                    "Event_Time": actual_delivery.strftime("%Y-%m-%d %H:%M:%S"),
                    "Event_Type": "Delivered",
                    "Location_ID": delivery_loc,
                    "Remarks": "Signed electronic proof of delivery (ePOD)"
                })
            elif shipment_status == "Cancelled":
                event_records.append({
                    "Shipment_ID": shipment_id,
                    "Event_Time": (dispatch_time + timedelta(hours=1)).strftime("%Y-%m-%d %H:%M:%S"),
                    "Event_Type": "Cancelled",
                    "Location_ID": pickup_loc,
                    "Remarks": "Order cancelled by customer before out-for-delivery"
                })

            # Telemetry breadcrumbs along corridor
            if shipment_status in ("In Transit", "Dispatched") and len(telemetry_records) < 50000:
                num_pings = random.randint(4, 8)
                for step in range(num_pings):
                    p_progress = (step + 1) / (num_pings + 1)
                    cur_lat = p_lat + (d_lat - p_lat) * p_progress + random.uniform(-0.015, 0.015)
                    cur_lon = p_lon + (d_lon - p_lon) * p_progress + random.uniform(-0.015, 0.015)
                    ping_time = datetime.now() - timedelta(minutes=(num_pings - step) * random.randint(8, 20))
                    telemetry_records.append({
                        "Vehicle_ID": vehicle_id,
                        "Timestamp": ping_time.strftime("%Y-%m-%d %H:%M:%S"),
                        "Latitude": round(cur_lat, 6),
                        "Longitude": round(cur_lon, 6),
                        "Speed_KMH": round(random.uniform(38.0, 72.0), 2),
                        "Fuel_Level": round(max(20.0, 95.0 - (p_progress * 40.0)), 2),
                        "Engine_Status": "Running"
                    })

    # Save to CSV
    if export_csv:
        print("[6/8] Saving CSV tables into data/ folder...")
        df_orders = pd.DataFrame(order_records)
        df_orders.to_csv(DATA_DIR / "Orders.csv", index=False)
        print(f"    -> Saved {len(df_orders)} rows to data/Orders.csv")

        df_payments = pd.DataFrame(payment_records)
        df_payments.to_csv(DATA_DIR / "Payments.csv", index=False)
        print(f"    -> Saved {len(df_payments)} rows to data/Payments.csv")

        df_shipments = pd.DataFrame(shipment_records)
        df_shipments.to_csv(DATA_DIR / "Shipments.csv", index=False)
        print(f"    -> Saved {len(df_shipments)} rows to data/Shipments.csv")

        df_events = pd.DataFrame(event_records)
        df_events.to_csv(DATA_DIR / "Delivery_Events.csv", index=False)
        print(f"    -> Saved {len(df_events)} rows to data/Delivery_Events.csv")

        df_telemetry = pd.DataFrame(telemetry_records)
        df_telemetry.to_csv(DATA_DIR / "Vehicle_Locations.csv", index=False)
        print(f"    -> Saved {len(df_telemetry)} rows to data/Vehicle_Locations.csv")

        # 7. Calendar Dimension
        print("[7/8] Generating DimDate Calendar...")
        df_date = generate_calendar_dim()
        df_date.to_csv(DATA_DIR / "DimDate.csv", index=False)
        print(f"    -> Saved {len(df_date)} calendar dates to data/DimDate.csv")

    # Insert into MySQL if active
    if insert_db:
        print("[8/8] Ingesting batch rows into MySQL...")
        cursor.executemany("""
            INSERT INTO Orders (Order_ID, Customer_ID, Order_Date, Pickup_Location_ID, Delivery_Location_ID, Priority, Order_Value, Weight_KG, Expected_Delivery_Date, Order_Status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, [tuple(x.values()) for x in order_records])
        cursor.executemany("""
            INSERT INTO Payments (Payment_ID, Order_ID, Payment_Date, Payment_Method, Payment_Status, Amount)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, [tuple(x.values()) for x in payment_records])
        if shipment_records:
            cursor.executemany("""
                INSERT INTO Shipments (Shipment_ID, Order_ID, Vehicle_ID, Driver_ID, Dispatch_Time, Expected_Delivery_Time, Actual_Delivery_Time, Distance_KM, Shipment_Status, Shipping_Cost, Fuel_Cost)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, [tuple(x.values()) for x in shipment_records])
        if event_records:
            cursor.executemany("""
                INSERT INTO Delivery_Events (Shipment_ID, Event_Time, Event_Type, Location_ID, Remarks)
                VALUES (%s, %s, %s, %s, %s)
            """, [tuple(x.values()) for x in event_records])
        if telemetry_records:
            cursor.executemany("""
                INSERT INTO Vehicle_Locations (Vehicle_ID, Timestamp, Latitude, Longitude, Speed_KMH, Fuel_Level, Engine_Status)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, [tuple(x.values()) for x in telemetry_records])
        conn.commit()
        cursor.close()
        conn.close()

    print("\n[+] Data generation completed successfully! All tables ready in data/ folder.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Synthetic Logistics Data Generator")
    parser.add_argument("--customers", type=int, default=1000, help="Number of customers")
    parser.add_argument("--drivers", type=int, default=100, help="Number of drivers")
    parser.add_argument("--vehicles", type=int, default=80, help="Number of vehicles")
    parser.add_argument("--orders", type=int, default=5000, help="Number of orders (default: 5000)")
    parser.add_argument("--full", action="store_true", help="Generate full scale production dataset (50,000 orders)")
    parser.add_argument("--no-db", action="store_true", help="Skip database insert, export to CSV only")
    args = parser.parse_args()

    insert_to_db = not args.no_db
    if args.full:
        generate_dataset(num_customers=5000, num_drivers=200, num_vehicles=150, num_orders=50000, insert_db=insert_to_db)
    else:
        generate_dataset(num_customers=args.customers, num_drivers=args.drivers, num_vehicles=args.vehicles, num_orders=args.orders, insert_db=insert_to_db)
