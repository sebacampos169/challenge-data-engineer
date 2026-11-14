import requests
import pandas as pd
import duckdb
con = duckdb.connect('warehouse.duckdb')

url = "https://api.frankfurter.dev/v1/2024-01-01..2026-03-31"
parametros = {
    "base": "USD",
    "symbols": "MXN,BRL,EUR"
}

respuesta = requests.get(url, params=parametros)
data = respuesta.json()

df = pd.DataFrame(data["rates"]).T
df.index.name = "fecha"
df_largo = df.reset_index().melt(id_vars="fecha", var_name="moneda", value_name="tasa")

con.register("api_tipo_cambio", df_largo)               # le muestra el DataFrame a DuckDB
con.execute("""
    DROP TABLE IF EXISTS bronze.api_tipo_cambio""")

con.execute("""
    CREATE SCHEMA IF NOT EXISTS bronze;
    CREATE TABLE IF NOT EXISTS bronze.api_tipo_cambio (
        fecha DATE, 
        moneda VARCHAR, 
        tasa DECIMAL(18,8),
        PRIMARY KEY (fecha, moneda)
    )""")

con.execute("""
    INSERT OR REPLACE INTO bronze.api_tipo_cambio (fecha, moneda, tasa)
    SELECT fecha, moneda, tasa FROM api_tipo_cambio""") #Lee desde el df


con.close()