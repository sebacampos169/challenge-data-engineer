import duckdb
con = duckdb.connect('warehouse.duckdb')

ruta = 'data/raw/incremental_2026-01/Devoluciones.csv'
def correr(archivo_sql, ruta):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

correr('sql/bronze/devoluciones.sql', ruta)
correr('sql/silver/devoluciones.sql', ruta)
correr('sql/silver/cargar_devoluciones.sql', ruta)
correr('sql/gold/fact_devoluciones.sql', ruta)
