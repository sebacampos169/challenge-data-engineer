CREATE SCHEMA IF NOT EXISTS bronze;

--Creo tabla ventas
CREATE TABLE IF NOT EXISTS bronze.ventas AS
SELECT filename AS archivo, 0::BIGINT AS linea, now() AS cargado_en, * EXCLUDE (filename)
FROM read_csv('{ruta}', all_varchar=true, filename=true)
WHERE false;

-- Idempotencia: borra lo que ya se había cargado y vuelve a leer
DELETE FROM bronze.ventas WHERE archivo = '{ruta}';

-- Agrego nueva columna, aparecio en el incremental
ALTER TABLE bronze.ventas ADD COLUMN IF NOT EXISTS Codigo_Promocion VARCHAR;

-- Inserto la nueva info
INSERT INTO bronze.ventas BY NAME
SELECT filename         AS archivo,
 row_number() OVER ()   AS linea, 
 now()                  AS cargado_en,
  * EXCLUDE (filename)
FROM read_csv('{ruta}', all_varchar=true, filename=true);
