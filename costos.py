import duckdb
con = duckdb.connect('warehouse.duckdb')

ruta = 'data/raw/historico/Costos.csv'

def correr(archivo_sql, ruta):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

correr('sql/bronze/costos.sql', ruta)
correr('sql/silver/costos.sql', ruta)
correr('sql/silver/cargar_costos.sql', ruta)