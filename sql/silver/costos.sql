CREATE SCHEMA IF NOT EXISTS silver;

CREATE OR REPLACE TEMP TABLE costos_norm AS
SELECT
archivo,
linea,
Periodo                                     AS periodo,
TRY_CAST(Id_Producto AS INTEGER)            AS id_producto,
TRY_CAST(REPLACE(TRIM(Costo_Unitario), ',', '.') AS DECIMAL(18,4))   AS costo_unitario
FROM bronze.costos;

CREATE OR REPLACE TEMP TABLE costos_chk AS
WITH numerado AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY periodo, id_producto, costo_unitario ORDER BY linea) AS rn
    FROM costos_norm
)

SELECT *,
concat_ws(',',
    CASE WHEN id_producto IS NULL THEN 'ID NULO' END,
    CASE WHEN costo_unitario IS NULL OR costo_unitario <= 0 THEN 'COSTO NO VALIDO' END,
    CASE WHEN periodo IS NULL THEN 'PERIODO NO VALIDO' END,
    CASE WHEN rn > 1 THEN 'DUPLICADO' END
    ) AS fallas
FROM numerado