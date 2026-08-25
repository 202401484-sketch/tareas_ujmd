-- ==========================================================
-- Stored Procedure: sp_etl_load_dw
-- Archivo: supabase/objects/procedures/sp_etl_load_dw.sql
-- ESTE ARCHIVO SE EDITA DIRECTAMENTE - no crear nuevas versiones
-- ==========================================================

CREATE OR REPLACE PROCEDURE sp_etl_load_dw()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO dw.dim_zona (municipio, departamento)
    SELECT DISTINCT m.nombre, d.nombre
    FROM municipio m
    JOIN departamento d ON m.id_departamento = d.id_departamento
    ON CONFLICT (municipio, departamento) DO NOTHING;

    INSERT INTO dw.dim_cliente (cliente_id, nombre, municipio)
    SELECT c.dui_cliente, c.nombre, m.nombre
    FROM cliente c
    JOIN municipio m ON c.id_municipio = m.id_municipio
    ON CONFLICT (cliente_id) DO UPDATE
        SET nombre = EXCLUDED.nombre,
            municipio = EXCLUDED.municipio;

    INSERT INTO dw.dim_repartidor (repartidor_id, nombre)
    SELECT r.id_repartidor, r.nombre
    FROM repartidor r
    ON CONFLICT (repartidor_id) DO UPDATE
        SET nombre = EXCLUDED.nombre;

    INSERT INTO dw.dim_producto (producto_id, nombre)
    SELECT p.id_producto, p.nombre
    FROM producto p
    ON CONFLICT (producto_id) DO UPDATE
        SET nombre = EXCLUDED.nombre;

    INSERT INTO dw.dim_tiempo (
        fecha_completa, dia, mes, anio, trimestre,
        dia_semana, es_fin_de_semana, hora, turno
    )
    SELECT DISTINCT
        pe.fecha_hora,
        EXTRACT(DAY FROM pe.fecha_hora)::INT,
        EXTRACT(MONTH FROM pe.fecha_hora)::INT,
        EXTRACT(YEAR FROM pe.fecha_hora)::INT,
        EXTRACT(QUARTER FROM pe.fecha_hora)::INT,
        TRIM(TO_CHAR(pe.fecha_hora, 'Day')),
        EXTRACT(DOW FROM pe.fecha_hora) IN (0, 6),
        EXTRACT(HOUR FROM pe.fecha_hora)::INT,
        CASE
            WHEN EXTRACT(HOUR FROM pe.fecha_hora) BETWEEN 6 AND 11 THEN 'Manana'
            WHEN EXTRACT(HOUR FROM pe.fecha_hora) BETWEEN 12 AND 17 THEN 'Tarde'
            WHEN EXTRACT(HOUR FROM pe.fecha_hora) BETWEEN 18 AND 21 THEN 'Noche'
            ELSE 'Madrugada'
        END
    FROM pedido pe
    ON CONFLICT (fecha_completa) DO NOTHING;

    INSERT INTO dw.fact_ventas (
        fecha_id, cliente_id, producto_id, repartidor_id, zona_id,
        id_detalle_origen, cantidad, precio_unitario, monto_total, costo_envio
    )
    SELECT
        dt.fecha_id,
        pe.dui_cliente,
        dp.id_producto,
        pe.id_repartidor,
        dz.zona_id,
        dp.id_detalle,
        dp.cantidad,
        dp.precio_unitario_historico,
        dp.cantidad * dp.precio_unitario_historico,
        pe.costo_envio
    FROM detalle_pedido dp
    JOIN pedido pe   ON dp.id_pedido = pe.id_pedido
    JOIN cliente cl  ON pe.dui_cliente = cl.dui_cliente
    JOIN municipio m ON cl.id_municipio = m.id_municipio
    JOIN departamento d ON m.id_departamento = d.id_departamento
    JOIN dw.dim_tiempo dt ON dt.fecha_completa = pe.fecha_hora
    JOIN dw.dim_zona dz   ON dz.municipio = m.nombre AND dz.departamento = d.nombre
    ON CONFLICT (id_detalle_origen) DO NOTHING;

    RAISE NOTICE 'ETL completado: dw.fact_ventas actualizado';
END;
$$;
