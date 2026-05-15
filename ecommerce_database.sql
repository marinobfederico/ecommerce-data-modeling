/* =============================================================================
1. CREACIÓN DEL ENTORNO Y TABLAS BASE
=============================================================================
*/

CREATE DATABASE IF NOT EXISTS ecommerce_project;
USE ecommerce_project;

-- Tabla de Clientes (Dimensión)
CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(20)
);

-- Tabla de Productos Original (Para importación)
CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
);

-- Tabla de Órdenes (Hechos / Centro)
CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_timestamp DATETIME -- Agregada para análisis de logística
);

-- Tabla de Items de Órdenes (Hechos detalle)
CREATE TABLE order_items (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    price DECIMAL(10,2),
    shipping_charges DECIMAL(10,2)
);

-- Tabla de Pagos (Hechos detalle)
CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

/* =============================================================================
2. DEPURACIÓN DE DATOS (DATA CLEANING)
=============================================================================
*/

-- El dataset de Kaggle contiene duplicados en productos. 
-- Creamos una versión "maestra" única usando MAX para evitar inconsistencias.
CREATE TABLE products_clean AS
SELECT
    product_id,
    MAX(product_category_name) AS product_category_name,
    MAX(product_weight_g) AS product_weight_g,
    MAX(product_length_cm) AS product_length_cm,
    MAX(product_height_cm) AS product_height_cm,
    MAX(product_width_cm) AS product_width_cm
FROM products
GROUP BY product_id;

-- Definición de Claves Primarias (PK)
ALTER TABLE products_clean ADD PRIMARY KEY (product_id);
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
ALTER TABLE orders ADD PRIMARY KEY (order_id);

/* =============================================================================
3. INTEGRIDAD REFERENCIAL (ELIMINACIÓN DE HUÉRFANOS)
=============================================================================
*/

SET SQL_SAFE_UPDATES = 0;

-- Borramos items de órdenes que no existen en la tabla principal de órdenes
DELETE oi FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Borramos items de productos que no existen en nuestra tabla limpia
DELETE oi FROM order_items oi
LEFT JOIN products_clean p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Borramos registros de pagos de órdenes inexistentes
DELETE p FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

SET SQL_SAFE_UPDATES = 1;

/* =============================================================================
4. RELACIONES (MODELO ESTRELLA)
=============================================================================
*/

ALTER TABLE orders ADD CONSTRAINT fk_orders_customers 
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE order_items ADD CONSTRAINT fk_items_orders 
FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items ADD CONSTRAINT fk_items_products 
FOREIGN KEY (product_id) REFERENCES products_clean(product_id);

ALTER TABLE payments ADD CONSTRAINT fk_payments_orders 
FOREIGN KEY (order_id) REFERENCES orders(order_id);

/* =============================================================================
5. CONSULTAS ANALÍTICAS (KPIs PRINCIPALES)
=============================================================================
*/

-- A. Revenue Total
SELECT ROUND(SUM(payment_value),2) AS total_revenue FROM payments;

-- B. Ticket Promedio (AOV)
SELECT ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2) AS avg_ticket FROM payments;

-- C. Top 10 Categorías por Ingresos
SELECT 
    p.product_category_name, 
    ROUND(SUM(oi.price),2) AS revenue
FROM order_items oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;