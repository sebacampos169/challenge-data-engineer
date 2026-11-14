CREATE SCHEMA IF NOT EXISTS silver;
CREATE TABLE IF NOT EXISTS silver.costos (
archivo         VARCHAR,
periodo         VARCHAR,
id_producto     INTEGER,
costo_unitario  DECIMAL(18,2),
PRIMARY KEY(periodo, id_producto)
);

INSERT OR REPLACE INTO silver.costos BY NAME
SELECT archivo, periodo, id_producto, costo_unitario
FROM costos_chk
WHERE fallas = '';

--Costos rechazados
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
SELECT c.archivo, c.linea, 'costos', c.fallas, CAST(to_json(r) AS VARCHAR)
FROM costos_chk c
JOIN bronze.costos r ON r.archivo = c.archivo AND r.linea = c.linea
WHERE c.fallas <> '';