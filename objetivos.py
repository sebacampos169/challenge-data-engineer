import duckdb
con = duckdb.connect('warehouse.duckdb')

ruta = 'data/raw/historico/Objetivos.csv'

def correr(archivo_sql, ruta):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

correr('sql/bronze/objetivos.sql', ruta)
correr('sql/silver/objetivos.sql', ruta)
correr('sql/silver/cargar_objetivos.sql', ruta)