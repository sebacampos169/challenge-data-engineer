import duckdb
con = duckdb.connect()

ruta = 'data/raw/historico/Devoluciones.csv'
def correr(archivo_sql, ruta):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

correr('sql/bronze/devoluciones.sql', ruta)
correr('sql/silver/devoluciones.sql', ruta)
correr('sql/silver/cargar_devoluciones.sql', ruta)

print(con.sql("SELECT * FROM silver.rechazados"))