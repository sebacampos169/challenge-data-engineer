import duckdb
con = duckdb.connect('warehouse.duckdb')

#print(con.sql("SHOW ALL TABLES"))
#con.execute("""DROP TABLE IF EXISTS bronze.precios""")
print(con.sql("SELECT * FROM ops.corridas LIMIT 10;" ))

