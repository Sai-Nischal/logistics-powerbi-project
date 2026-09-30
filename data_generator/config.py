"""
Configuration Module for Logistics Data Generator & Real-Time Simulator.
Loads environment variables securely and provides standardized database connection parameters.
"""

import os
from pathlib import Path
from dotenv import load_dotenv
import pymysql

# Load .env file from project root
BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

# Database Connection Settings
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_NAME = os.getenv("DB_NAME", "logistics_db")

# Simulation Settings
SIMULATION_INTERVAL_SECONDS = int(os.getenv("SIMULATION_INTERVAL_SECONDS", 30))
ACTIVE_VEHICLE_PINGS_PER_CYCLE = int(os.getenv("ACTIVE_VEHICLE_PINGS_PER_CYCLE", 15))
BATCH_INSERT_SIZE = int(os.getenv("BATCH_INSERT_SIZE", 1000))

def get_db_connection(include_database=True):
    """
    Establishes and returns a PyMySQL connection.
    If include_database is False, connects to the server without selecting a specific database.
    """
    kwargs = {
        "host": DB_HOST,
        "port": DB_PORT,
        "user": DB_USER,
        "password": DB_PASSWORD,
        "autocommit": False,
        "charset": "utf8mb4",
        "cursorclass": pymysql.cursors.DictCursor
    }
    if include_database:
        kwargs["database"] = DB_NAME
    return pymysql.connect(**kwargs)
