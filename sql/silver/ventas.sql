CREATE SCHEMA IF NOT EXISTS silver;
CREATE OR REPLACE TEMP TABLE ventas_norm AS
SELECT
    archivo,
    linea,
    TRY_CAST(ID_Venta AS BIGINT)            AS id_venta,
    TRY_CAST(Fecha AS DATE)                 AS fecha,
    TRY_CAST(ID_Producto AS INTEGER)        AS id_producto,
    TRY_CAST(ID_Tienda AS INTEGER)          AS id_tienda,
    TRY_CAST(Cantidad AS INTEGER)           AS cantidad,
    TRY_CAST(Precio_Unitario AS DECIMAL(18,4)) AS precio_unitario,
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
    ) AS canal,

    Codigo_Promocion AS codigo_promocion  
FROM bronze.ventas
WHERE archivo = '{ruta}';


CREATE OR REPLACE TEMP TABLE ventas_chk AS
SELECT *,
    concat_ws(',',
        CASE WHEN fecha IS NULL THEN 'V01' END,
        CASE WHEN id_venta IS NULL OR id_producto IS NULL OR id_tienda IS NULL THEN 'V02' END,
        CASE WHEN cantidad IS NULL OR cantidad <= 0 THEN 'V03' END,
        CASE WHEN precio_unitario IS NULL OR precio_unitario <= 0 THEN 'V04' END,
        CASE WHEN pais_tienda IS NULL THEN 'V05' END,
        CASE WHEN categoria IS NULL THEN 'V06' END,
        CASE WHEN tipo_venta = 'Retail' AND cantidad > 100 THEN 'V07' END,
        CASE WHEN rn > 1 THEN 'V08' END
    ) AS fallas
FROM (
    SELECT *, row_number() OVER (PARTITION BY id_venta ORDER BY linea) AS rn
    FROM ventas_norm
);

