CREATE TABLE dim_tiempo (
    date_id DATE PRIMARY KEY,
    anio INT,
    mes INT,
    nombre_mes VARCHAR(20),
    trimestre INT,
    cohorte VARCHAR(7)
);