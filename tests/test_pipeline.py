from conftest import cargar_ventas, escribir_ventas, fila_venta


def contar(con, tabla):
    return con.execute(f"SELECT count(*) FROM {tabla}").fetchone()[0]


def test_normaliza_pais(con, tmp_path):
    """Calidad: las variantes de un mismo pais quedan en un solo valor."""
    ruta = escribir_ventas(tmp_path, "v.csv", [
        fila_venta(1, pais="Brazil"), fila_venta(2, pais=" México"),
        fila_venta(3, pais="ITALIA "), fila_venta(4, pais="Mexico")])
    cargar_ventas(con, ruta)
    paises = {r[0] for r in con.execute("SELECT DISTINCT pais_tienda FROM silver.ventas").fetchall()}
    assert paises == {"Brasil", "México", "Italia"}


def test_rechaza_registros_invalidos(con, tmp_path):
    """Calidad: cantidad <= 0 y Retail con cantidad > 100 se rechazan (no se pierden)."""
    ruta = escribir_ventas(tmp_path, "v.csv", [
        fila_venta(1),                                   # valida
        fila_venta(2, cantidad=0),                       # rechazada
        fila_venta(3, cantidad=2000, tipo="Retail")])    # rechazada
    cargar_ventas(con, ruta)
    assert contar(con, "silver.ventas") == 1
    assert con.execute("SELECT count(*) FROM silver.rechazados WHERE archivo=?", [ruta]).fetchone()[0] == 2


def test_idempotencia(con, tmp_path):
    """Cargar dos veces el mismo archivo no cambia ningun conteo."""
    ruta = escribir_ventas(tmp_path, "v.csv", [fila_venta(1), fila_venta(2), fila_venta(3, cantidad=0)])
    tablas = ("bronze.ventas", "silver.ventas", "silver.rechazados")
    cargar_ventas(con, ruta)
    primera = [contar(con, t) for t in tablas]
    cargar_ventas(con, ruta)
    assert [contar(con, t) for t in tablas] == primera == [3, 2, 1]


def test_incremental_corrige_sin_duplicar(con, tmp_path):
    """Dato tardio: una venta reenviada con otro precio reemplaza a la anterior."""
    historico = escribir_ventas(tmp_path, "hist.csv", [fila_venta(1, precio="100.00")])
    incremental = escribir_ventas(tmp_path, "inc.csv", [fila_venta(1, precio="90.00")])
    cargar_ventas(con, historico)
    cargar_ventas(con, incremental)
    assert contar(con, "silver.ventas") == 1
    assert float(con.execute("SELECT precio_unitario FROM silver.ventas WHERE id_venta=1").fetchone()[0]) == 90.0