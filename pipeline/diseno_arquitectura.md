## 1. Diagrama de Flujo (Conceptual)
Propongo una arquitectura ELT (Extract, Load, Transform) basada en la nube (Azure/AWS) utilizando el patrón de Arquitectura Medallón.

- Origen: Base de Datos Transaccional (PostgreSQL/SQL Server), files, streaming.

- Ingesta: Azure Data Factory (Extracción incremental).

- Storage: Data Lake Storage (Capa Bronze: Raw Data).

- Procesamiento: Databricks / Spark (Capa Silver: Limpieza y Capa Gold: Modelo Estrella).

- Destino: Data Warehouse (Snowflake / Synapse) o tablas Delta para consumo en BI.

![Flujo de pipeline](/images/pipeline.png)

## 2. Herramientas seleccionadas
- Orquestador: Azure Data Factory (ADF). Herramienta elegida por su capacidad de reintentos y monitoreo centralizado.

- Transformación: Databricks (PySpark). Permite procesar grandes volúmenes de datos de forma distribuida y manejar la lógica de negocio compleja.

- Almacenamiento: Delta Lake. Vital para garantizar transacciones ACID y poder realizar upserts o merge de forma eficiente.
