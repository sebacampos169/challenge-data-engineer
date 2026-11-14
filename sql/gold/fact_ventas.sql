CREATE SCHEMA IF NOT EXISTS gold;

CREATE OR REPLACE TABLE gold.dim_pais AS
SELECT * FROM (VALUES ('México','MXN'), ('Brasil','BRL'), ('Italia','EUR')) t(pais, moneda);

CREATE OR REPLACE TABLE gold.fact_ventas AS
SELECT v.id_venta, v.fecha, v.id_producto, v.id_tienda, v.cantidad, v.categoria,
       v.precio_unitario                  AS precio_unitario_usd,
       v.tipo_venta, v.canal,
       v.pais_tienda                      AS pais,
       p.moneda,
       v.cantidad * v.precio_unitario     AS venta_bruta_usd,
       fx.tipo_cambio,
       CAST(v.cantidad * v.precio_unitario * fx.tipo_cambio AS DECIMAL(18,4)) AS venta_bruta_local,
       v.codigo_promocion
FROM silver.ventas v
JOIN gold.dim_pais p ON p.pais = v.pais_tienda
JOIN silver.tipo_cambio_mensual fx
     ON fx.mes = date_trunc('month', v.fecha)::DATE AND fx.moneda = p.moneda;