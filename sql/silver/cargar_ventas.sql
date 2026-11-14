CREATE SCHEMA IF NOT EXISTS silver;
ALTER TABLE silver.ventas ADD COLUMN IF NOT EXISTS codigo_promocion VARCHAR;
CREATE TABLE IF NOT EXISTS silver.ventas (
    id_venta        BIGINT PRIMARY KEY,
    archivo         VARCHAR,
    fecha           DATE,
    id_producto     INTEGER,
    id_tienda       INTEGER,
    cantidad        INTEGER,
    precio_unitario DECIMAL(18,4),
    tipo_venta      VARCHAR,
    pais_tienda     VARCHAR,
    categoria       VARCHAR,
    canal           VARCHAR,
    codigo_promocion VARCHAR
);

-- IMPORTANTE UPSERT DE TABLA, si id_venta existe lo actualiza, en caso de que no exista lo inserta
INSERT OR REPLACE INTO silver.ventas
SELECT id_venta, archivo, fecha, id_producto, id_tienda, cantidad, precio_unitario, tipo_venta, pais_tienda, categoria, canal, codigo_promocion
FROM ventas_chk
WHERE fallas = '';

--Ventas rechazadas
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
SELECT c.archivo, c.linea, 'ventas', c.fallas, CAST(to_json(r) AS VARCHAR)
FROM ventas_chk c
JOIN bronze.ventas r ON r.archivo = c.archivo AND r.linea = c.linea
WHERE c.fallas <> '';