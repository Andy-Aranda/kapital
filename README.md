# Kapital: Challenge Técnico
Este repositorio contiene la solución al challenge técnico para la posición de Ingeniero de Datos. El objetivo es diseñar un modelo analítico para una financiera de PYMES que permita evaluar el desempeño de la colocación de créditos y el comportamiento de pagos.

### 🏗️ Estructura del Proyecto
```
├── data/           # Datos simulados en formato CSV
├── models/         # Scripts DDL para la creación de tablas (Esquema Estrella)
├── sql/            # Queries que responden a las preguntas de negocio
├── pipeline/       # Documentación técnica del flujo de datos
├── images/         # Imágenes utilizadas para descripción de procesos
├── README.md       # Documentación general y respuestas del challenge
├── kapital.db      # Base de datos local (generada por DuckDB)
└── seeds.sql       # Script de carga de datos iniciales
```
### 1. Modelado de Datos
#### Diseño: Esquema Estrella (Star Schema)
Se optó por un modelo dimensional tipo Estrella. Debido a que el negocio tiene dos procesos con distinta granularidad (originación de crédito y recepción de pagos), se implementaron dos tablas de hechos que comparten dimensiones (Fact Constellation).

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

3. Costo de Cómputo: En entornos cloud, es preferible optimizar el tiempo de lectura que el espacio de almacenamiento.

### 2. Pipeline Conceptual (Ingesta y Transformación)
#### Arquitectura Propuesta
Para llevar los datos de un sistema transaccional (OLTP) a un Data Warehouse en la nube, propongo una Arquitectura Medallón (data lake):

1. Herramientas: Orquestación: Azure Data Factory (ADF) o Apache Airflow.
    - Procesamiento: Databricks (PySpark) para transformaciones distribuidas.
    - Almacenamiento: Delta Lake sobre Azure Data Lake Storage (ADLS).

2. Manejo de Incrementalidad:  Implementaría una estrategia de watermarking utilizando la columna ```updated_at``` de las tablas origen para extraer solo registros nuevos o modificados desde la última ejecución.
    - Para la carga en las tablas finales, usaría la sentencia MERGE de Delta Lake para realizar upserts.

### 3. Escalabilidad en Producción
Para escalar esta solución a millones de registros:

1. Particionamiento: Particionar las tablas de hechos por fecha (ej. year, month) para mejorar el data skipping.

2. Cómputo Distribuido: Migrar scripts locales a PySpark en un cluster de Databricks para procesamiento en paralelo.

3. CI/CD: Implementar pipelines en GitHub Actions para automatizar pruebas unitarias sobre los queries SQL y asegurar la calidad del código antes del despliegue.


### 4. Calidad de Datos
#### Validaciones
Implementaría validaciones en tres niveles dentro de la arquitectura Medallón:

1. Validación de Esquema (Capa Bronze): Asegurar que los tipos de datos sean correctos (ej. que amount sea numérico y no texto) y aplicar Schema Enforcement para evitar que cambios inesperados en el origen rompan el pipeline.

2. Validación de Integridad (Capa Silver): * Not Nulls: Campos críticos como credit_id, payment_id, amount y origination_date deben ser obligatorios.

    a) Rangos Lógicos: Validar que amount y amount_paid sean siempre mayores a cero y que la interest_rate esté en un rango lógico (ej. 0 a 1).

3. Unicidad: Verificar que no existan Primary Keys duplicadas en las dimensiones antes de procesar los hechos.

#### Detección de Duplicados
La detección de duplicados se realizaría en la Capa Silver utilizando una Window Function. Esto permite identificar si un mismo ```payment_id``` ha sido enviado más de una vez (por error de sistema o re-procesamiento de archivos).


``` SQL
SELECT *, 
    ROW_NUMBER() OVER(
        PARTITION BY payment_id 
        ORDER BY updated_at DESC
    ) as rn
FROM staging_pagos; -- si rn > 1, es un duplicado
```
- Acción: Cualquier registro con ```row_num >``` 1 es marcado como duplicado. En producción, se mantendría solo el más reciente y los demás se moverían a una tabla de Logs de Errores para auditoría.

#### Consistencia entre créditos y pagos
Implementaría tres reglas:

1. Integridad Referencial: Mediante un LEFT JOIN entre fact_pagos y dim_credito, validaría que no existan "pagos huérfanos". Si un credit_id en la tabla de pagos no existe en la de créditos, el registro se envía a cuarentena.

2. Consistencia Cronológica: Validar que la fecha de pago (payment_date) sea siempre igual o posterior a la fecha de originación del crédito (origination_date). Un pago anterior a la creación del crédito indica un error de sistema.

3. Consistencia Financiera: Validar que la suma acumulada de amount_paid para un crédito no exceda significativamente el amount original más los intereses calculados (esto detectaría errores de sobre-pago o duplicidad de montos).
