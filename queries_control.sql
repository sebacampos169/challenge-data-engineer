-- Q1: ventas brutas 2025 en USD
SELECT sum(venta_bruta_usd) FROM gold.fact_ventas WHERE year(fecha)=2025;

-- Q2: margen bruto por categoria
SELECT categoria, ((SUM(v.venta_bruta_usd) - SUM(c.costo_unitario*v.cantidad)) / SUM(v.venta_bruta_usd))*100 AS margen
FROM gold.fact_ventas v
JOIN silver.costos c
ON v.id_producto = c.id_producto
AND c.periodo = strftime(v.fecha, '%Y-%m')
WHERE YEAR(v.fecha) = 2025
GROUP BY categoria;