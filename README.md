# Kapital: Challenge Técnico
Este repositorio contiene la solución al challenge técnico para la posición de Ingeniero de Datos. El objetivo es diseñar un modelo analítico para una financiera de PYMES que permita evaluar el desempeño de la colocación de créditos y el comportamiento de pagos.

### 🏗️ Estructura del Proyecto
```
├── data/           # Datos simulados en formato CSV
├── models/         # Scripts DDL para la creación de tablas (Esquema Estrella)
├── sql/            # Queries que responden a las preguntas de negocio
├── pipeline/       # Documentación técnica del flujo de datos
├── README.md       # Documentación general y respuestas del challenge
├── kapital.db      # Base de datos local (generada por DuckDB)
└── seeds.sql       # Script de carga de datos iniciales
```
### 1. Modelado de Datos
#### Diseño: Esquema Estrella (Star Schema)
Se optó por un modelo dimensional tipo Estrella. Debido a que el negocio tiene dos procesos con distinta granularidad (Originación de crédito y Recepción de pagos), se implementaron dos tablas de hechos que comparten dimensiones (Fact Constellation).

- Tablas de Hechos:
    - ```fact_creditos```: Registra la colocación inicial del crédito.
    - ```fact_pagos```: Registra cada transacción de pago y días de atraso.

- Dimensiones:
    - ```dim_tiempo```: Permite el análisis por cohortes (mes/año) y trimestres.
    - ```dim_credito```: Contiene atributos del crédito (tasa, plazo, estatus).
    - ```dim_cliente```: Información del acreditado.

#### Estrella vs. Copo de Nieve
Se eligió el Esquema Estrella sobre el Copo de Nieve por:

1. Rendimiento: Reduce la cantidad de JOINS necesarios, acelerando las consultas analíticas.

2. Simplicidad para BI: Herramientas como Power BI o Tableau consumen de forma más eficiente modelos desnormalizados.

3. Costo de Cómputo: En entornos de nube modernos, es preferible optimizar el tiempo de lectura (Compute) que el espacio de almacenamiento (Storage).

### 2. Pipeline Conceptual (Ingesta y Transformación)
#### Arquitectura Propuesta
Para llevar los datos de un sistema transaccional (OLTP) a un Data Warehouse en la nube, propongo una Arquitectura Medallón (Lakehouse):

1. Herramientas: Orquestación: Azure Data Factory (ADF) o Apache Airflow.
    - Procesamiento: Databricks (PySpark) para transformaciones distribuidas.
    - Almacenamiento: Delta Lake sobre Azure Data Lake Storage (ADLS).

2. Manejo de Incrementalidad:  Implementaría una estrategia de Watermarking utilizando la columna ```updated_at``` de las tablas origen para extraer solo registros nuevos o modificados desde la última ejecución.
    - Para la carga en las tablas finales, usaría la sentencia MERGE de Delta Lake para realizar Upserts (Update + Insert) eficientes.

graph LR
    subgraph Origen
        A[Sistemas Transaccionales <br/> OLTP - SQL Server/Postgres]
    end

    subgraph "Azure / AWS (Data Lakehouse)"
        B[(Capa Bronze <br/> Raw Data / Delta)]
        C[(Capa Silver <br/> Cleaned / Validated)]
        D[(Capa Gold <br/> Analytical / Star Schema)]
        
        A -->|Ingesta Incremental <br/> ADF / Airflow| B
        B -->|Transformación PySpark| C
        C -->|Modelo de Datos| D
    end

    subgraph Consumo
        E[Power BI / Tableau]
        F[Data Science / ML]
        D --> E
        D --> F
    end

    style B fill:#cd7f32,stroke:#333,color:#fff
    style C fill:#c0c0c0,stroke:#333,color:#000
    style D fill:#ffd700,stroke:#333,color:#000



### 3. Calidad de Datos
- Validaciones: Implementación de restricciones NOT NULL en llaves primarias, validación de rangos (ej. amount > 0) y consistencia de tipos de datos.

- Detección de Duplicados: Uso de Window Functions en la capa de transformación:

``` SQL
SELECT *, ROW_NUMBER() OVER(PARTITION BY payment_id ORDER BY updated_at DESC) as rn
FROM staging_pagos; -- si rn > 1, es un duplicado
```
- Consistencia: Aplicación de Integridad Referencial (Foreign Keys) para asegurar que no existan pagos de créditos que no están registrados en la tabla maestra.

### 4. Ejecución del Proyecto
El proyecto utiliza DuckDB para simular el entorno analítico de forma local y eficiente.

#### Requisitos
- DuckDB instalado.

#### Pasos para replicar:
1. Abrir la terminal en la raíz del proyecto.

2. Ejecutar DuckDB: ```duckdb kapital.db```

3. Crear el modelo: ```.read models/dim_tiempo.sql```, ```.read models/fact_creditos.sql```, etc.

4. Cargar datos: ```.read seeds.sql```

5. Ejecutar analíticos: ```.read sql/porcentaje_default_cohorte.sql```


### 5. Escalabilidad en Producción
Para escalar esta solución a millones de registros:

1. Particionamiento: Particionar las tablas de hechos por fecha (ej. year, month) para mejorar el data skipping.

2. Cómputo Distribuido: Migrar los scripts de SQL/DuckDB a PySpark en un cluster de Databricks para procesamiento en paralelo.

3. CI/CD: Implementar pipelines en GitHub Actions para automatizar pruebas unitarias sobre los queries SQL y asegurar la calidad del código antes del despliegue.

#### Supuestos Realizados
- Se asume que la tasa de interés proporcionada es anual.

- El estatus 'default' se considera un estado final del crédito para el cálculo de pérdidas.

- La moneda es consistente en todas las fuentes de datos.
