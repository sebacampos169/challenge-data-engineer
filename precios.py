import duckdb
con = duckdb.connect('warehouse.duckdb')

ruta = 'data/raw/historico/Precios.csv'

def correr(archivo_sql, ruta):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

correr('sql/bronze/precios.sql', ruta)
correr('sql/silver/precios.sql', ruta)
correr('sql/silver/cargar_precios.sql', ruta)