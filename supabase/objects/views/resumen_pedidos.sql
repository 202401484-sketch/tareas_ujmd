-- supabase/objects/views/resumen_pedidos.sql
-- Edita libremente - se re-aplica en cada despliegue

CREATE OR REPLACE VIEW resumen_pedidos AS
SELECT
    pe.id_pedido,
    cl.nombre AS cliente,
    re.nombre AS repartidor,
    pe.fecha_hora,
    pe.estado_pedido,
    fn_total_pedido(pe.id_pedido) AS total_pedido
FROM pedido pe
JOIN cliente cl ON pe.dui_cliente = cl.dui_cliente
LEFT JOIN repartidor re ON pe.id_repartidor = re.id_repartidor;
