import duckdb
con = duckdb.connect()

con.sql(open('sql/normalizar_ventas.sql', encoding='utf-8').read())

print(con.sql("SELECT count(*) FROM ventas_norm"))
print(con.sql("SELECT pais_tienda, count(*) FROM ventas_norm GROUP BY 1"))
print(con.sql("SELECT categoria, count(*) FROM ventas_norm GROUP BY 1"))
print(con.sql("SELECT canal, count(*) FROM ventas_norm GROUP BY 1"))
