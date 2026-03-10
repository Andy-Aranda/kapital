CREATE TABLE dim_credito (
    credit_id VARCHAR(50) PRIMARY KEY,
    status VARCHAR(20),
    term_months INT,
    interest_rate DECIMAL(5, 4)
);