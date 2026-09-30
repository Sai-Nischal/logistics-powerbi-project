# Real-Time Logistics & Delivery Performance Analytics using SQL, Power Query and Power BI

## 📌 Project Overview
An enterprise-grade logistics analytics control tower designed to monitor supply chain performance, tracking order fulfillments, vehicle GPS telemetry, delivery delay root causes, transportation costs, driver metrics, and operational efficiency across major logistics corridors in India.

This project combines:
- **Relational Database Engineering**: Normalized SQL schema, indexes, constraints, and analytical views.
- **Python Synthetic Data Engine & Real-Time Simulator**: Realistic data generator producing historical shipments and live streaming telemetry pings.
- **Power Query ETL Pipeline**: Clean data transformation, data type validation, and dimensional bucketing.
- **Star Schema Data Modeling**: Enterprise data model with facts and dimensions optimized for high-speed DAX querying.
- **Advanced DAX Metrics**: 25+ business measures covering performance, fleet utilization, financial KPIs, and time intelligence.
- **Interactive 4-Page Power BI Control Tower**: Executive and operational dashboard with cross-filtering, tooltips, dynamic titles, and drill-through navigation.

---

## 🏗️ Architecture & Technology Stack

```text
Python Data Engine (Faker + Async Generator)
        ↓
PostgreSQL / SQL Server Operational Database
        ↓
Power Query ETL Engine
        ↓
Power BI Star Schema Data Model
        ↓
DAX Analytical Engine
        ↓
4-Page Power BI Executive Control Tower
```

- **Database**: PostgreSQL / SQL Server (ANSI SQL compliant scripts provided)
- **Data Engine**: Python 3.9+ (`psycopg2` / `pyodbc`, `Faker`, `pandas`)
- **ETL**: Power Query (M Language)
- **Analytics & BI**: Power BI Desktop, DAX

---

## 📁 Repository Structure

```text
logistics-powerbi-project/
│
├── README.md
│
├── database/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_constraints.sql
│   ├── 04_indexes.sql
│   ├── 05_seed_data.sql
│   ├── 06_views.sql
│   └── 07_analysis_queries.sql
│
├── data_generator/
│   ├── requirements.txt
│   ├── config.py
│   ├── generate_data.py
│   ├── generate_realtime.py
│   └── README.md
│
├── power_query/
│   ├── transformations.md
│   └── m_code_examples.txt
│
├── power_bi/
│   ├── data_model.md
│   ├── dax_measures.md
│   └── dashboard_design.md
│
└── documentation/
    ├── architecture.md
    ├── data_dictionary.md
    ├── business_requirements.md
    └── interview_questions.md
```

---

## 🚀 Phase-by-Phase Implementation Roadmap
- [x] **Phase 1**: System Architecture & Business Requirements
- [x] **Phase 2**: Relational Database Schema & Entity Relationships
- [x] **Phase 3**: SQL Database Setup & DDL Scripts (`database/01` to `07`)
- [x] **Phase 4**: Synthetic Data Generation Engine (`data_generator/generate_data.py`)
- [x] **Phase 5**: Analytical SQL Views & Operational Queries (`06_views.sql`, `07_analysis_queries.sql`)
- [x] **Phase 6**: Power Query Transformation Pipeline (`power_query/`)
- [x] **Phase 7**: Power BI Star Schema Data Modeling (`power_bi/data_model.md`)
- [x] **Phase 8**: DAX Metrics & Measure Engineering (`power_bi/dax_measures.md`)
- [x] **Phase 9**: 4-Page Control Tower Dashboard Development (`power_bi/dashboard_design.md`)
- [x] **Phase 10**: Python Real-Time Telemetry Simulation Script (`data_generator/generate_realtime.py`)
- [x] **Phase 11**: Data Validation & Quality Audit
- [x] **Phase 12**: Portfolio Documentation & Interview Q&A Preparation (`documentation/interview_questions.md`)

---

## 🛠️ Step-by-Step Setup Guide

### 1. Database Setup (MySQL)
Execute the SQL scripts in numerical order using MySQL Workbench, MySQL Shell, or command line:
1. `database/01_create_database.sql`: Creates schema `logistics_db` and collation.
2. `database/02_create_tables.sql`: Builds the 9 relational tables.
3. `database/03_constraints.sql`: Applies foreign keys and validation constraints.
4. `database/04_indexes.sql`: Builds high-speed B-Tree query indexes.
5. `database/05_seed_data.sql`: Populates master hubs and initial fleet baseline.
6. `database/06_views.sql`: Deploys analytical views for reporting.
7. `database/07_analysis_queries.sql`: Runs operational analysis queries.

### 2. Configure Python Environment
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Update `.env` with your local MySQL password:
   ```env
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=YourPassword
   DB_NAME=logistics_db
   ```
3. Install Python dependencies:
   ```bash
   python -m pip install -r data_generator/requirements.txt
   ```

### 3. Generate Synthetic Logistics Data
Run the generation script to populate orders, shipments, delivery events, and payments:
```bash
python data_generator/generate_data.py --orders 5000
```
*(To generate the full 50,000-order portfolio scale, run with `--full`)*

### 4. Run the Real-Time Telemetry Simulator
Start the simulator in a separate terminal:
```bash
python data_generator/generate_realtime.py
```

### 5. Connect Power BI Desktop
1. Open **Power BI Desktop**.
2. Click **Get Data** -> **MySQL Database**.
3. Server: `localhost:3306`, Database: `logistics_db`.
4. Import tables and follow the M transformations in `power_query/transformations.md`.
5. Connect relationships according to `power_bi/data_model.md`.
6. Add the DAX measures from `power_bi/dax_measures.md`.
7. Build the 4 pages following `power_bi/dashboard_design.md`.
