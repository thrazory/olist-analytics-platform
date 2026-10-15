WITH orders_base AS (
  SELECT order_id, customer_id, order_status, order_purchase_timestamp
  FROM olist_orders_dataset
),
orders_with_payment AS (
  SELECT o.order_id, o.customer_id, o.order_status, p.payment_value
  FROM orders_base o
  LEFT JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
),
orders_with_review AS (
  SELECT op.*, r.review_score
  FROM orders_with_payment op
  LEFT JOIN olist_order_reviews_dataset r ON op.order_id = r.order_id
)
SELECT
  order_status,
  COUNT(*) AS total_orders,
  AVG(payment_value) AS avg_ticket,
  AVG(review_score) AS avg_review
FROM orders_with_review
GROUP BY order_status;

-- 2. Clientes que compraram mais de uma vez
WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders,
    MIN(order_purchase_timestamp) AS first_purchase,
    MAX(order_purchase_timestamp) AS last_purchase
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
),
repeat_customers AS (
  SELECT * FROM customer_orders WHERE total_orders > 1
)
SELECT
  COUNT(*) AS repeat_customers,
  AVG(total_orders) AS avg_orders_per_customer,
  AVG(EXTRACT(DAY FROM last_purchase - first_purchase)) AS avg_days_between_purchases
FROM repeat_customers;

-- 3. Top 5 categorias por estado (CTE + Window Function)
WITH category_state_revenue AS (
  SELECT
    c.customer_state,
    p.product_category_name,
    SUM(oi.price) AS total_revenue
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
  JOIN olist_products_dataset p ON oi.product_id = p.product_id
  GROUP BY 1, 2
),
ranked AS (
  SELECT *,
    RANK() OVER (PARTITION BY customer_state ORDER BY total_revenue DESC) AS rank
  FROM category_state_revenue
)
SELECT * FROM ranked WHERE rank <= 5;
