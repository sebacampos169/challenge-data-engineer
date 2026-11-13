import duckdb
con = duckdb.connect('warehouse.duckdb')

ruta_ventas = 'data/raw/historico/Ventas.csv'
ruta_devoluciones = 'data/raw/historico/Devoluciones.csv'
def correr(archivo_sql, ruta):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

correr('sql/bronze/ventas.sql', ruta_ventas)
correr('sql/silver/ventas.sql', ruta_ventas)
correr('sql/silver/cargar_ventas.sql', ruta_ventas)

correr('sql/bronze/devoluciones.sql', ruta_devoluciones)
correr('sql/silver/devoluciones.sql', ruta_devoluciones)
correr('sql/silver/cargar_devoluciones.sql', ruta_devoluciones)

print(con.sql("SELECT * FROM silver.rechazados WHERE fuente = 'devoluciones'"))