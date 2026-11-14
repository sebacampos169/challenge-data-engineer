CREATE OR REPLACE TABLE silver.tipo_cambio_mensual AS
SELECT date_trunc('month', fecha)::DATE AS mes,
       moneda,
       arg_max(tasa, fecha) AS tipo_cambio,     -- tasa de la fecha más alta del mes
       max(fecha)           AS fecha_cotizacion
FROM silver.tipo_cambio
GROUP BY 1, 2;