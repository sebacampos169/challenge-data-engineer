CREATE SCHEMA IF NOT EXISTS silver;
CREATE TABLE IF NOT EXISTS silver.devoluciones (
    archivo             VARCHAR,
    linea               INTEGER,
    id_devolucion       INTEGER PRIMARY KEY,
    id_venta            INTEGER,
    fecha               DATE,
    id_producto         INTEGER,
    id_cliente          INTEGER,
    id_tienda           INTEGER,
    cantidad_devuelta   INTEGER,
    motivo              VARCHAR(100),
    precio_unitario     DECIMAL(18,4),
    nombre_cliente      VARCHAR(100),
    pais                VARCHAR(100),
    ubicacion_tienda    VARCHAR(100),
    nombre_producto     VARCHAR(100),
    categoria_producto  VARCHAR(100)

);

-- IMPORTANTE UPSERT DE TABLA, si id_venta existe lo actualiza, en caso de que no exista lo inserta
INSERT OR REPLACE INTO silver.devoluciones
SELECT archivo,
    linea,       
    id_devolucion,
    id_venta,  
    fecha,     
    id_producto,
    id_cliente,    
    id_tienda,    
    cantidad_devuelta,
    motivo,
    precio_unitario,
    nombre_cliente,
    pais,
    ubicacion_tienda,
    nombre_producto,
    categoria_producto
FROM devoluciones_chk
WHERE fallas = '';

-- Devoluciones rechazadas
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
SELECT c.archivo, c.linea, 'devoluciones', c.fallas, CAST(to_json(r) AS VARCHAR)
FROM devoluciones_chk c
JOIN bronze.devoluciones r ON r.archivo = c.archivo AND r.linea = c.linea
WHERE c.fallas <> '';