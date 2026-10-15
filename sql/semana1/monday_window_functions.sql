-- 1. Ranking de vendedores por receita total
SELECT
  seller_id,
  SUM(price) AS total_revenue,
  RANK() OVER (ORDER BY SUM(price) DESC) AS revenue_rank
FROM olist_order_items_dataset
GROUP BY seller_id;

-- 2. Receita acumulada por mês (running total)
SELECT
  DATE_TRUNC('month', order_purchase_timestamp) AS month,
  SUM(payment_value) AS monthly_revenue,
  SUM(SUM(payment_value)) OVER (
    ORDER BY DATE_TRUNC('month', order_purchase_timestamp)
  ) AS cumulative_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
GROUP BY 1;

-- 3. Comparação mês atual vs mês anterior (LAG)
SELECT
  month,
  monthly_revenue,
  LAG(monthly_revenue) OVER (ORDER BY month) AS prev_month_revenue,
  monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month) AS mom_diff
FROM (
  SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    SUM(payment_value) AS monthly_revenue
  FROM olist_orders_dataset o
  JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
  GROUP BY 1
) monthly;

-- 4. Percentil de ticket médio por categoria (NTILE)
SELECT
  product_category_name,
  AVG(price) AS avg_price,
  NTILE(4) OVER (ORDER BY AVG(price)) AS price_quartile
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY product_category_name;


		


	










