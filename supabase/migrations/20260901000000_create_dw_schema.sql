-- ==========================================================
-- UJMD - Caso Practico: ETL de Sivar Express hacia un DW
-- Migration: 20260901000000_create_dw_schema.sql
-- ==========================================================

CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE IF NOT EXISTS dw.dim_tiempo (
    fecha_id            SERIAL PRIMARY KEY,
    fecha_completa       TIMESTAMP NOT NULL,
    dia                  INT NOT NULL,
    mes                  INT NOT NULL,
    anio                 INT NOT NULL,
    trimestre            INT NOT NULL,
    dia_semana           VARCHAR(15) NOT NULL,
    es_fin_de_semana     BOOLEAN NOT NULL,
    hora                 INT NOT NULL,
    turno                VARCHAR(20) NOT NULL,
    UNIQUE (fecha_completa)
);

CREATE TABLE IF NOT EXISTS dw.dim_zona (
    zona_id      SERIAL PRIMARY KEY,
    municipio    VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    UNIQUE (municipio, departamento)
);

CREATE TABLE IF NOT EXISTS dw.dim_cliente (
    cliente_id   VARCHAR(10) PRIMARY KEY,
    nombre       VARCHAR(150) NOT NULL,
    municipio    VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dw.dim_repartidor (
    repartidor_id VARCHAR(10) PRIMARY KEY,
    nombre        VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_producto (
    producto_id  VARCHAR(20) PRIMARY KEY,
    nombre       VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.fact_ventas (
    venta_id        SERIAL PRIMARY KEY,
    fecha_id        INT NOT NULL,
    cliente_id      VARCHAR(10) NOT NULL,
    producto_id     VARCHAR(20) NOT NULL,
    repartidor_id   VARCHAR(10),
    zona_id         INT,
    id_detalle_origen INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    monto_total     NUMERIC(10,2) NOT NULL,
    costo_envio     NUMERIC(10,2),
    CONSTRAINT fk_fact_tiempo FOREIGN KEY (fecha_id) REFERENCES dw.dim_tiempo(fecha_id),
    CONSTRAINT fk_fact_cliente FOREIGN KEY (cliente_id) REFERENCES dw.dim_cliente(cliente_id),
    CONSTRAINT fk_fact_producto FOREIGN KEY (producto_id) REFERENCES dw.dim_producto(producto_id),
    CONSTRAINT fk_fact_repartidor FOREIGN KEY (repartidor_id) REFERENCES dw.dim_repartidor(repartidor_id),
    CONSTRAINT fk_fact_zona FOREIGN KEY (zona_id) REFERENCES dw.dim_zona(zona_id),
    UNIQUE (id_detalle_origen)
);
