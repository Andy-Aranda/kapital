CREATE TABLE fact_creditos (
    credit_id VARCHAR(50),
    customer_id VARCHAR(50),
    origination_date DATE,
    amount DECIMAL(15, 2),
    FOREIGN KEY (credit_id) REFERENCES dim_credito(credit_id),
    FOREIGN KEY (customer_id) REFERENCES dim_cliente(customer_id),
    FOREIGN KEY (origination_date) REFERENCES dim_tiempo(date_id)
);