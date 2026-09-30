# Data Generator & Real-Time Telemetry Simulation Engine

This directory contains Python scripts for generating realistic synthetic data and simulating streaming GPS telemetry into MySQL.

## 📦 Requirements & Installation

Dependencies have been installed into the environment:
- `pymysql`: Pure-Python MySQL client
- `cryptography`: Modern authentication protocols
- `faker`: Realistic synthetic Indian names and addresses
- `pandas`: Data manipulation and validation
- `python-dotenv`: Secure configuration loading

To reinstall or verify dependencies:
```bash
python -m pip install -r requirements.txt
```

---

## ⚙️ Configuration (`.env`)

Create or update `.env` in the project root:
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=YourMySQLPasswordHere
DB_NAME=logistics_db

SIMULATION_INTERVAL_SECONDS=30
ACTIVE_VEHICLE_PINGS_PER_CYCLE=15
```

---

## 🚀 Scripts

### 1. `generate_data.py` (Historical Batch Generation)
Populates 5,000 customers, 200 drivers, 150 vehicles, 48 locations, orders, shipments, delivery events, and payments.

**Usage:**
```bash
# Fast test run (1,000 orders):
python generate_data.py --orders 1000

# Full portfolio production run (50,000 orders):
python generate_data.py --full
```

### 2. `generate_realtime.py` (Simulated Live Streaming)
Simulates continuous IoT vehicle telemetry:
- Streams GPS coordinates (latitude, longitude)
- Tracks speed and fuel depletion
- Broadcasts milestone events ("In Transit", "Delayed", "Delivered")
- Configurable cycle interval (default: 30 seconds)

**Usage:**
```bash
python generate_realtime.py
```
*(Press `Ctrl+C` to stop the simulation)*
