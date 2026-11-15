## Cómo correrlo (un solo comando)

python -m venv .venv
.venv\Scripts\activate          # Windows   (Linux/Mac: source .venv/bin/activate)
pip install -r requirements.txt
python run.py

Los CSV deben estar en data/raw/historico/ y data/raw/incremental_2026-01/ (ajustar CARPETAS en run.py si el nombre cambia). El resultado queda en warehouse.duckdb.

## Cómo correr los tests
```bash
python -m pytest -v
```

## Consultas de control
``` bash
python control.py          # ejecuta queries/control.sql (Q1 a Q6)
```

## Arquitectura (medallón)
Capa	Esquema	Contenido
Bronze	bronze	Copia fiel del CSV, todo texto, con archivo, linea
Silver	silver	Datos tipados, normalizados y validados. Rechazos en silver.rechazados con la regla que fallaron
Gold	gold	fact_ventas y fact_devoluciones (USD y moneda local) para BI
Ops	    ops	    ops.corridas: registro de cada carga

## Reglas de calidad
Cada fila inválida se guarda en silver.rechazados (archivo, línea, motivo) y no se pierde. Reglas de ventas: fecha inválida, claves nulas, cantidad ≤ 0, precio ≤ 0, país o categoría inválidos, Retail con cantidad > 100 y ID duplicado dentro del archivo.

## Registro
- ops.corridas: inicio, fin, archivo, estado, filas leidas y rechazadas.

