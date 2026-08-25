# ujmd_workshop (respaldo)

Pipeline de CI/CD para base de datos con GitHub Actions y Supabase.
Copia de respaldo del laboratorio — Arquitectura de Datos en Entornos
Digitales, UJMD.

## Estructura

```
ujmd_workshop/
├── .github/workflows/deploy.yml
├── supabase/
│   ├── migrations/
│   │   ├── 20260810000000_initial_schema.sql   (tablas base: cliente, pedido, detalle_pedido, producto, repartidor, municipio, departamento)
│   │   └── 20260901000000_create_dw_schema.sql (esquema dw: dimensiones + fact_ventas)
│   └── objects/
│       ├── views/resumen_pedidos.sql
│       ├── functions/fn_total_pedido.sql
│       └── procedures/
│           ├── sp_registrar_pedido.sql
│           └── sp_etl_load_dw.sql
└── README.md
```

## Setup rápido (cuenta nueva)

1. Crear repositorio en GitHub (sin README inicial).
2. Crear proyecto nuevo en Supabase.
3. `git init && git remote add origin <tu-repo> && git add -A && git commit -m "init" && git push -u origin master`
4. Agregar los 3 secrets en GitHub (Settings → Secrets and variables → Actions):
   `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF`, `SUPABASE_DB_PASSWORD`.
5. Actions → Deploy to Supabase → Run workflow.
6. En Supabase SQL Editor, poblar algunas filas de `departamento`/`municipio`/
   `cliente`/`producto`/`repartidor` antes de probar `sp_registrar_pedido`
   (las FK lo requieren).
7. Ejecutar `CALL sp_etl_load_dw();` para poblar el Data Warehouse.
