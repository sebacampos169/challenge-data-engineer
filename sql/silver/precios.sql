CREATE SCHEMA IF NOT EXISTS silver;

CREATE OR REPLACE TEMP TABLE precios_norm AS
SELECT
archivo,
linea,
TRY_CAST(ID_Producto AS INTEGER)        AS id_producto,
TRY_CAST(Vigencia_Desde AS DATE)        AS vigencia_desde,
TRY_CAST(Precio_Lista AS DECIMAL(18,4)) AS precio_lista
FROM bronze.precios;

CREATE OR REPLACE TEMP TABLE precios_chk AS
WITH numerado AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id_producto, vigencia_desde ORDER BY linea) AS rn
    FROM precios_norm
)

SELECT *,
concat_ws(',',
    CASE WHEN id_producto IS NULL THEN 'ID NULO' END,
    CASE WHEN precio_lista IS NULL OR precio_lista <= 0 THEN 'PRECIO NO VALIDO' END,
    CASE WHEN vigencia_desde IS NULL THEN 'FECHA NO VALIDA' END,
    CASE WHEN rn > 1 THEN 'DUPLICADO' END
    ) AS fallas
FROM numerado
