import duckdb
con = duckdb.connect('warehouse.duckdb')

print(con.sql("""
SELECT * FROM bronze.api_tipo_cambio LIMIT 3
"""))
