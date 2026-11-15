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

-- Q3: venta bruta por país en moneda local
SELECT pais, SUM(venta_bruta_local) as venta_bruta_x_pais
FROM gold.fact_ventas
WHERE YEAR(fecha) = 2025
GROUP BY pais;

-- Q4: Ventas en usd, cantidad lineas, cantidad no tienen costo
SELECT sum(v.venta_bruta_usd) AS ventas_usd,
       count(*) AS lineas,
       count(*) FILTER (WHERE c.id_producto IS NULL) AS lineas_sin_costo
FROM gold.fact_ventas v
LEFT JOIN silver.costos c ON c.id_producto=v.id_producto AND c.periodo=strftime(v.fecha, '%Y-%m')
WHERE v.fecha >= '2026-01-01' AND v.fecha < '2026-02-01';

-- Q5: Precio lista smart 55
SELECT precio_lista FROM silver.precios
WHERE id_producto=3 AND vigencia_desde <= DATE '2026-01-20'
ORDER BY vigencia_desde DESC LIMIT 1; 

-- Q6: filas de la tabla de ventas tras correr 2 veces
SELECT count(*) FROM gold.fact_ventas; 

--TEST
SELECT * FROM gold.fact_ventas