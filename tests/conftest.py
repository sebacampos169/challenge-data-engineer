"""Fixtures y helpers de los tests. Cada test usa una base DuckDB temporal y vacía,
asi no toca warehouse.duckdb."""
from pathlib import Path
import duckdb
import pytest

RAIZ = Path(__file__).resolve().parent.parent

# Columnas del Ventas.csv historico (el incremental agrega Codigo_Promocion al final)
HEADER = ("ID_Venta,ID_Pedido,Fecha,ID_Producto,ID_Cliente,ID_Tienda,Cantidad,Precio_Unitario,"
          "Canal_Venta,Categoría_Venta,Nombre_Cliente,Ubicación_Cliente,Nombre_Tienda,"
          "Ubicación_Tienda,Nombre_Producto,Categoría_Producto,Subcategoría_Producto")


@pytest.fixture
def con(tmp_path):
    c = duckdb.connect(str(tmp_path / "test.duckdb"))
    for esquema in ("bronze", "silver", "gold"):
        c.execute(f"CREATE SCHEMA IF NOT EXISTS {esquema}")
    yield c
    c.close()


def correr(con, sql_relativo, ruta=""):
    """Igual que correr() de run.py: lee el .sql y reemplaza {ruta}."""
    sql = (RAIZ / sql_relativo).read_text(encoding="utf-8").replace("{ruta}", ruta)
    con.execute(sql)


def cargar_ventas(con, ruta):
    for sql in ("sql/bronze/ventas.sql", "sql/silver/ventas.sql", "sql/silver/cargar_ventas.sql"):
        correr(con, sql, ruta)


def fila_venta(id_venta, fecha="2025-03-10", cantidad=1, precio="10.50",
               pais="Brasil", categoria="Ropa", tipo="Retail"):
    return (f"{id_venta},1,{fecha},1,1,1,{cantidad},{precio},Online,{tipo},Cliente Test,"
            f"{pais},Tienda Test,{pais},Producto Test,{categoria},Sub")


def escribir_ventas(tmp_path, nombre, filas):
    ruta = tmp_path / nombre
    ruta.write_text(HEADER + "\n" + "\n".join(filas) + "\n", encoding="utf-8")
    return ruta.as_posix()