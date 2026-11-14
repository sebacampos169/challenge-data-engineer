import duckdb
con = duckdb.connect('warehouse.duckdb')

#print(con.sql("SHOW ALL TABLES"))
#con.execute("""DROP TABLE IF EXISTS bronze.precios""")
print(con.sql("SELECT * FROM gold.fact_ventas LIMIT 10;" ))


#SELECT count(*) FROM bronze.ventas WHERE archivo LIKE '%incremental%';        -- 3238
#SELECT count(*) FROM silver.rechazados WHERE archivo LIKE '%incremental%'; --0
#SELECT count(*) FROM silver.ventas WHERE fecha >= '2026-01-01'; --3132

# SELECT DISTINCT pais_tienda FROM silver.ventas; OK
# SELECT DISTINCT categoria FROM silver.ventas; OK

#SELECT count(*) FROM silver.ventas; --83427