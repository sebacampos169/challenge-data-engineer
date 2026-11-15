import duckdb
con = duckdb.connect('warehouse.duckdb')

ruta = 'data/raw/incremental_2026-01/Ventas.csv'
def correr(archivo_sql, ruta):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

#correr('sql/bronze/ventas.sql', ruta)
#correr('sql/silver/ventas.sql', ruta)
#correr('sql/silver/cargar_ventas.sql', ruta)
correr('sql/gold/fact_ventas.sql',ruta)

