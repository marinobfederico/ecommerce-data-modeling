E-commerce SQL & Power BI Project 🇧🇷

Proyecto de análisis de datos utilizando el dataset público de Olist, uno de los principales marketplaces de e-commerce de Brasil.

El objetivo fue construir un flujo básico de trabajo de analítica de datos:

importación de archivos CSV
modelado relacional en MySQL
limpieza y validación de datos
consultas SQL para análisis de negocio
preparación del modelo para Power BI

Volumen de datos:

38.000+ clientes
100.000+ órdenes
5 tablas relacionadas
📂 Estructura del repositorio
Archivo	Descripción
ecommerce_database.sql	Script completo de creación, limpieza y análisis
df_customers.csv	Información de clientes
df_orders.csv	Órdenes y timestamps
df_order_items.csv	Productos vendidos por orden
df_payments.csv	Métodos y valores de pago
df_products.csv	Catálogo de productos
🛠️ Limpieza y preparación de datos

Durante el desarrollo del proyecto se detectaron algunos problemas de calidad de datos en el dataset original.

Duplicados en productos

Se encontraron múltiples registros repetidos para algunos product_id.
Para resolverlo, se creó una tabla depurada (products_clean) agrupando los productos mediante funciones de agregación SQL.

Registros huérfanos

Antes de crear las relaciones entre tablas, se identificaron registros en order_items y payments que no tenían correspondencia en las tablas principales.

Estos registros fueron eliminados para poder aplicar integridad referencial correctamente.

Relaciones entre tablas

Se definieron:

Primary Keys (PK)
Foreign Keys (FK)

para construir un modelo relacional apto para consultas analíticas y conexión con Power BI.

🏗️ Modelo de datos
customers ──┐
            ├──► orders ──► order_items ──► products_clean
payments ───┘

El modelo separa tablas de dimensiones (customers, products_clean) y tablas transaccionales (orders, order_items, payments).

📈 KPIs analizados
Revenue total
Ticket promedio (AOV)
Top categorías de productos
Métodos de pago más utilizados
Revenue por estado
Tiempo promedio de entrega
🔍 Aprendizajes del proyecto
Importación y modelado de datos relacionales en MySQL
Limpieza y validación de datos reales
Uso de JOINs y funciones de agregación
Aplicación de integridad referencial
Construcción de consultas orientadas a negocio
Preparación de datos para visualización en Power BI
🚧 Próximo paso

Desarrollo de dashboard interactivo en Power BI conectado directamente a MySQL.

📌 Dataset utilizado

Olist E-commerce Dataset — Kaggle
https://www.kaggle.com/datasets/bytadit/ecommerce-order-dataset
