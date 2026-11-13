CREATE SCHEMA IF NOT EXISTS bronze;

--Creo tabla devoluciones
CREATE TABLE IF NOT EXISTS bronze.devoluciones AS
SELECT filename AS archivo, 0::BIGINT AS linea, now() AS cargado_en, * EXCLUDE (filename)
FROM read_csv('{ruta}', all_varchar=true, filename=true)
WHERE false;

-- Idempotencia: borra lo que ya se había cargado y vuelve a leer
DELETE FROM bronze.devoluciones WHERE archivo = '{ruta}';

-- Inserto la nueva info
INSERT INTO bronze.devoluciones
SELECT filename, row_number() OVER (), now(), * EXCLUDE (filename)
FROM read_csv('{ruta}', all_varchar=true, filename=true);