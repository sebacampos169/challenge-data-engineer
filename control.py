import duckdb
con = duckdb.connect('warehouse.duckdb', read_only=True)

sql = open('queries_control.sql', encoding='utf-8').read()
for consulta in sql.split(';'):
    if consulta.strip():
        print(consulta.strip().split('\n')[0])   # imprime el comentario "-- Qx"
        con.sql(consulta).show(max_rows=50)
