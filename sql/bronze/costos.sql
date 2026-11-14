CREATE SCHEMA IF NOT EXISTS bronze;

--Creo tabla bronze de costos
CREATE TABLE IF NOT EXISTS bronze.costos AS
SELECT filename AS archivo, 0::INTEGER AS linea, * 
FROM read_csv('{ruta}', all_varchar=true);

--Elimino lo que esta actualmente y cargo la nueva info
DELETE FROM bronze.costos WHERE archivo = '{ruta}';

INSERT INTO bronze.costos BY NAME --Inserta por nombre de columna y no por posición
SELECT filename AS archivo, ROW_NUMBER() OVER() AS linea,*
FROM read_csv('{ruta}', all_varchar=true);