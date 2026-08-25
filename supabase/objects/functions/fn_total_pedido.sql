-- supabase/objects/functions/fn_total_pedido.sql
-- Edita libremente - se re-aplica en cada despliegue

CREATE OR REPLACE FUNCTION fn_total_pedido(p_id_pedido INT)
RETURNS NUMERIC AS $$
    SELECT COALESCE(SUM(dp.cantidad * dp.precio_unitario_historico), 0)
    FROM detalle_pedido dp
    WHERE dp.id_pedido = p_id_pedido;
$$ LANGUAGE SQL STABLE;
