CREATE SCHEMA IF NOT EXISTS silver;
CREATE TABLE IF NOT EXISTS silver.precios (
archivo         VARCHAR,
id_producto     INTEGER,
vigencia_desde  DATE,
precio_lista    DECIMAL(18,2),
PRIMARY KEY(id_producto, vigencia_desde)
);

INSERT OR REPLACE INTO silver.precios BY NAME
SELECT archivo, id_producto, vigencia_desde, precio_lista
FROM precios_chk
WHERE fallas = '';

--Precios rechazadas
CREATE TABLE IF NOT EXISTS silver.rechazados (
    archivo  VARCHAR,
    linea    BIGINT,
    fuente   VARCHAR,
    reglas   VARCHAR,
    registro VARCHAR,
    PRIMARY KEY (archivo, linea)
);

DELETE FROM silver.rechazados WHERE archivo = '{ruta}';

INSERT INTO silver.rechazados
SELECT c.archivo, c.linea, 'precios', c.fallas, CAST(to_json(r) AS VARCHAR)
FROM precios_chk c
JOIN bronze.precios r ON r.archivo = c.archivo AND r.linea = c.linea
WHERE c.fallas <> '';