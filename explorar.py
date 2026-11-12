import duckdb
con = duckdb.connect()
#print(con.sql("SELECT COUNT(*) FROM read_csv('data/raw/historico/Ventas.csv')"))

print(con.sql("SELECT * FROM read_csv('data/raw/historico/Ventas.csv') LIMIT 10")) #Ventas

print(con.sql("SELECT * FROM read_csv('data/raw/historico/Precios.csv') LIMIT 10")) #Precios

print(con.sql("SELECT * FROM read_csv('data/raw/historico/Devoluciones.csv') LIMIT 10")) #Devoluciones

print(con.sql("SELECT * FROM read_csv('data/raw/historico/Costos.csv') LIMIT 10")) #Costos

print(con.sql("SELECT * FROM read_csv('data/raw/historico/Objetivos.csv') LIMIT 10")) #Objetivos