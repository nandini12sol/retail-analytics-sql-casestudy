# Case Study: Retail Analytics

## 📌 Project Overview
This casestudy focuses on a retail company that has encountered  challenges in understanding its sales performance, customer engagement and inventory management. 
Through a comprehensive data analysis approach , the company aims to identify high and low sales products, effectively segment customers base and analyse customer behaviour 
to enhance marketing strategies, inventory decisions and overall customer experience.

## 📊 Dataset Description
Sales Transaction: Records of sales transactions, including transaction ID, customer ID, product ID, quantity purchased, transaction date and price.
Customer Profiles: Information on customers, including customer ID, age, gender, location, and join date.
Product inventory: Data on product inventory including product ID, product name, category, stack level and price.

## 🧠 Case Study Questions & Solutions

### Total Sales Summary

### Q1: Write a SQL query to summarize the total sales and quantities sold per product by the company.
```sql
select ProductID,
sum(quantitypurchased) as TotalUnitsSold,
sum(price*quantitypurchased) as TotalSales
from sales_transaction
group by ProductId
order by 3 desc;
```

#### Output :
<img width="535" height="261" alt="image" src="https://github.com/user-attachments/assets/4dd57711-1364-4709-aa88-eb5e77d78794" /> 

#### 🔍 Business Performance Insights
* **Top Revenue Generator:** **ProductID 17 is the clear flagship product**, dominating both sales volume (100 units) and overall revenue ($9,450.00). It leads the second-highest earner (Product 87) by over $1,630.
* **High-Margin vs. High-Volume Drivers:** Several products achieve top-10 revenue rankings despite lower unit volumes, signaling higher unit price points:
  * **ProductID 96** ranks #4 in revenue ($7,132.32) with only 72 units sold (~$99.06/unit), out-earning **ProductID 54** ($7,052.86) which required 86 units (~$82.01/unit).
  * Similarly, **ProductID 156** (76 units) out-earns **ProductID 57** (78 units), and **ProductID 200** (69 units) sits comfortably in the top 10 due to its high average ticket size (~$93.91/unit).

#### 🛠️ Actionable Recommendations
1. **Protect Inventory for Flagship Items:** Prioritize safety stock and supplier SLAs for **ProductID 17** and **ProductID 87**. Any stockout on these high-velocity items will immediately impact top-line revenue.
2. **Upsell High-Margin Products:** Promote **ProductID 96** and **ProductID 200** through featured placements or loyalty perks. Because their average unit price is nearly $95–$100, small increases in unit volume will generate disproportionate revenue gains.


### Customer Purchase Frequency

### Q2: Write a SQL query to count the number of transactions per customer to understand purchase frequency.
```sql
select CustomerID,
count(*) as NumberOfTransactions
from sales_transaction
group by 1 
order by 2 desc;
```

#### Output :
<img width="398" height="255" alt="image" src="https://github.com/user-attachments/assets/96761ce0-3813-47f4-ab10-b6d850512d26" />


#### 🔍 Business Performance Insights
* **Top Repeat Buyer:** **CustomerID 664 leads all buyers in purchase frequency**, placing 14 separate orders and outpacing the next tier by 2 transactions.
* **Tightly Clustered VIP Tier:** Immediately below the top customer, **7 distinct customers (IDs 958, 99, 113, 929, 936, 670, and 39) are tied at 12 transactions**, followed closely by **CustomerID 277 and 476 at 11 transactions**. This tight clustering signals a reliable core group of habitual repeat buyers.


#### 🛠️ Actionable Recommendations

1. **Analyze High-Frequency Basket Composition:** Join `sales_transaction` with product data for these top 10 CustomerIDs to identify which categories or flagship items (such as ProductID 17) drive their repeat visits, then promote those products to lower-frequency shoppers.
2. **Expand into RFM Segmentation:** Combine transaction count (Frequency) with total spend (Monetary) and last purchase date (Recency) to distinguish active high-frequency buyers from power users who may have recently gone quiet.


### Product Categories Performance

### Q3: Write a SQL query to evaluate the performance of the product categories based on the total sales which help us understand the product categories which needs to be promoted in the marketing campaigns.
```sql
select p.Category,
sum(s.quantitypurchased) as TotalUnitsSold,
sum(p.price*s.quantitypurchased) as TotalSales
from sales_transaction s 
join product_inventory p 
on s.productid=p.productid
group by p.Category
order by TotalSales desc;
```

#### Output :
<img width="601" height="182" alt="image" src="https://github.com/user-attachments/assets/46044940-c4c2-4c51-8f5e-d2d5f2783d8f" />

#### 🔍 Product Category Insights
* **Dominant Market Segment:** **Home & Kitchen is the clear revenue powerhouse**, leading both in volume (3,477 units sold) and total revenue ($217,755.94). It outperforms the next highest category by over $40,000.
* **The Volume vs. Value Paradox:** **Beauty & Health exhibits a lower average unit value.** Even though Beauty & Health sold more physical units (3,001) than Clothing (2,810), it generated significantly less total revenue ($143,824.99 vs $162,874.21). This implies that Clothing has a much higher average unit price than Beauty & Health.


#### 🛠️ Actionable Recommendations
1. **Targeted Marketing Campaigns:** Allocate a larger portion of the promotional budget to **Electronics and Clothing**. Since these sectors yield high revenue per item sold, increasing their sales volumes slightly via strategic campaigns will maximize overall profit margins.
2. **Beauty & Health Cross-Selling / Bundling:** Since Beauty & Health has high transaction volume but lower total revenue, implement cross-selling strategies (e.g., "Buy 3 for $X") or bundle them with higher-ticket Home & Kitchen items to raise the average order value (AOV).


### Sales Trend

### Q4: Write a SQL query to identify the sales trend to understand the revenue pattern of the company.

```sql
select 
cast(transactiondate as date) as DATETRANS,
count(*) as Transaction_count,
sum(quantitypurchased) as TotalUnitsSold,
round(sum(price*quantitypurchased),2) as TotalSales
from sales_transaction
group by cast(transactiondate as date)
order by DATETRANS desc;
```

#### Output :
<img width="702" height="263" alt="image" src="https://github.com/user-attachments/assets/0689f898-e441-4ff6-8741-f79fdc19ae15" />
 

#### 🔍 Sales Trend Insights
* **Partial Data Alert (2023-07-28):** There is a sharp decline in sales ($1,158.86) and transaction volume (8) on the final day. Given the uniform pattern of prior days, this strongly indicates an **incomplete day or a mid-day data snapshot** rather than an organic drop in business performance.
* **Highly Uniform Base Transaction Rate:** Excluding the final day, the dataset shows an identical `Transaction_count` of exactly **24 transactions per day** across every single date. In a real-world scenario, this is an extreme statistical anomaly, suggesting either synthetic data generation constraints, capped batch processing, or a fixed system data-pull limitation.


#### 🛠️ Actionable Recommendations
1. **Time-of-Day Granularity Check:** Break this analysis down further by extracting the hours from the original `transactiondate` timestamp. Seeing if the 24 daily transactions map to exactly 1 transaction per hour will confirm whether the data pipeline is artificially throttled.
2. **Normalize Partial Reporting Intervals:** When building dashboards or forecasting models with this trend data, explicitly filter out or flag the final day (`2023-07-28`) to avoid throwing off moving averages and running-total indicators.



### Growth rate of sales

### Q5: Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.

```sql
with monthly_sales as (
select month(transactiondate) as month,
round(sum(quantitypurchased*price),2) as total_sales
from sales_transaction 
group by 1
)
select month,total_sales,
round(lag(total_sales) over(order by month),2) as previous_month_sales,
round((total_sales-lag(total_sales) over(order by month))/(lag(total_sales) 
over(order by month))*100,2) as  mom_growth_percentage
from monthly_sales
order by month;
```

#### Output :
<img width="700" height="230" alt="image" src="https://github.com/user-attachments/assets/7a26becd-248f-45e6-aeb4-c45a9815c590" />
 

#### 🔍 Month-over-Month (MoM) Growth Insights
* **The Revenue Ceiling Plateau:** From Month 1 through Month 6, the company's revenue heavily oscillates around a stable baseline of roughly **$100,000 per month**. The shallow ups and downs (-7.29%, +6.81%, -1.66%, +1.42%, -0.77%) indicate stagnant growth or a mature business model struggling to scale past its current capacity.
* **Critical Drop in Month 7:** Month 7 exhibits a alarming, double-digit collapse of **-10.99%**, dragging total revenue down to a dataset-low of $90,981.75. This marks a significant departure from the steady $100k monthly trajectory observed previously.


#### 🛠️ Actionable Recommendations
1. **Diagnose the Month 7 Slump:** Conduct an emergency deep-dive audit specifically on Month 7 transaction records. Assess whether this sharp decline stems from systemic customer churn, an inventory stockout of top-performing items (like Product 17), or incomplete reporting intervals cutting the month short.
2. **Break Through the $100k Resistance Level:** Because the business is trapped in a cyclical revenue plateau during the first half-year, launch strategic demand-generation frameworks (e.g., referral bonuses, aggressive paid ad acquisition campaigns) to inject new pipeline velocity.


### Loyalty Indicators

### Q6:Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular company to understand the loyalty of the customer.

```sql
select CustomerID,
min(transactiondate) as FirstPurchase,
max(transactiondate) as LastPurchase,
datediff(max(transactiondate),min(transactiondate)) as DaysBetweenPurchases
from sales_transaction 
group by CustomerID
having DaysBetweenPurchases>0
order by 4 desc;
```

#### Output :
<img width="703" height="258" alt="image" src="https://github.com/user-attachments/assets/8e1e5a1e-bf30-4d6a-b235-94ec723e106c" />

#### 🔍 Customer Loyalty Insights
* **Full-Lifecycle Retention:** **CustomerID 215 has the longest active lifespan** at **208 days**, purchasing on both the first recorded day (`2023-01-01`) and the final recorded day (`2023-07-28`) of the dataset.
* **Overlap Between Tenure and Frequency:** **CustomerID 664** (204 days) and **CustomerID 277** (203 days) appear in both the top 10 for purchase frequency (14 and 11 orders) and top 10 for customer tenure. This confirms they are true high-engagement champions rather than sporadic shoppers who simply bought twice months apart.


#### 🛠️ Actionable Recommendations
1. **Reward Long-Tenure Champions:** Recognize long-standing customers like **CustomerID 215, 414, and 664** with milestone anniversary perks or early access to new products to reinforce multi-month retention.
2. **Distinguish "Active Loyalists" from "Sporadic Returners":** Pair `DaysBetweenPurchases` with `NumberOfTransactions` to calculate each customer's average purchase cadence (`DaysBetweenPurchases / (NumberOfTransactions - 1)`). This separates consistent buyers from customers who only made two purchases 200 days apart.


### Customer Segmentation

### Q7: Write an SQL query that segments customers based on the total quantity of products they have purchased. Also, count the number of customers in each segment which will help us target a particular segment for marketing.

```sql
create table customer_segment as
with cust_base as(
select c.customerid,
sum(s.quantitypurchased) total_qty
from sales_transaction s 
left join customer_profiles c 
on s.customerid=c.customerid
group by 1
)
select customerid,
case when total_qty between 1 and 10 then 'Low'
when total_qty between 11 and 30 then 'Med'
when total_qty >30 then 'High'
else 'None'
end as CustomerSegment
from cust_base;
select CustomerSegment,count(*) from customer_segment 
group by 1;
    
```

#### Output :
<img width="338" height="157" alt="image" src="https://github.com/user-attachments/assets/cb43d4f0-f0d0-48aa-84db-f094a15b7ee6" />

#### 🔍 Customer Segmentation Insights
* **Strong Mid-Tier Core:** Out of **989 active purchasing customers**, the largest group sits in the **Medium segment (`11–30` units)** with **559 customers (56.5%)**, showing that most buyers engage in repeat or multi-item purchases rather than single one-off orders.
* **Large Growth Pool in the Low Tier:** **423 customers (42.8%) fall into the Low segment (`1–10` units)**, representing a substantial pool of casual or newer buyers who have not yet scaled their order volume.
* **Ultra-Exclusive High-Volume Tier:** Only **7 customers (0.7%) reach the High segment (`>30` units)**, making them an elite group of bulk or super-frequent buyers.

#### 🛠️ Actionable Recommendations
1. **Protect and Retain the Top 7 "High" Buyers:** Assign dedicated VIP perks, exclusive discounts, or early-access rewards to the **7 High-segment customers**. Losing even one or two of these accounts would noticeably impact unit volume.
2. **Convert "Med" Customers into "High" Buyers:** Since **559 customers** already buy between 11 and 30 units, introduce tiered volume incentives (e.g., "Unlock VIP status at 31+ items" or bundle discounts) to nudge upper-tier Medium shoppers past the 30-unit threshold.
3. **Nurture the "Low" Segment with Second-Order Triggers:** Target the **423 Low-segment customers** with automated post-purchase follow-ups, personalized product recommendations, and cross-sell bundles to move them into the Medium tier.




ble or an image screenshot of the result here)

