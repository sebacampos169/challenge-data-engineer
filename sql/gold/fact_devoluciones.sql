CREATE OR REPLACE TABLE gold.fact_devoluciones AS
SELECT d.id_devolucion, d.fecha, d.id_producto, d.id_cliente, d.id_tienda, d.cantidad_devuelta, d.motivo,
       d.precio_unitario                  AS precio_unitario_usd,
       d.nombre_cliente,
       d.pais,
       d.nombre_producto,
       d.categoria_producto,
       d.ubicacion_tienda,
       p.moneda,
       d.cantidad_devuelta * d.precio_unitario     AS total_devuelto_usd,
       fx.tipo_cambio,
       CAST(d.cantidad_devuelta * d.precio_unitario * fx.tipo_cambio AS DECIMAL(18,4)) AS total_devuelto_local
FROM silver.devoluciones d
JOIN gold.dim_pais p ON p.pais = d.ubicacion_tienda
JOIN silver.tipo_cambio_mensual fx
     ON fx.mes = date_trunc('month', d.fecha)::DATE AND fx.moneda = p.moneda;