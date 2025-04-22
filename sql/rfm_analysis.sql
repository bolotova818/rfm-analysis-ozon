
-- RFM-анализ клиентской базы Ozon

-- 1. Расчёт метрик RFM по каждому клиенту
WITH rfm_raw AS (
  SELECT
    customer_id,
    JULIANDAY('2024-12-31') - JULIANDAY(MAX(order_date)) AS recency_days,
    COUNT(order_id) AS frequency,
    SUM(total) AS monetary
  FROM Ozon_Orders
  GROUP BY customer_id
),

-- 2. Присвоение баллов от 1 до 5 по каждой метрике
rfm_scored AS (
  SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days ASC) AS R_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS F_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS M_score
  FROM rfm_raw
)

-- 3. Финальный вывод с RFM-сегментами
SELECT
  customer_id,
  recency_days,
  frequency,
  monetary,
  R_score,
  F_score,
  M_score,
  CAST(R_score AS TEXT) || CAST(F_score AS TEXT) || CAST(M_score AS TEXT) AS RFM_segment
FROM rfm_scored
ORDER BY R_score DESC, F_score DESC, M_score DESC;


-- 4. Количество клиентов в каждом сегменте
SELECT
  RFM_segment,
  COUNT(*) AS customer_count
FROM (
  SELECT
    customer_id,
    CAST(NTILE(5) OVER (ORDER BY recency_days ASC) AS TEXT) ||
    CAST(NTILE(5) OVER (ORDER BY frequency ASC) AS TEXT) ||
    CAST(NTILE(5) OVER (ORDER BY monetary ASC) AS TEXT) AS RFM_segment
  FROM rfm_raw
)
GROUP BY RFM_segment
ORDER BY customer_count DESC;


-- 5. Суммарная выручка по каждому сегменту
SELECT
  RFM_segment,
  SUM(monetary) AS total_revenue,
  COUNT(*) AS customers
FROM (
  SELECT
    customer_id,
    monetary,
    CAST(NTILE(5) OVER (ORDER BY recency_days ASC) AS TEXT) ||
    CAST(NTILE(5) OVER (ORDER BY frequency ASC) AS TEXT) ||
    CAST(NTILE(5) OVER (ORDER BY monetary ASC) AS TEXT) AS RFM_segment
  FROM rfm_raw
)
GROUP BY RFM_segment
ORDER BY total_revenue DESC;
