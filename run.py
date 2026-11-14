import duckdb
from datetime import datetime
from pathlib import Path

con = duckdb.connect('warehouse.duckdb')
Path('logs').mkdir(exist_ok=True)

CARPETAS = ['data/raw/historico', 'data/raw/incremental_2026-01']   #ruta carpetas
FUENTES = ['precios', 'costos', 'objetivos', 'ventas', 'devoluciones'] #nombre archivos

def correr(archivo_sql, ruta=''):
    sql = open(archivo_sql, encoding='utf-8').read().replace('{ruta}', ruta)
    con.execute(sql)

def alerta(msg):
    print('ALERTA:', msg)
    open('logs/alertas.log', 'a', encoding='utf-8').write(f'{datetime.now()} {msg}\n')

con.execute("CREATE SCHEMA IF NOT EXISTS ops")
con.execute("""CREATE TABLE IF NOT EXISTS ops.corridas (
    inicio TIMESTAMP, fin TIMESTAMP, archivo VARCHAR, estado VARCHAR,
    leidas BIGINT, rechazadas BIGINT, error VARCHAR)""")

for carpeta in CARPETAS:
    for fuente in FUENTES:
        ruta = f'{carpeta}/{fuente.capitalize()}.csv'
        if not Path(ruta).exists():
            continue                                  # si no tengo un archivo ej objetivo incremental continua
        inicio = datetime.now()
        try:
            correr(f'sql/bronze/{fuente}.sql', ruta)
            correr(f'sql/silver/{fuente}.sql', ruta)
            correr(f'sql/silver/cargar_{fuente}.sql', ruta)
            leidas = con.execute(f"SELECT count(*) FROM bronze.{fuente} WHERE archivo=?", [ruta]).fetchone()[0]
            rech = con.execute("SELECT count(*) FROM silver.rechazados WHERE archivo=?", [ruta]).fetchone()[0]
            con.execute("INSERT INTO ops.corridas VALUES (?,?,?,?,?,?,?)",
                        [inicio, datetime.now(), ruta, 'OK', leidas, rech, None])
            if leidas and rech / leidas > 0.20:
                alerta(f'{ruta}: {rech} de {leidas} filas rechazadas')
        except Exception as e:
            con.execute("INSERT INTO ops.corridas VALUES (?,?,?,?,?,?,?)",
                        [inicio, datetime.now(), ruta, 'ERROR', 0, 0, str(e)])
            alerta(f'FALLO {ruta}: {e}')
            raise

correr('sql/gold/fact_ventas.sql')
correr('sql/gold/fact_devoluciones.sql')
print('Pipeline terminado')