CREATE SCHEMA IF NOT EXISTS silver;
CREATE TABLE IF NOT EXISTS silver.tipo_cambio (
    fecha DATE,
    moneda VARCHAR,
    tasa DECIMAL(18,8),
    PRIMARY KEY(fecha, moneda)
);

INSERT OR REPLACE INTO silver.tipo_cambio BY NAME
SELECT fecha, moneda, tasa
FROM bronze.api_tipo_cambio;

