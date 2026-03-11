-- 1. Poblar Dimensiones (Catálogos)
INSERT INTO dim_cliente (customer_id) VALUES 
('CUST_01'), ('CUST_02'), ('CUST_03'), ('CUST_04'), ('CUST_05'), ('CUST_06');

INSERT INTO dim_credito (credit_id, status, term_months, interest_rate) VALUES
('C001', 'closed', 12, 0.15),
('C002', 'active', 6, 0.12),
('C003', 'default', 24, 0.18),
('C004', 'late', 12, 0.14),
('C005', 'active', 12, 0.16),
('C006', 'active', 18, 0.15);

INSERT INTO dim_tiempo (date_id, anio, mes, nombre_mes, trimestre, cohorte) VALUES
('2023-01-15', 2023, 1, 'Enero', 1, '2023-01'),
('2023-01-20', 2023, 1, 'Enero', 1, '2023-01'),
('2023-02-10', 2023, 2, 'Febrero', 1, '2023-02'),
('2023-02-15', 2023, 2, 'Febrero', 1, '2023-02'),
('2023-02-20', 2023, 2, 'Febrero', 1, '2023-02'), -- Agregada para P002
('2023-02-25', 2023, 2, 'Febrero', 1, '2023-02'),
('2023-03-05', 2023, 3, 'Marzo', 1, '2023-03'),
('2023-03-10', 2023, 3, 'Marzo', 1, '2023-03'), -- Agregada para P004
('2023-03-12', 2023, 3, 'Marzo', 1, '2023-03'),
('2023-03-15', 2023, 3, 'Marzo', 1, '2023-03'), -- Agregada para P005
('2023-03-25', 2023, 3, 'Marzo', 1, '2023-03'),
('2023-04-05', 2023, 4, 'Abril', 2, '2023-04'),
('2023-04-10', 2023, 4, 'Abril', 2, '2023-04'),
('2023-04-25', 2023, 4, 'Abril', 2, '2023-04');

-- 2. Poblar Tablas de Hechos (Eventos)
INSERT INTO fact_creditos (credit_id, customer_id, origination_date, amount) VALUES
('C001', 'CUST_01', '2023-01-15', 100000),
('C002', 'CUST_02', '2023-01-20', 50000),
('C003', 'CUST_03', '2023-02-10', 200000),
('C004', 'CUST_04', '2023-02-25', 80000),
('C005', 'CUST_05', '2023-03-05', 150000),
('C006', 'CUST_06', '2023-03-12', 120000);

INSERT INTO fact_pagos (payment_id, credit_id, payment_date, amount_paid, days_late) VALUES
('P001', 'C001', '2023-02-15', 9000, 0),
('P002', 'C002', '2023-02-20', 8500, 0),
('P003', 'C004', '2023-03-25', 5000, 35),
('P004', 'C003', '2023-03-10', 0, 45),
('P005', 'C001', '2023-03-15', 9000, 0),
('P006', 'C005', '2023-04-05', 13000, 2),
('P007', 'C004', '2023-04-25', 5000, 40),
('P008', 'C003', '2023-04-10', 0, 75);