-- ==========================================================
-- Stored Procedure: sp_registrar_pedido (v2)
-- Descripcion: Registra un pedido con validaciones y nota
-- Archivo: supabase/objects/procedures/sp_registrar_pedido.sql
-- ESTE ARCHIVO SE EDITA DIRECTAMENTE - no crear nuevas versiones
-- ==========================================================

CREATE OR REPLACE PROCEDURE sp_registrar_pedido(
    p_dui_cliente      VARCHAR(10),
    p_id_repartidor    VARCHAR(10),
    p_direccion        TEXT,
    p_detalles         JSONB,
    p_metodo_pago      VARCHAR(50),
    p_sucursal_origen  VARCHAR(150),
    p_nota             TEXT DEFAULT NULL,
    p_costo_envio      NUMERIC(10,2) DEFAULT 0
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_pedido  INT;
    v_detalle    JSONB;
    v_total      NUMERIC(10,2) := 0;
    v_existe     BOOLEAN;
BEGIN
    -- Validar que el cliente existe
    SELECT EXISTS(
        SELECT 1 FROM cliente WHERE dui_cliente = p_dui_cliente
    ) INTO v_existe;

    IF NOT v_existe THEN
        RAISE EXCEPTION 'Cliente con DUI % no existe', p_dui_cliente;
    END IF;

    -- 1. Insertar el pedido principal (id_pedido se genera automaticamente)
    INSERT INTO pedido (
        dui_cliente, id_repartidor, direccion_entrega,
        estado_pedido, nota, costo_envio, metodo_pago, sucursal_origen
    )
    VALUES (
        p_dui_cliente, p_id_repartidor, p_direccion,
        'Pendiente', p_nota, p_costo_envio, p_metodo_pago, p_sucursal_origen
    )
    RETURNING id_pedido INTO v_id_pedido;

    -- 2. Insertar cada linea de detalle
    FOR v_detalle IN SELECT * FROM jsonb_array_elements(p_detalles) LOOP
        INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario_historico)
        VALUES (
            v_id_pedido,
            v_detalle->>'id_producto',
            (v_detalle->>'cantidad')::INT,
            (v_detalle->>'precio')::NUMERIC
        );
        v_total := v_total +
            (v_detalle->>'cantidad')::INT *
            (v_detalle->>'precio')::NUMERIC;
    END LOOP;

    -- 3. Actualizar el total
    UPDATE pedido SET total = v_total WHERE id_pedido = v_id_pedido;

    RAISE NOTICE 'Pedido % registrado. Total: % Nota: %',
        v_id_pedido, v_total, COALESCE(p_nota, 'sin nota');
END;
$$;
