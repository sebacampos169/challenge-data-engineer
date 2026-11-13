CREATE SCHEMA IF NOT EXISTS silver;
CREATE OR REPLACE TEMP TABLE devoluciones_norm AS
SELECT
archivo,
linea,
TRY_CAST(ID_Devolución AS INTEGER)              AS id_devolucion,
TRY_CAST(ID_Venta AS INTEGER)                   AS id_venta,
try_strptime(trim(Fecha), '%d/%m/%Y'):: DATE    AS fecha, --VIENE EN FORMATO dd/mm/yy AL HACER TRY_CAST genera NULL
TRY_CAST(ID_Producto AS INTEGER)                AS id_producto,
TRY_CAST(ID_Cliente AS INTEGER)                 AS id_cliente,
TRY_CAST(ID_Tienda AS INTEGER)                  AS id_tienda,
TRY_CAST(Cantidad_Devuelta AS INTEGER)          AS cantidad_devuelta,
TRY_CAST(Motivo AS VARCHAR(100))                AS motivo,
TRY_CAST(Precio_Unitario AS DECIMAL(18,4))      AS precio_unitario,
TRY_CAST(Nombre_Cliente AS VARCHAR(100))        AS nombre_cliente,

-- Ubicación cliente
CASE lower(strip_accents(trim(Ubicación_Cliente)))
    WHEN 'mexico' THEN 'México'
    WHEN 'italy' THEN 'Italia' WHEN 'italia' THEN 'Italia'
    WHEN 'brasil' THEN 'Brasil' WHEN 'brazil' THEN 'Brasil'
END AS pais,

-- Ubicación tienda
CASE lower(strip_accents(trim(Ubicación_Tienda)))
    WHEN 'mexico' THEN 'México'
    WHEN 'italy' THEN 'Italia' WHEN 'italia' THEN 'Italia'
    WHEN 'brasil' THEN 'Brasil' WHEN 'brazil' THEN 'Brasil'
END AS ubicacion_tienda,

TRY_CAST(Nombre_Producto AS VARCHAR(100)) AS nombre_producto,

-- Categoría producto
CASE lower(strip_accents(trim(Categoría_Producto)))
    WHEN 'electronica' THEN 'Electrónica'
    WHEN 'ropa' THEN 'Ropa' 
    WHEN 'alimentos' THEN 'Alimentos'
    WHEN 'muebles' THEN 'Muebles'
END AS categoria_producto,

FROM bronze.devoluciones
WHERE archivo = '{ruta}';

CREATE OR REPLACE TEMP TABLE devoluciones_chk AS
SELECT *,
    concat_ws(',',
        CASE WHEN fecha IS NULL THEN 'V01' END,
        CASE WHEN id_venta IS NULL OR id_producto IS NULL OR id_tienda IS NULL THEN 'V02' END,
        CASE WHEN cantidad_devuelta IS NULL OR cantidad_devuelta <= 0 THEN 'V03' END,
        CASE WHEN precio_unitario IS NULL OR precio_unitario <= 0 THEN 'V04' END,
        CASE WHEN ubicacion_tienda IS NULL THEN 'V05' END,
        CASE WHEN categoria_producto IS NULL THEN 'V06' END,
        --CASE WHEN tipo_venta = 'Retail' AND cantidad > 100 THEN 'V07' END,
        CASE WHEN rn > 1 THEN 'V08' END
    ) AS fallas
FROM (
    SELECT *, row_number() OVER (PARTITION BY id_venta ORDER BY linea) AS rn
    FROM devoluciones_norm)