# Pharmaceutical Sales Performance & Operations Report #
## VicPharm Sales Analysis (Aug 2025 – Dec 2025) ##

**Business Objectives**

The objective of this analysis was to transform raw, semi-structured sales data into actionable business intelligence to support inventory optimization, cash-flow management and customer risk assessment.

**Business Questions Addressed**

•	What is the total revenue and average order value over the period?

•	Which customers contribute the most to revenue?

•	Are there significant payment delays or outstanding balances that pose credit risk?

•	Which products generate the highest sales volume and demand?

**Stakeholder Focus Areas**

•	Financial Health: Evaluating revenue performance and order value trends.

•	Customer Behavior: Identifying high-value and repeat customers.

•	Operational Risk: Monitoring payment delays and outstanding receivables.

•	Inventory Demand: Highlighting frequently sold and bulk-purchased products.

**Data Sourcing & Credibility**

i.	Dataset Description

The dataset consisted of transactional sales records containing:

•	Order information: Order ID, order date and due date

•	Customer details: Customer identifiers

•	Financial metrics: Total order amount, amount paid and outstanding balance

•	Payment attributes: Payment mode and payment status

•	Product data: Product descriptions with embedded quantity information

ii.	Data Sources & Integrity

The data was sourced from internal Excel files provided by the business stakeholder (CEO, Vicpharm) for the purpose of this analysis:

•	salesList (1).xlsx: Core financial transaction data, including revenue, payments and order status
Data quality checks confirmed the dataset was consistent and reliable, comprising 213 unique orders across 106 unique customers, with no critical missing or duplicate records affecting the analysis.

iii.	Data Privacy & Ethics

•	No personally identifiable information (PII) included

•	Fully compliant with ethical and privacy standards

**Data Cleaning & Transformation**
   
To make the dataset analysis-ready, the semi-structured product information required parsing, normalization and restructuring. SQL transformations were performed in BigQuery to unnest product strings, standardize date fields and derive analytical metrics used in the final dashboards and reports.

i.	Aggregating Product Demand

Product data was stored as comma-separated text strings with embedded quantity values. SQL query was used to flatten the product list and calculate total quantity sold per product, enabling product demand analysis.

Purpose:

•	Identify most demanded products

•	Support inventory planning and product prioritization

ii.	Extracting Itemized Order Details

To support customer-level and order-level product analysis, an itemized dataset was created by unnesting products at the order level. This resulted in one row per product per order.

Purpose:

•	Enable customer-product analysis

•	Support frequency and volume-based product insights

iii.	Additional Data Preparation Steps

•	Date Standardization: Converted Date & Time and Due Date fields into standardized ISO date formats for time-series analysis.

•	Financial Calculations: Derived Remaining Balance by subtracting Amount Paid from Total Amount.

•	Customer Segmentation: Classified customers as Repeat (>1 order) or One-Time (1 order) using distinct order counts.

•	Data Cleaning: Handled null and missing payment values to ensure unpaid transactions were accurately reflected as outstanding debt.

**Final Analytical Datasets**

•	CleanedProductSales.csv
Itemized order-level dataset containing product quantities per transaction.

•	CleanedTotalSales.csv
Aggregated dataset summarizing product demand and overall sales performance.

iv.	Outcome

These transformations converted raw, semi-structured transactional data into clean, normalized analytical tables, forming the foundation for all subsequent Tableau visualizations, KPIs and business intelligence insights.

**Key Findings**

i. Financial Overview (KPIs)

•	Total Revenue: ₦212,368,025

•	Average Order Value (AOV): ₦997,033

•	Collection Rate: 99.1% of transactions are marked as "Paid."

ii. Customer Insights 

•	Concentration: The Top 10 customers contribute 45.6% of total revenue.

•	Lead Customer: Green Access Pharmacy is the primary driver with ₦24.8M in purchases.

•	Retention: 46.2% of your database are Repeat Customers.

iii. Product Performance

•	Volume Leader: Vama ORS is the most frequently sold product (126 appearances) and holds the record for the largest single-item order (7,000 units).

•	Core Portfolio: Vama ORS and Codolin Expectorant represent the highest "Quantity per Order" metrics, indicating high-bulk demand.

iv. Credit & Risk Assessment

•	Outstanding Debt: ₦33,000 remains unpaid, specifically attributed to "Damaged Stocks" entries.

•	Payment Terms: Most orders are granted a 60-day credit window (e.g., Nov orders due in Jan). While 99% are paid, the extended due dates delay actual cash liquidity.

•	Payment Delay Days: The highest number of customers (70) settled their payments approximately 40 days after the due date. A further 51 customers exhibited extended payment delays of up to 140 days, representing the longest delay observed in the dataset, while only 8 customers paid exactly on the due date.

**Data Visualizations** 

This VicPharm Sales and Performance Dashboard 2 emphasizes product demand, payment behavior and operational exposure.
Charts Included

i.	Most Frequently Sold Products (Treemap)

a.	Displays products by order frequency.

b.	Highlights high-demand items based on how often they appear in customer orders.

ii.	High-Quantity Items Within Orders (Horizontal Bar Chart)

a.	Shows products ranked by total quantity sold.

b.	Identifies bulk-purchased and fast-moving inventory items.

iii.	Payment Timeliness (Bar Chart)

a.	Compares the number of On-Time versus Late payments.

b.	Reveals a strong skew toward late payments, indicating credit risk.

iv.	Distribution of Customer Payment Delays (Histogram / Bar Chart)

a.	Visualizes the number of customers by days delayed after the due date.

b.	Highlights common delay ranges and extreme late-payment behavior.

v.	Daily Sales Trend (Line Chart)

a.	Tracks revenue at the daily level.

b.	Exposes transaction spikes and irregular sales patterns.

vi.	Paid vs Unpaid Transactions (Pie Chart)

a.	Displays the proportion of paid versus unpaid invoices.

b.	Confirms that while most transactions are paid, a small unpaid portion represents outstanding debt.

![](images/Sheet_9.png)

**Insight Summary**

The analysis reveals strong overall revenue performance, driven by a relatively small group of high-value customers and a limited set of high-demand products. Total revenue exceeded ₦212M, with an average order value of approximately ₦997K, indicating sizable transaction volumes. Sales activity peaked sharply in September, followed by fluctuating but sustained performance toward the end of the year. Customer segmentation shows a near-even split between repeat and one-time buyers, highlighting opportunities to strengthen retention strategies among high-spending clients.

However, the findings also expose notable operational risk related to payment behavior. A significant majority of customers settled invoices after the due date, with payment delays extending up to 140 days in extreme cases. While over 99% of transactions were eventually paid, the prevalence of late payments poses cash-flow pressure and underscores the need for tighter credit controls and proactive collections. From an inventory perspective, a small number of products accounts for both the highest order frequency and the largest sales volumes, suggesting clear candidates for inventory prioritization and demand-driven stocking decisions.

**Strategic Recommendations**

1.	VIP Loyalty Program: Since 10 customers drive nearly half your revenue, implement a "Gold Tier" for customers like Green Access Pharmacy and Klen Gwagwalada to ensure long-term retention.
   
2.	Inventory Optimization: Vama ORS and Codolin Expectorant should never be out of stock. Use the 7,000-unit outlier data to set "Safety Stock" levels for high-quantity buyers.
   
3.	Shorten Credit Cycles: The current payment delay between Order Date and Due Date is often 60+ days. Consider offering a 2% discount for payments made within 15 days to improve cash flow.
   
4.	Audit "Damaged Stocks": The only unpaid balances are tied to damaged stocks. Investigate the logistics chain to reduce breakage and recover that lost ₦33k.



