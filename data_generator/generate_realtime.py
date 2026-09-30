"""
Real-Time Telemetry & Delivery Event Simulator.
Periodically generates live GPS vehicle pings (speed, location, fuel, engine status)
and real-time delivery status updates for in-transit shipments into MySQL.
"""

import time
import random
from datetime import datetime, timedelta
import pymysql

from config import (
    get_db_connection,
    SIMULATION_INTERVAL_SECONDS,
    ACTIVE_VEHICLE_PINGS_PER_CYCLE
)

def run_simulation(interval_seconds=SIMULATION_INTERVAL_SECONDS, pings_per_cycle=ACTIVE_VEHICLE_PINGS_PER_CYCLE):
    """
    Continuous simulation loop inserting GPS telemetry and delivery lifecycle events.
    """
    print(f"=================================================================")
    print(f"🚀 Logistics Real-Time Telemetry & Delivery Event Simulator")
    print(f"   Update Interval:  {interval_seconds} seconds")
    print(f"   Vehicles / Cycle: {pings_per_cycle}")
    print(f"   Press Ctrl+C to terminate simulation gracefully.")
    print(f"=================================================================\n")

    iteration = 1

    while True:
        try:
            conn = get_db_connection()
            cursor = conn.cursor()

            # 1. Fetch active shipments currently in transit
            cursor.execute("""
                SELECT 
                    s.Shipment_ID,
                    s.Vehicle_ID,
                    s.Expected_Delivery_Time,
                    loc_pickup.Latitude AS Origin_Lat,
                    loc_pickup.Longitude AS Origin_Lon,
                    loc_drop.Latitude AS Dest_Lat,
                    loc_drop.Longitude AS Dest_Lon
                FROM Shipments s
                INNER JOIN Orders o ON s.Order_ID = o.Order_ID
                INNER JOIN Locations loc_pickup ON o.Pickup_Location_ID = loc_pickup.Location_ID
                INNER JOIN Locations loc_drop ON o.Delivery_Location_ID = loc_drop.Location_ID
                WHERE s.Shipment_Status = 'In Transit'
                LIMIT %s
            """, (pings_per_cycle,))
            active_shipments = cursor.fetchall()

            current_time = datetime.now()
            telemetry_inserts = []
            event_inserts = []

            for row in active_shipments:
                v_id = row['Vehicle_ID']
                s_id = row['Shipment_ID']
                orig_lat, orig_lon = float(row['Origin_Lat']), float(row['Origin_Lon'])
                dest_lat, dest_lon = float(row['Dest_Lat']), float(row['Dest_Lon'])

                # Interpolate position along corridor with noise
                progress = random.uniform(0.1, 0.9)
                cur_lat = round(orig_lat + (dest_lat - orig_lat) * progress + random.uniform(-0.01, 0.01), 6)
                cur_lon = round(orig_lon + (dest_lon - orig_lon) * progress + random.uniform(-0.01, 0.01), 6)
                speed = round(random.uniform(42.0, 78.0), 1)
                fuel_level = round(random.uniform(25.0, 95.0), 1)

                telemetry_inserts.append((v_id, current_time, cur_lat, cur_lon, speed, fuel_level, "Running"))

                # 10% chance of milestone event (Transit ping, Delay, or Final Delivery)
                if random.random() < 0.10:
                    roll = random.random()
                    if roll < 0.35:
                        # Delivery completed
                        cursor.execute("""
                            UPDATE Shipments 
                            SET Shipment_Status = 'Delivered', Actual_Delivery_Time = %s 
                            WHERE Shipment_ID = %s
                        """, (current_time, s_id))
                        cursor.execute("""
                            UPDATE Orders 
                            SET Order_Status = 'Delivered' 
                            WHERE Order_ID = (SELECT Order_ID FROM Shipments WHERE Shipment_ID = %s)
                        """, (s_id,))
                        event_inserts.append((s_id, current_time, "Delivered", None, "Consignee signature confirmed via mobile app"))
                        print(f"   [DELIVERY] Shipment {s_id} marked as DELIVERED at {current_time.strftime('%H:%M:%S')}")
                    elif roll < 0.65:
                        # Unplanned delay alert
                        event_inserts.append((s_id, current_time, "Delayed", None, "Heavy toll gate queue & monsoon road diversion"))
                        print(f"   [ALERT] Delay logged for Shipment {s_id}")
                    else:
                        event_inserts.append((s_id, current_time, "In Transit", None, f"Passed toll checkpoint at {cur_lat}, {cur_lon}"))

            # Bulk insert new telemetry
            if telemetry_inserts:
                cursor.executemany("""
                    INSERT INTO Vehicle_Locations (Vehicle_ID, Timestamp, Latitude, Longitude, Speed_KMH, Fuel_Level, Engine_Status)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, telemetry_inserts)

            if event_inserts:
                cursor.executemany("""
                    INSERT INTO Delivery_Events (Shipment_ID, Event_Time, Event_Type, Location_ID, Remarks)
                    VALUES (%s, %s, %s, %s, %s)
                """, event_inserts)

            conn.commit()
            cursor.close()
            conn.close()

            print(f"[Cycle {iteration:03d} | {current_time.strftime('%H:%M:%S')}] Broadcasted {len(telemetry_inserts)} GPS pings and {len(event_inserts)} events.")
            iteration += 1

        except pymysql.MySQLError as err:
            print(f"[!] Database Error: {err}")
        except Exception as ex:
            print(f"[!] Unexpected Simulation Error: {ex}")

        time.sleep(interval_seconds)

if __name__ == "__main__":
    try:
        run_simulation()
    except KeyboardInterrupt:
        print("\n[+] Telemetry simulation terminated by user.")
