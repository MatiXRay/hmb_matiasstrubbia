
-- =========================================================
-- INSERTS ADAPTADOS AL ESQUEMA NUEVO (PostgreSQL)
-- =========================================================
-- Este script convierte tus datos de prueba originales
-- (productos/ingredientes/pedidos/pedidos_productos...) al
-- esquema nuevo: producto, ingrediente, ingrediente_producto_base,
-- pedido, detalle_pedido, detalle_pedido_ingrediente, etc.
-- Ejecutar con la base recién creada y vacía.

-- -------------------------
-- Datos maestros
-- -------------------------
-- Categorías
INSERT INTO categoria (nombre, elaborado) VALUES
('hamburguesa', TRUE),
('extra', TRUE),
('bebida', FALSE);

-- Productos
INSERT INTO producto (nombre, descripcion, precio_base, id_categoria) VALUES
('McRaulo Cheese', 'Hamburguesa clásica con queso cheddar', 8.99, (SELECT id_categoria FROM categoria WHERE nombre='hamburguesa')),
('McRaulo Veggie', 'Hamburguesa vegetariana con proteína de soja', 9.99, (SELECT id_categoria FROM categoria WHERE nombre='hamburguesa')),
('McRaulo Pollo', 'Hamburguesa de pollo crujiente', 9.49, (SELECT id_categoria FROM categoria WHERE nombre='hamburguesa')),
('Papas fritas', 'Papas fritas crujientes', 3.99, (SELECT id_categoria FROM categoria WHERE nombre='extra')),
('Papas con cheddar', 'Papas fritas con queso cheddar derretido', 5.99, (SELECT id_categoria FROM categoria WHERE nombre='extra')),
('Coca-Cola', 'Refresco de cola 500ml', 2.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida')),
('Sprite', 'Refresco de lima-limón 500ml', 2.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida')),
('Fanta', 'Refresco de naranja 500ml', 2.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida')),
('Limonada', 'Limonada natural 500ml', 3.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida')),
('Agua mineral', 'Agua mineral 500ml', 1.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida'));

-- Ingredientes (sin columna stock en el modelo nuevo)
INSERT INTO ingrediente (nombre, descripcion, precio, unidad_medida) VALUES
('Pan de hamburguesa', 'Pan brioche para hamburguesa', 0.50, 'unidad'),
('Carne de res', 'Medallón de carne de res 150g', 2.50, 'unidad'),
('Pollo crispy', 'Medallón de pollo rebozado 120g', 2.00, 'unidad'),
('Medallón veggie', 'Medallón de proteína vegetal 120g', 2.50, 'unidad'),
('Queso cheddar', 'Feta de queso cheddar', 0.75, 'unidad'),
('Lechuga', 'Lechuga fresca', 0.30, 'g'),
('Tomate', 'Rodaja de tomate', 0.40, 'g'),
('Cebolla', 'Cebolla en rodajas', 0.30, 'g'),
('Pepinillos', 'Pepinillos en rodajas', 0.50, 'g'),
('Bacon', 'Tiras de bacon crujiente', 1.50, 'g'),
('Salsa especial', 'Salsa especial de la casa', 0.50, 'ml'),
('Ketchup', 'Salsa de tomate', 0.20, 'ml'),
('Mostaza', 'Mostaza amarilla', 0.20, 'ml'),
('Mayonesa', 'Mayonesa casera', 0.30, 'ml'),
('Guacamole', 'Guacamole fresco', 1.20, 'g');

-- Ingredientes base por producto
-- McRaulo Cheese
INSERT INTO ingrediente_producto_base (id_producto, id_ingrediente, cantidad) VALUES
((SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Pan de hamburguesa'), 1),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Carne de res'), 1),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Queso cheddar'), 2),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Lechuga'), 20),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Tomate'), 30),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Cebolla'), 15),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Salsa especial'), 15),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Ketchup'), 10);

-- McRaulo Veggie
INSERT INTO ingrediente_producto_base (id_producto, id_ingrediente, cantidad) VALUES
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Pan de hamburguesa'), 1),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Medallón veggie'), 1),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Queso cheddar'), 1),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Lechuga'), 25),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Tomate'), 30),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Cebolla'), 15),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Pepinillos'), 15),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Salsa especial'), 15),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Mayonesa'), 10);

-- McRaulo Pollo
INSERT INTO ingrediente_producto_base (id_producto, id_ingrediente, cantidad) VALUES
((SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Pan de hamburguesa'), 1),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Pollo crispy'), 1),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Queso cheddar'), 1),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Lechuga'), 20),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Tomate'), 30),
((SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo'), (SELECT id_ingrediente FROM ingrediente WHERE nombre='Mayonesa'), 15);

-- Estados y medios de pago
INSERT INTO estado (nombre_estado) VALUES ('pendiente'), ('en_preparacion'), ('entregado');

INSERT INTO metodo_pago (nombre) VALUES ('mercadopago'), ('efectivo'), ('tarjeta');

-- Clientes (mínimos para asociar compras/pedidos)
INSERT INTO cliente (nombre, email, contraseña, dni, telefono, puntos_acumulados) VALUES
('Cliente Web 1', 'cliente1@ejemplo.com', 'clavehash1', '10000000', '351-1111111', 0),
('Cliente Web 2', 'cliente2@ejemplo.com', 'clavehash2', '10000001', '351-2222222', 0);

-- -------------------------
-- Pedidos + Detalles + Personalizaciones + Compra (método de pago)
-- -------------------------

-- ========== PEDIDO 1 ==========
-- Fecha: to_timestamp(1716056400) | estado: pendiente | total: 24.97 | método: mercadopago
WITH ep AS (
    INSERT INTO estado_pedido (nombre_cliente, fecha_ingreso, fecha_salida, id_estado)
    VALUES (
        'Cliente Web 1',
        to_timestamp(1716056400),
        NULL,
        (SELECT id_estado FROM estado WHERE nombre_estado = 'pendiente')
    )
    RETURNING id_estado_pedido
), p AS (
    INSERT INTO pedido (fecha_hora, total, numero_orden, id_estado_pedido, id_cliente, id_cupon)
    SELECT to_timestamp(1716056400), 24.97, 1001, ep.id_estado_pedido,
           (SELECT id_cliente FROM cliente WHERE email='cliente1@ejemplo.com'), NULL
    FROM ep
    RETURNING id_pedido
)
INSERT INTO compra (fecha_hora, id_cliente, id_pedido, id_metodo_pago)
SELECT to_timestamp(1716056400),
       (SELECT id_cliente FROM cliente WHERE email='cliente1@ejemplo.com'),
       p.id_pedido,
       (SELECT id_metodo_pago FROM metodo_pago WHERE nombre='mercadopago')
FROM p;

-- Detalles del pedido 1
WITH p AS (SELECT id_pedido FROM pedido WHERE numero_orden = 1001)
-- 1) McRaulo Cheese personalizada
, dp1 AS (
  INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
  SELECT 'Sin cebolla, con bacon extra y guacamole extra', 11.69, p.id_pedido,
         (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
  FROM p
  RETURNING id_detalle_pedido
)
INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT dp1.id_detalle_pedido, i.id_ingrediente, x.cantidad, x.es_extra
FROM dp1
JOIN (
  VALUES
    ('Cebolla', 0::DECIMAL, FALSE),
    ('Bacon', 2::DECIMAL, TRUE),
    ('Guacamole', 1::DECIMAL, TRUE)
) AS x(nombre, cantidad, es_extra)
JOIN ingrediente i ON i.nombre = x.nombre;

-- 2) Papas fritas
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
SELECT NULL, 3.99, p.id_pedido, (SELECT id_producto FROM producto WHERE nombre='Papas fritas')
FROM (SELECT id_pedido FROM pedido WHERE numero_orden = 1001) p;

-- 3) Coca-Cola (primera)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
SELECT NULL, 2.50, p.id_pedido, (SELECT id_producto FROM producto WHERE nombre='Coca-Cola')
FROM (SELECT id_pedido FROM pedido WHERE numero_orden = 1001) p;

-- 4) Coca-Cola (segunda)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
SELECT NULL, 2.50, p.id_pedido, (SELECT id_producto FROM producto WHERE nombre='Coca-Cola')
FROM (SELECT id_pedido FROM pedido WHERE numero_orden = 1001) p;

-- 5) Agua mineral
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
SELECT NULL, 1.50, p.id_pedido, (SELECT id_producto FROM producto WHERE nombre='Agua mineral')
FROM (SELECT id_pedido FROM pedido WHERE numero_orden = 1001) p;

-- ========== PEDIDO 2 ==========
-- Fecha: to_timestamp(1716142800) | estado: entregado | total: 32.48 | método: efectivo
WITH ep AS (
    INSERT INTO estado_pedido (nombre_cliente, fecha_ingreso, fecha_salida, id_estado)
    VALUES (
        'Cliente Web 2',
        to_timestamp(1716142800),
        to_timestamp(1716142800) + INTERVAL '40 minutes',
        (SELECT id_estado FROM estado WHERE nombre_estado = 'entregado')
    )
    RETURNING id_estado_pedido
), p AS (
    INSERT INTO pedido (fecha_hora, total, numero_orden, id_estado_pedido, id_cliente, id_cupon)
    SELECT to_timestamp(1716142800), 32.48, 1002, ep.id_estado_pedido,
           (SELECT id_cliente FROM cliente WHERE email='cliente2@ejemplo.com'), NULL
    FROM ep
    RETURNING id_pedido
)
INSERT INTO compra (fecha_hora, id_cliente, id_pedido, id_metodo_pago)
SELECT to_timestamp(1716142800),
       (SELECT id_cliente FROM cliente WHERE email='cliente2@ejemplo.com'),
       p.id_pedido,
       (SELECT id_metodo_pago FROM metodo_pago WHERE nombre='efectivo')
FROM p;

-- Detalles del pedido 2
WITH p AS (SELECT id_pedido FROM pedido WHERE numero_orden = 1002)
-- 1) McRaulo Veggie (con queso extra)
, dp1 AS (
  INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
  SELECT 'Con queso extra', 10.74, p.id_pedido,
         (SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie')
  FROM p
  RETURNING id_detalle_pedido
)
INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT dp1.id_detalle_pedido, i.id_ingrediente, 1::DECIMAL, TRUE
FROM dp1
JOIN ingrediente i ON i.nombre = 'Queso cheddar';

-- 2) McRaulo Pollo (sin tomate, bien cocido)
WITH p AS (SELECT id_pedido FROM pedido WHERE numero_orden = 1002)
, dp2 AS (
  INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
  SELECT 'Sin tomate, bien cocido', 9.49, p.id_pedido,
         (SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo')
  FROM p
  RETURNING id_detalle_pedido
)
INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT dp2.id_detalle_pedido, i.id_ingrediente, 0::DECIMAL, FALSE
FROM dp2
JOIN ingrediente i ON i.nombre = 'Tomate';

-- 3) Papas con cheddar
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
SELECT NULL, 5.99, p.id_pedido, (SELECT id_producto FROM producto WHERE nombre='Papas con cheddar')
FROM (SELECT id_pedido FROM pedido WHERE numero_orden = 1002) p;

-- 4) Limonada (con poco hielo)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
SELECT 'Con poco hielo', 3.50, p.id_pedido, (SELECT id_producto FROM producto WHERE nombre='Limonada')
FROM (SELECT id_pedido FROM pedido WHERE numero_orden = 1002) p;

-- ========== PEDIDO 3 ==========
-- Fecha: to_timestamp(1716229200) | estado: en_preparacion | total: 45.96 | método: tarjeta
WITH ep AS (
    INSERT INTO estado_pedido (nombre_cliente, fecha_ingreso, fecha_salida, id_estado)
    VALUES (
        'Cliente Web 1',
        to_timestamp(1716229200),
        NULL,
        (SELECT id_estado FROM estado WHERE nombre_estado = 'en_preparacion')
    )
    RETURNING id_estado_pedido
), p AS (
    INSERT INTO pedido (fecha_hora, total, numero_orden, id_estado_pedido, id_cliente, id_cupon)
    SELECT to_timestamp(1716229200), 45.96, 1003, ep.id_estado_pedido,
           (SELECT id_cliente FROM cliente WHERE email='cliente1@ejemplo.com'), NULL
    FROM ep
    RETURNING id_pedido
)
INSERT INTO compra (fecha_hora, id_cliente, id_pedido, id_metodo_pago)
SELECT to_timestamp(1716229200),
       (SELECT id_cliente FROM cliente WHERE email='cliente1@ejemplo.com'),
       p.id_pedido,
       (SELECT id_metodo_pago FROM metodo_pago WHERE nombre='tarjeta')
FROM p;

-- Detalles del pedido 3 (3 McRaulo Cheese)

-- 1) Normal, sin modificaciones
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
SELECT 'Normal, sin modificaciones', 8.99, p.id_pedido, (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
FROM (SELECT id_pedido FROM pedido WHERE numero_orden = 1003) p;

-- 2) Sin lechuga, con bacon extra
WITH p AS (SELECT id_pedido FROM pedido WHERE numero_orden = 1003)
, dp2 AS (
  INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
  SELECT 'Sin lechuga, con bacon extra', 10.49, p.id_pedido,
         (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
  FROM p
  RETURNING id_detalle_pedido
)
INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT dp2.id_detalle_pedido, i.id_ingrediente, x.cantidad, x.es_extra
FROM dp2
JOIN (
  VALUES
    ('Lechuga', 0::DECIMAL, FALSE),
    ('Bacon', 2::DECIMAL, TRUE)
) AS x(nombre, cantidad, es_extra)
JOIN ingrediente i ON i.nombre = x.nombre;

-- 3) Sin cebolla, sin tomate, doble queso, con guacamole
WITH p AS (SELECT id_pedido FROM pedido WHERE numero_orden = 1003)
, dp3 AS (
  INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
  SELECT 'Sin cebolla, sin tomate, doble queso, con guacamole', 11.49, p.id_pedido,
         (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
  FROM p
  RETURNING id_detalle_pedido
)
INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT dp3.id_detalle_pedido, i.id_ingrediente, x.cantidad, x.es_extra
FROM dp3
JOIN (
  VALUES
    ('Cebolla', 0::DECIMAL, FALSE),
    ('Tomate', 0::DECIMAL, FALSE),
    ('Queso cheddar', 1::DECIMAL, TRUE),
    ('Guacamole', 1::DECIMAL, TRUE)
) AS x(nombre, cantidad, es_extra)
JOIN ingrediente i ON i.nombre = x.nombre;
