-- Creación de tablas para un autoservicio de hamburguesas
-- Fechas en formato UTC (segundos desde 1970-01-01 00:00:00)

-- Tabla productos
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_base DECIMAL(10, 2) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    disponible BOOLEAN DEFAULT TRUE
);

-- Tabla ingredientes
CREATE TABLE ingredientes (
    id_ingrediente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    stock INTEGER NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL
);

-- Tabla productos_ingredientes_base
CREATE TABLE productos_ingredientes_base (
    id_producto INTEGER REFERENCES productos(id_producto),
    id_ingrediente INTEGER REFERENCES ingredientes(id_ingrediente),
    cantidad DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_producto, id_ingrediente)
);

-- Tabla pedidos
CREATE TABLE pedidos (
    id_pedido SERIAL PRIMARY KEY,
    fecha_hora BIGINT NOT NULL, -- Formato UTC (segundos desde epoch)
    estado VARCHAR(50) NOT NULL DEFAULT 'pendiente',
    total DECIMAL(10, 2) NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL
);

-- Tabla pedidos_productos (MODIFICADA - sin columna cantidad)
CREATE TABLE pedidos_productos (
    id_pedido_producto SERIAL PRIMARY KEY,
    id_pedido INTEGER REFERENCES pedidos(id_pedido),
    id_producto INTEGER REFERENCES productos(id_producto),
    -- cantidad INTEGER NOT NULL, -- REMOVIDO: cada fila representa una unidad
    subtotal DECIMAL(10, 2) NOT NULL, -- precio final de este producto específico
    notas TEXT -- personalizaciones específicas para este producto individual
);

-- Tabla pedidos_productos_ingredientes (sin cambios)
CREATE TABLE pedidos_productos_ingredientes (
    id_pedido_producto INTEGER REFERENCES pedidos_productos(id_pedido_producto),
    id_ingrediente INTEGER REFERENCES ingredientes(id_ingrediente),
    cantidad DECIMAL(10, 2) NOT NULL,
    es_extra BOOLEAN NOT NULL,
    PRIMARY KEY (id_pedido_producto, id_ingrediente)
);