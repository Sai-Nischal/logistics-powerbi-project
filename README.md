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
- [ ] **Phase 2**: Relational Database Schema & Entity Relationships
- [ ] **Phase 3**: SQL Database Setup & DDL Scripts
- [ ] **Phase 4**: Synthetic Data Generation Engine (50k+ records)
- [ ] **Phase 5**: Analytical SQL Views & Operational Queries
- [ ] **Phase 6**: Power Query Transformation Pipeline
- [ ] **Phase 7**: Power BI Star Schema Data Modeling
- [ ] **Phase 8**: DAX Metrics & Measure Engineering
- [ ] **Phase 9**: 4-Page Control Tower Dashboard Development
- [ ] **Phase 10**: Python Real-Time Telemetry Simulation Script
- [ ] **Phase 11**: Data Validation & Quality Audit
- [ ] **Phase 12**: Portfolio Documentation & Interview Q&A Preparation
