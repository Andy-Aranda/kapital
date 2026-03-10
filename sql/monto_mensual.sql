SELECT 
    t.cohorte AS mes_originacion,
    SUM(f.amount) AS monto_total_colocado -- agregacion
FROM fact_creditos f
JOIN dim_tiempo t ON f.origination_date = t.date_id
GROUP BY t.cohorte
ORDER BY t.cohorte;