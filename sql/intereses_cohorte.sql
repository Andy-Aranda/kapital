SELECT 
    t.cohorte,
    -- calculo derivado: monto * tasa * (meses/12) para sacar el interes anualizado
    SUM(f.amount * d.interest_rate * (d.term_months / 12.0)) AS ingreso_intereses_estimado
FROM fact_creditos f
JOIN dim_credito d ON f.credit_id = d.credit_id
JOIN dim_tiempo t ON f.origination_date = t.date_id
GROUP BY t.cohorte
ORDER BY t.cohorte;