# 🛒DMart Sales

## Problem Statement
DMart, a fresh produce retailer, switched to **sustainable packaging in June 2020**.  
This case study analyzes the impact of this change on sales across different dimensions such as:
- Regions  
- Platforms  
- Customer Segments  
- Demographics  

The goal is to identify trends and suggest strategies to minimize disruptions in the future.

---

##  Dataset Description
- **File:** `data.sql`  
- **Schema:** `dmart.qt`  
- **Table:** `weekly_sales`  

### Columns:
- `week_date` → Week start date (DD/MM/YY)  
- `region` → Region (ASIA, USA, EUROPE, etc.)  
- `platform` → Sales platform (Offline / Online)  
- `segment` → Customer segment (C1, F1, etc.)  
- `customer_type` → Customer type (New / Guest)  
- `transactions` → Number of transactions  
- `sales` → Total sales (₹)  

---

##  DMart.md Context
The file [DMart.md](DMart.md) contains the original case study context, including introduction, problem statement, and dataset details.  
It serves as the foundation for this analysis.

---

##  Questions
See [DMart_questions.md](DMart_questions.md) for data exploration and pre/post-change analysis questions.

---

##  Solutions
SQL queries addressing the questions are available in  
[dmartdata case study solution.sql](dmartdata%20case%20study%20solution.sql)

---

##  Power BI Dashboard
View dashboard file: [dmart.pbix](dmart.pbix)

---

##  Objective
This case study helps practice:
- Data cleansing  
- Aggregation  
- Time-based analysis  

It focuses on evaluating the business impact of sustainable packaging changes on sales metrics.

---

##  Tools Used
- SQL  
- Power BI  
- Data Analysis  
