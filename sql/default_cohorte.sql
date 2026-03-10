WITH base_calculo AS (
    SELECT 
        t.cohorte,
        d.status,
        -- window function (COUNT OVER PARTITION)
        COUNT(f.credit_id) OVER(PARTITION BY t.cohorte) AS total_creditos_mes
    FROM fact_creditos f
    JOIN dim_credito d ON f.credit_id = d.credit_id
    JOIN dim_tiempo t ON f.origination_date = t.date_id
)
SELECT 
    cohorte,
    -- contar defaults y dividir entre el total de la ventana
    (COUNT(CASE WHEN status = 'default' THEN 1 END) * 100.0 / MAX(total_creditos_mes)) AS pct_default
FROM base_calculo
GROUP BY cohorte;