import duckdb
con = duckdb.connect('warehouse.duckdb')
print(con.sql("SHOW TABLES"))
#print(con.sql("SELECT * FROM ventas_norm LIMIT 5"))