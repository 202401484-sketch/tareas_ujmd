-- ==========================================================
-- UJMD - Caso Sivar Express - Modelo 3FN (version consolidada final)
-- Migration: 20260810000000_initial_schema.sql
-- ==========================================================

-- Tabla: DEPARTAMENTO
CREATE TABLE IF NOT EXISTS departamento (
    id_departamento SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla: MUNICIPIO
CREATE TABLE IF NOT EXISTS municipio (
    id_municipio SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_departamento INT NOT NULL,
    CONSTRAINT fk_municipio_departamento FOREIGN KEY (id_departamento)
        REFERENCES departamento(id_departamento)
);

-- Tabla: CLIENTE
CREATE TABLE IF NOT EXISTS cliente (
    dui_cliente VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    direccion_linea1 VARCHAR(200),
    email VARCHAR(255),
    id_municipio INT NOT NULL,
    CONSTRAINT fk_cliente_municipio FOREIGN KEY (id_municipio)
        REFERENCES municipio(id_municipio)
);
COMMENT ON COLUMN cliente.email IS 'Correo electronico de contacto del cliente (opcional)';

-- Tabla: REPARTIDOR
CREATE TABLE IF NOT EXISTS repartidor (
    id_repartidor VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20)
);

-- Tabla: PRODUCTO
CREATE TABLE IF NOT EXISTS producto (
    id_producto VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    precio_actual NUMERIC(10,2) NOT NULL CHECK (precio_actual >= 0)
);

-- Tabla: PEDIDO
CREATE TABLE IF NOT EXISTS pedido (
    id_pedido SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP NOT NULL DEFAULT now(),
    dui_cliente VARCHAR(10) NOT NULL,
    id_repartidor VARCHAR(10),
    costo_envio NUMERIC(10,2) NOT NULL DEFAULT 0,
    metodo_pago VARCHAR(50) NOT NULL,
    estado_pedido VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    sucursal_origen VARCHAR(150) NOT NULL,
    direccion_entrega TEXT,
    total NUMERIC(10,2),
    nota TEXT,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (dui_cliente)
        REFERENCES cliente(dui_cliente),
    CONSTRAINT fk_pedido_repartidor FOREIGN KEY (id_repartidor)
        REFERENCES repartidor(id_repartidor),
    CONSTRAINT pedido_estado_pedido_check CHECK (
        estado_pedido IN ('Pendiente', 'En Camino', 'Entregado', 'Cancelado')
    ),
    CONSTRAINT pedido_metodo_pago_check CHECK (
        metodo_pago IN ('Efectivo', 'Tarjeta de Crédito', 'Tarjeta de Débito', 'Transferencia')
    )
);

-- Tabla: DETALLE_PEDIDO
CREATE TABLE IF NOT EXISTS detalle_pedido (
    id_detalle SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario_historico NUMERIC(10,2) NOT NULL CHECK (precio_unitario_historico >= 0),
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto)
);

-- Seed data con ON CONFLICT DO NOTHING - idempotente y seguro
INSERT INTO departamento (nombre)
VALUES ('San Salvador'), ('La Libertad')
ON CONFLICT (nombre) DO NOTHING;
