## 1. Diagrama de Flujo (Conceptual)
Propongo una arquitectura ELT (Extract, Load, Transform) basada en la nube (Azure/AWS) utilizando el patrón de Arquitectura Medallón.

- Origen: Base de Datos Transaccional (PostgreSQL/SQL Server).

- Ingesta: Azure Data Factory / Airflow (Extracción incremental).

- Storage: Data Lake Storage (Capa Bronze: Raw Data).

- Procesamiento: Databricks / Spark (Capa Silver: Limpieza y Capa Gold: Modelo Estrella).

- Destino: Data Warehouse (Snowflake / Synapse) o tablas Delta para consumo en BI.

## 2. Herramientas seleccionadas
- Orquestador: Azure Data Factory (ADF) o Airflow. Elegidos por su capacidad de manejar dependencias complejas, reintentos y monitoreo centralizado.

- Transformación: Databricks (PySpark). Permite procesar grandes volúmenes de datos de forma distribuida y manejar la lógica de negocio compleja (como la lógica de estatus de crédito).

- Almacenamiento: Delta Lake. Vital para garantizar transacciones ACID y poder realizar "Upserts" (Merge) de forma eficiente.

## 3. Manejo de Incrementalidad
Para no procesar toda la base de datos cada vez (que sería costoso e ineficiente), se implementará una estrategia de Watermarking:

1. Se identifica la fecha máxima de actualización (```max_updated_at```) en el Data Warehouse.

2. La consulta de extracción solo traerá registros donde ```updated_at``` > ```max_updated_at```.

3. En la capa Silver/Gold, se realiza un MERGE utilizando el ```credit_id``` o ```payment_id``` para actualizar registros existentes o insertar los nuevos.

## 4. Estrategia de Calidad de Datos
- Validación de Esquema: Impedir que datos con formatos incorrectos rompan el pipeline.

- Check de Nulos: Los campos ```credit_id```, ```amount``` y ```origination_date``` son obligatorios.

- Consistencia Referencial: Verificación de que cada pago (```fact_pagos```) tenga un crédito padre existente en ```dim_credito```. Si no existe, el registro se mueve a una tabla de "Cuarentena" para su revisión.