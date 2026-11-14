CREATE SCHEMA IF NOT EXISTS silver;
CREATE TABLE IF NOT EXISTS silver.objetivos (
archivo         VARCHAR,
periodo         VARCHAR,
id_tienda     INTEGER,
objetivo_ventas  DECIMAL(18,2),
PRIMARY KEY(periodo, id_tienda)
);

INSERT OR REPLACE INTO silver.objetivos BY NAME
SELECT archivo, periodo, id_tienda, objetivo_ventas
FROM objetivos_chk
WHERE fallas = '';

--Objetivos rechazados
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
SELECT c.archivo, c.linea, 'objetivos', c.fallas, CAST(to_json(r) AS VARCHAR)
FROM objetivos_chk c
JOIN bronze.objetivos r ON r.archivo = c.archivo AND r.linea = c.linea
WHERE c.fallas <> '';