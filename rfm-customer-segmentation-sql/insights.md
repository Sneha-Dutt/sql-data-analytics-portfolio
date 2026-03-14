# RFM Customer Segmentation Insights

## Dataset Information
**Dataset:** Olist Brazilian E-commerce Dataset  
**Source:** Kaggle  
**Link:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce  

The dataset contains real e-commerce transaction data from a Brazilian marketplace, including customer information, orders, and payments.  
This analysis focuses on understanding customer purchasing behavior using **RFM (Recency, Frequency, Monetary) segmentation**.

---

# 1. Customer Base Overview

- The analysis includes **~96,000 unique customers**.
- The **average revenue per customer is approximately R$167**.
- The **highest spending customer generated R$13,664.08 in revenue**.

### Insight
Customer spending distribution is **highly skewed**, meaning a small number of customers generate significantly more revenue compared to the average customer.

### Business Implication
High-value customers should be prioritized through **loyalty programs, personalized offers, and premium customer experiences**.

---

# 2. Recency Analysis

Recency was calculated as the **number of days since the customer's last purchase** relative to the most recent order in the dataset.

### Key Observations
- Some customers have **not made a purchase for over 500 days**.
- These customers are likely **inactive or churned**.

### Insight
A significant portion of the customer base is **not actively purchasing**, indicating potential customer churn.

### Business Recommendation
Companies can implement **re-engagement strategies**, such as:
- Win-back email campaigns
- Personalized discounts
- Retargeting advertisements

---

# 3. Purchase Frequency Analysis

Frequency represents the **number of orders placed by each customer**.

### Key Observations
- Many customers place **only one or two orders**.
- A smaller group of customers place **multiple orders**, showing higher engagement.

### Insight
The dataset indicates a **large number of one-time buyers**, suggesting opportunities to improve customer retention.

### Business Recommendation
Businesses can increase repeat purchases through:
- Loyalty programs
- Subscription services
- Personalized product recommendations

---

# 4. Customer Segmentation Using RFM

Customers were segmented using **RFM scoring** with the `NTILE(5)` function to assign scores from 1–5 based on:

- **Recency** → How recently a customer made a purchase
- **Frequency** → How often the customer purchases
- **Monetary** → How much money the customer spends

### Segments Created

| Segment | Description |
|------|------|
| Champions | Recently purchased, frequent buyers with strong spending |
| Loyal Customers | Consistent buyers with moderate purchase frequency |
| Potential Loyalists | Recent customers who may become loyal |
| At Risk | Previously active customers who have not purchased recently |
| Bad Customers | Low spending, low frequency, and long inactivity |

### Insight
Customer segmentation enables businesses to **tailor marketing strategies for different customer groups**, improving overall marketing effectiveness.

---

# 5. Revenue Contribution by Customer Segments

Revenue contribution varies significantly across different customer segments.

### Key Observations
- **Champions and Loyal Customers contribute the largest share of total revenue.**
- **At Risk customers represent previously valuable customers who may churn.**
- **Bad Customers contribute minimal revenue and show low engagement.**

### Insight
A relatively **small group of high-value customers drives a large portion of the revenue**, which is a common pattern in e-commerce businesses.

---

# 6. Business Recommendations

### Focus on Champions
- Offer **VIP benefits and exclusive deals**
- Provide **early access to sales**
- Reward loyalty with **special promotions**

### Convert Potential Loyalists
- Send **targeted marketing campaigns**
- Offer **product recommendations**
- Encourage repeat purchases through incentives

### Re-engage At Risk Customers
- Launch **win-back campaigns**
- Provide **limited-time discounts**
- Send **personalized reminder emails**

### Reduce Marketing Spend on Low-Value Segments
- Limit marketing resources for **Bad Customers**
- Focus acquisition efforts on **higher-value segments**

---

# Key Takeaways

- Customer spending is **unevenly distributed**, with high-value customers driving most of the revenue.
- Many customers make **only a single purchase**, highlighting opportunities to improve retention.
- **RFM segmentation helps businesses identify valuable customers and design targeted marketing strategies**.
- Strategic engagement of high-value and at-risk customers can **significantly improve customer lifetime value and overall revenue**.
