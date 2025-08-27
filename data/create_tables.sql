-- =========================
-- BASE DE DATOS HAMBURGUESERÍA
-- =========================

-- Tabla: metodo_pago
CREATE TABLE metodo_pago (
    id_metodo_pago SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- Tabla: cliente
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    puntos_acumulados INT DEFAULT 0
);

-- Tabla: estado
CREATE TABLE estado (
    id_estado SERIAL PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL
);

-- Tabla: cupon
CREATE TABLE cupon (
    id_cupon SERIAL PRIMARY KEY,
    codigo_cupon VARCHAR(50) NOT NULL UNIQUE,
    id_cliente INT REFERENCES cliente(id_cliente)
);

-- Tabla: estado_pedido
CREATE TABLE estado_pedido (
    id_estado_pedido SERIAL PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    fecha_ingreso TIMESTAMP NOT NULL,
    fecha_salida TIMESTAMP,
    id_estado INT REFERENCES estado(id_estado)
);

-- Tabla: pedido
CREATE TABLE pedido (
    id_pedido SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    numero_orden INT NOT NULL,
    id_estado_pedido INT REFERENCES estado_pedido(id_estado_pedido),
    id_cliente INT REFERENCES cliente(id_cliente),
    id_cupon INT REFERENCES cupon(id_cupon)
);

-- Tabla: compra
CREATE TABLE compra (
    id_compra SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP NOT NULL,
    id_cliente INT REFERENCES cliente(id_cliente),
    id_pedido INT REFERENCES pedido(id_pedido),
    id_metodo_pago INT REFERENCES metodo_pago(id_metodo_pago)
);

-- Tabla: movimiento_puntos
CREATE TABLE movimiento_puntos (
    id_movimiento SERIAL PRIMARY KEY,
    descripcion TEXT NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    tipo_movimiento VARCHAR(50) NOT NULL,
    id_cliente INT REFERENCES cliente(id_cliente),
    id_compra INT REFERENCES compra(id_compra)
);

-- Tabla: categoria
CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    elaborado BOOLEAN NOT NULL
);

-- Tabla: producto
CREATE TABLE producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_base DECIMAL(10, 2) NOT NULL,
    id_categoria INT REFERENCES categoria(id_categoria)
);

-- Tabla: ingrediente
CREATE TABLE ingrediente (
    id_ingrediente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL
);

-- Tabla: ingrediente_producto_base
CREATE TABLE ingrediente_producto_base (
    id_producto INT REFERENCES producto(id_producto),
    id_ingrediente INT REFERENCES ingrediente(id_ingrediente),
    cantidad DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_producto, id_ingrediente)
);

-- Tabla: detalle_pedido
CREATE TABLE detalle_pedido (
    id_detalle_pedido SERIAL PRIMARY KEY,
    notas TEXT,
    subtotal DECIMAL(10, 2) NOT NULL,
    id_pedido INT REFERENCES pedido(id_pedido),
    id_producto INT REFERENCES producto(id_producto)
);

-- Tabla: detalle_pedido_ingrediente
CREATE TABLE detalle_pedido_ingrediente (
    id_detalle_pedido INT REFERENCES detalle_pedido(id_detalle_pedido),
    id_ingrediente INT REFERENCES ingrediente(id_ingrediente),
    cantidad DECIMAL(10, 2) NOT NULL,
    es_extra BOOLEAN NOT NULL,
    PRIMARY KEY (id_detalle_pedido, id_ingrediente)
);

-- Tabla: tipo_contribuyente
CREATE TABLE tipo_contribuyente (
    id_tipo_contribuyente SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);
