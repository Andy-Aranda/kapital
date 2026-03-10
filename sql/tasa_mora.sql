SELECT 
    -- calculo derivado
    (COUNT(DISTINCT CASE WHEN days_late > 30 THEN credit_id END) * 1.0 / 
    COUNT(DISTINCT credit_id)) AS tasa_mora
FROM fact_pagos;