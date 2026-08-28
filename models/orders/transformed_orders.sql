-- models/staging/stg_orders.sql

-- {{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ source('bigquery_source', 'orders') }} --staging.orders

)

SELECT
    order_id,
    customer_id,
    order_date,
    product_id,
    product_name,
    category,
    quantity,
    unit_price,
    total_amount,
    status,
    payment_method,
    shipping_city,
    shipping_state,
    DATE_DIFF(current_date(),order_date,DAY) AS days_since_order,
    quantity * unit_price AS calculated_total_amount,

    status = 'Delivered' AS is_delivered,

    status = 'Cancelled' AS is_cancelled,

    CASE
        WHEN total_amount >= 50000 THEN 'High Value'
        WHEN total_amount >= 20000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_value_segment,

    DATE_TRUNC(order_date, MONTH) AS order_month,

    EXTRACT(YEAR FROM order_date) AS order_year,

    EXTRACT(MONTH FROM order_date) AS order_month_number,

    -- Audit columns
    'dbt' AS loaded_by,
    CURRENT_TIMESTAMP() AS loaded_at,
    'BigQuery' AS source_system,
    'bigquery_source.orders' AS source_table,
    'India' AS source_region

FROM source_data