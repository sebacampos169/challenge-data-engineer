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
        CASE WHEN d.fecha IS NULL THEN 'SIN FECHA' END,
        CASE WHEN d.id_venta IS NULL OR d.id_producto IS NULL OR d.id_tienda IS NULL THEN 'SIN ID' END,
        CASE WHEN d.cantidad_devuelta IS NULL OR d.cantidad_devuelta <= 0 THEN 'CANTIDAD DEVUELTA NULA O NEGATIVA' END,
        CASE WHEN d.precio_unitario IS NULL OR d.precio_unitario <= 0 THEN 'PRECIO NULO O NEGATIVO' END,
        CASE WHEN d.ubicacion_tienda IS NULL THEN 'TIENDA NULA' END,
        CASE WHEN d.categoria_producto IS NULL THEN 'CANTEGORIA NULA' END,
        CASE WHEN d.cantidad_devuelta > v.cantidad THEN 'CANTIDAD DEVUELTA > CANTIDAD VENDIDA' END,
        CASE WHEN d.id_devolucion IS NOT NULL AND v.id_venta IS NULL THEN 'VENTA INEXISTENTE' END
    ) AS fallas
FROM 
    devoluciones_norm d
    LEFT JOIN silver.ventas v
    ON  d.id_venta = v.id_venta