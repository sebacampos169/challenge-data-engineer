CREATE SCHEMA IF NOT EXISTS silver;

CREATE OR REPLACE TEMP TABLE objetivos_norm AS
SELECT
archivo,
linea,
Periodo                                     AS periodo,
TRY_CAST(ID_Tienda AS INTEGER)            AS id_tienda,
TRY_CAST(REPLACE(TRIM(Objetivo_Ventas), ',', '.') AS DECIMAL(18,4))   AS objetivo_ventas
FROM bronze.objetivos;

CREATE OR REPLACE TEMP TABLE objetivos_chk AS
WITH numerado AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY periodo, id_tienda ORDER BY linea) AS rn
    FROM objetivos_norm
)

SELECT *,
concat_ws(',',
    CASE WHEN id_tienda IS NULL THEN 'ID NULO' END,
    CASE WHEN objetivo_ventas IS NULL OR objetivo_ventas <= 0 THEN 'OBJETIVO NO VALIDO' END,
    CASE WHEN periodo IS NULL THEN 'PERIODO NO VALIDO' END,
    CASE WHEN rn > 1 THEN 'DUPLICADO' END
    ) AS fallas
FROM numerado