# 🛒 Ecommerce Consumer Insights

##  Problem Statement  
This case study analyzes **consumer behavior** on an ecommerce platform — focusing on **demographics**, **purchase patterns**, and **satisfaction metrics** to identify trends, optimize marketing strategies, and improve **customer retention**.

---

##  Dataset Description  
**File:** `Ecommerce_Consumer_Behavior_Analysis_Data.csv`  
**Database:** `consumer_behavior`  
**Table:** `Consumer`  

###  Instructions for Use  
1. The dataset is provided as a CSV file: **`Ecommerce_Consumer_Behavior_Analysis_Data.csv`**  
2. Import this CSV file into **Microsoft SQL Server** to create the **Consumer** table in the **consumer_behavior** database  
3. Ensure that a **derived column `amount`** (float version of `Purchase_Amount` without the `$` symbol) is created during import or added via SQL

---

##  Table Breakdown  

### **Table:** `Consumer`  
Stores information on customer demographics, purchase behavior, and satisfaction metrics.  
Includes a derived column `amount` (float version of `Purchase_Amount`).

| Column Name | Data Type | Description |
|--------------|------------|-------------|
| `Customer_ID` | VARCHAR | Unique identifier for each customer |
| `Age` | INT | Customer's age |
| `Gender` | VARCHAR | Customer's gender |
| `Income_Level` | VARCHAR | Income bracket (Low, Middle, High) |
| `Marital_Status` | VARCHAR | Marital status (Single, Married, Widowed) |
| `Education_Level` | VARCHAR | Education level (High School, Bachelor's, Master's) |
| `Occupation` | VARCHAR | Occupation level (Low, Middle, High) |
| `Location` | VARCHAR | Customer's location |
| `Purchase_Category` | VARCHAR | Category of purchased product |
| `Purchase_Amount` | VARCHAR | Purchase amount with `$` symbol |
| `Frequency_of_Purchase` | INT | Number of purchases made |
| `Purchase_Channel` | VARCHAR | Channel used (Online, In-Store, Mixed) |
| `Brand_Loyalty` | INT | Loyalty score (1–5) |
| `Product_Rating` | INT | Rating given to product (1–5) |
| `Time_Spent_on_Product_Research_hours` | FLOAT | Hours spent researching before purchase |
| `Social_Media_Influence` | VARCHAR | Influence level (None, Low, Medium, High) |
| `Discount_Sensitivity` | VARCHAR | Sensitivity to discounts (Not Sensitive, Somewhat Sensitive, Sensitive) |
| `Return_Rate` | INT | Number of returns made by the customer |
| `Customer_Satisfaction` | INT | Satisfaction score (1–10) |
| `Engagement_with_Ads` | VARCHAR | Ad engagement level (None, Low, Medium, High) |
| `Device_Used_for_Shopping` | VARCHAR | Device used (Smartphone, Tablet, Desktop) |
| `Payment_Method` | VARCHAR | Payment method used |
| `Time_of_Purchase` | DATE | Date of purchase |
| `Discount_Used` | BOOLEAN | Whether a discount was used |
| `Customer_Loyalty_Program_Member` | BOOLEAN | Loyalty program membership status |
| `Purchase_Intent` | VARCHAR | Intent type (Need-based, Wants-based, Impulsive, Planned) |
| `Shipping_Preference` | VARCHAR | Shipping preference (Standard, Express, No Preference) |
| `Time_to_Decision` | INT | Days taken to make a purchase decision |
| `amount` | FLOAT | Derived column for `Purchase_Amount` without `$` symbol |

---

##  Questions  
Refer to **[`questions.md`](Consumer_Behavior_SQL_Practice.md)** for a detailed list of SQL practice problems categorized into six levels, covering:  
- Basic Queries  
- Aggregations  
- Subqueries  
- Date Functions  
- Window Functions  
- Business-Oriented Analysis  

---

## 🧩 Solutions  
Refer to **[`solutions.sql`](solutions.sql)** for complete SQL solutions to all the questions provided in `questions.md`.

---

## Objective  
This case study is designed to:  
- Strength **SQL skills** (data retrieval, aggregation, subqueries, and window functions)  
- Enhance understanding of **ecommerce consumer behavior**  
- Enable exploration of **data-driven insights** for marketing optimization and customer engagement  

---

## 📁 Project Structure  

Ecommerce_Consumer_Insights/

│

├── Ecommerce_Consumer_Behavior_Analysis_Data.csv # Dataset

├── questions.md # SQL Practice Questions

├── solutions.sql # SQL Answers

└── README.md # Project Documentation
