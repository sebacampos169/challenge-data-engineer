import duckdb
con = duckdb.connect('warehouse.duckdb')

ruta = 'data/raw/historico/Ventas.csv'
def correr(archivo_sql, ruta):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

correr('sql/bronze/ventas.sql', ruta)
correr('sql/silver/ventas.sql', ruta)
correr('sql/silver/cargar_ventas.sql', ruta)

print(con.sql("SELECT registro FROM silver.rechazados"))
#print(con.sql("SELECT count(*) AS silver FROM silver.ventas"))
#print(con.sql("SELECT count(*) AS rechazados FROM silver.rechazados"))

#con.close()