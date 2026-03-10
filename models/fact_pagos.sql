CREATE TABLE fact_pagos (
    payment_id VARCHAR(50) PRIMARY KEY,
    credit_id VARCHAR(50),
    payment_date DATE,
    amount_paid DECIMAL(15, 2),
    days_late INT,
    -- Relaciones
    FOREIGN KEY (credit_id) REFERENCES dim_credito(credit_id),
    FOREIGN KEY (payment_date) REFERENCES dim_tiempo(date_id)
);