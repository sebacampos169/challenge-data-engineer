--Creo vista temporal del archivo de Ventas
CREATE VIEW raw_ventas AS
SELECT row_number() OVER () AS linea, *
FROM read_csv('data/raw/historico/Ventas.csv', all_varchar=true);


CREATE OR REPLACE TABLE ventas_norm AS
SELECT
    linea,
    CAST(ID_Venta AS BIGINT)            AS id_venta,
    CAST(Fecha AS DATE)                 AS fecha,
    CAST(ID_Producto AS INTEGER)        AS id_producto,
    CAST(ID_Tienda AS INTEGER)          AS id_tienda,
    CAST(Cantidad AS INTEGER)           AS cantidad,
    CAST(Precio_Unitario AS DECIMAL(18,4)) AS precio_unitario,
    Categoría_Venta                     AS tipo_venta,

    -- País: sin espacios, sin mayúsculas, sin tildes, y unifico idiomas
    CASE lower(strip_accents(trim(Ubicación_Tienda)))
        WHEN 'mexico' THEN 'México'
        WHEN 'brasil' THEN 'Brasil'  WHEN 'brazil' THEN 'Brasil'
        WHEN 'italia' THEN 'Italia'  WHEN 'italy'  THEN 'Italia'
    END AS pais_tienda,

    -- Categoría de producto
    CASE lower(strip_accents(trim(Categoría_Producto)))
        WHEN 'electronica' THEN 'Electrónica'
        WHEN 'ropa'        THEN 'Ropa'
        WHEN 'alimentos'   THEN 'Alimentos'
        WHEN 'muebles'     THEN 'Muebles'
    END AS categoria,

    -- Canal: si viene vacío, lo deduzco del nombre de la tienda
    coalesce(
        nullif(trim(Canal_Venta), ''),
        CASE WHEN Nombre_Tienda LIKE 'Tienda Online%' THEN 'Online' ELSE 'Offline' END
    ) AS canal
FROM raw_ventas