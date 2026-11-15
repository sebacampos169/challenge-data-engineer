import duckdb
con = duckdb.connect('warehouse.duckdb')

def correr_api(archivo_sql):
    sql = open(archivo_sql, encoding='utf-8').read()
    con.execute(sql)


correr_api('sql/silver/tipo_cambio.sql')
correr_api('sql/silver/tipo_cambio_mensual.sql')
