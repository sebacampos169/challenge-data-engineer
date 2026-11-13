import duckdb
con = duckdb.connect()
#print(con.sql("SELECT COUNT(*) FROM read_csv('data/raw/historico/Ventas.csv')"))

# print(con.sql("SELECT Ubicación_Cliente, COUNT(*) " \
# "FROM read_csv('data/raw/historico/Ventas.csv') " \
# "GROUP BY Ubicación_Cliente")) #Ventas

# print(con.sql("" \
# "SELECT *, FIRST_VALUE(Precio_Lista) OVER (PARTITION BY ID_Producto ORDER BY Vigencia_Desde DESC) AS Precio_Actual FROM read_csv('data/raw/historico/Precios.csv')")) #Precios

#print(con.sql("SELECT * FROM read_csv('data/raw/historico/Devoluciones.csv') LIMIT 30")) #Devoluciones

print(con.sql("SELECT * FROM read_csv('data/raw/historico/Costos.csv') LIMIT 10")) #Costos

print(con.sql("SELECT * FROM read_csv('data/raw/historico/Objetivos.csv') LIMIT 10")) #Objetivos