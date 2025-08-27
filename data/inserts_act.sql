-- =========================================================
-- INSERTS ADAPTADOS SIN WITH (PostgreSQL) - Versión simplificada
-- =========================================================

-- -------------------------
-- Datos maestros (igual que antes)
-- -------------------------
-- Categorías
INSERT INTO categoria (nombre, elaborado) VALUES
  ('hamburguesa', TRUE),
  ('acompañamiento', TRUE),
  ('bebida', FALSE);

-- Productos
INSERT INTO producto (nombre, descripcion, precio_base, id_categoria) VALUES
  ('McRaulo Cheese', 'Hamburguesa clásica con queso cheddar', 8.99, (SELECT id_categoria FROM categoria WHERE nombre='hamburguesa')),
  ('McRaulo Veggie', 'Hamburguesa vegetariana con proteína de soja', 9.99, (SELECT id_categoria FROM categoria WHERE nombre='hamburguesa')),
  ('McRaulo Pollo', 'Hamburguesa de pollo crujiente', 9.49, (SELECT id_categoria FROM categoria WHERE nombre='hamburguesa')),
  ('Papas fritas', 'Papas fritas crujientes', 3.99, (SELECT id_categoria FROM categoria WHERE nombre='acompañamiento')),
  ('Papas con cheddar', 'Papas fritas con queso cheddar derretido', 5.99, (SELECT id_categoria FROM categoria WHERE nombre='acompañamiento')),
  ('Coca-Cola', 'Refresco de cola 500ml', 2.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida')),
  ('Sprite', 'Refresco de lima-limón 500ml', 2.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida')),
  ('Fanta', 'Refresco de naranja 500ml', 2.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida')),
  ('Limonada', 'Limonada natural 500ml', 3.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida')),
  ('Agua mineral', 'Agua mineral 500ml', 1.50, (SELECT id_categoria FROM categoria WHERE nombre='bebida'));

-- Ingredientes
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

-- Clientes
INSERT INTO cliente (nombre, email, contraseña, dni, telefono, puntos_acumulados) VALUES
  ('Cliente Web 1', 'cliente1@ejemplo.com', 'clavehash1', '10000000', '351-1111111', 0),
  ('Cliente Web 2', 'cliente2@ejemplo.com', 'clavehash2', '10000001', '351-2222222', 0);

-- -------------------------
-- Pedidos + Detalles + Personalizaciones + Compra (sin WITH)
-- -------------------------

-- ========== PEDIDO 1 ==========
-- Fecha: to_timestamp(1716056400) | estado: pendiente | total: 24.97 | método: mercadopago

-- 1) crear estado_pedido
INSERT INTO estado_pedido (nombre_cliente, fecha_ingreso, fecha_salida, id_estado)
VALUES (
  'Cliente Web 1',
  to_timestamp(1716056400),
  NULL,
  (SELECT id_estado FROM estado WHERE nombre_estado = 'pendiente')
);

-- 2) crear pedido (asocia el estado_pedido recién insertado buscando por cliente+fecha+estado)
INSERT INTO pedido (fecha_hora, total, numero_orden, id_estado_pedido, id_cliente, id_cupon)
VALUES (
  to_timestamp(1716056400),
  24.97,
  1001,
  (SELECT id_estado_pedido FROM estado_pedido
     WHERE nombre_cliente = 'Cliente Web 1'
       AND fecha_ingreso = to_timestamp(1716056400)
       AND id_estado = (SELECT id_estado FROM estado WHERE nombre_estado = 'pendiente')
     LIMIT 1),
  (SELECT id_cliente FROM cliente WHERE email = 'cliente1@ejemplo.com'),
  NULL
);

-- 3) crear compra (asocia por numero_orden -> id_pedido)
INSERT INTO compra (fecha_hora, id_cliente, id_pedido, id_metodo_pago)
SELECT
  to_timestamp(1716056400),
  (SELECT id_cliente FROM cliente WHERE email = 'cliente1@ejemplo.com'),
  id_pedido,
  (SELECT id_metodo_pago FROM metodo_pago WHERE nombre='mercadopago')
FROM pedido
WHERE numero_orden = 1001;

-- Detalles del pedido 1
-- 1) McRaulo Cheese personalizada (se inserta detalle y luego sus ingredientes)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  'Sin cebolla, con bacon extra y guacamole extra',
  11.69,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1001),
  (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
);

-- Insertar los ingredientes personalizados para ese detalle (buscamos el último detalle creado para ese pedido+producto)
INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT
  (SELECT id_detalle_pedido FROM detalle_pedido
     WHERE id_pedido = (SELECT id_pedido FROM pedido WHERE numero_orden = 1001)
       AND id_producto = (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
     ORDER BY id_detalle_pedido DESC
     LIMIT 1) AS id_detalle_pedido,
  i.id_ingrediente,
  x.cantidad,
  x.es_extra
FROM (
  VALUES
    ('Cebolla', 0::DECIMAL, FALSE),
    ('Bacon', 2::DECIMAL, TRUE),
    ('Guacamole', 1::DECIMAL, TRUE)
) AS x(nombre, cantidad, es_extra)
JOIN ingrediente i ON i.nombre = x.nombre;

-- 2) Papas fritas
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  NULL,
  3.99,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1001),
  (SELECT id_producto FROM producto WHERE nombre='Papas fritas')
);

-- 3) Coca-Cola (primera)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  NULL,
  2.50,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1001),
  (SELECT id_producto FROM producto WHERE nombre='Coca-Cola')
);

-- 4) Coca-Cola (segunda)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  NULL,
  2.50,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1001),
  (SELECT id_producto FROM producto WHERE nombre='Coca-Cola')
);

-- 5) Agua mineral
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  NULL,
  1.50,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1001),
  (SELECT id_producto FROM producto WHERE nombre='Agua mineral')
);

-- ========== PEDIDO 2 ==========
-- Fecha: to_timestamp(1716142800) | estado: entregado | total: 32.48 | método: efectivo

INSERT INTO estado_pedido (nombre_cliente, fecha_ingreso, fecha_salida, id_estado)
VALUES (
  'Cliente Web 2',
  to_timestamp(1716142800),
  to_timestamp(1716142800) + INTERVAL '40 minutes',
  (SELECT id_estado FROM estado WHERE nombre_estado = 'entregado')
);

INSERT INTO pedido (fecha_hora, total, numero_orden, id_estado_pedido, id_cliente, id_cupon)
VALUES (
  to_timestamp(1716142800),
  32.48,
  1002,
  (SELECT id_estado_pedido FROM estado_pedido
     WHERE nombre_cliente = 'Cliente Web 2'
       AND fecha_ingreso = to_timestamp(1716142800)
       AND id_estado = (SELECT id_estado FROM estado WHERE nombre_estado = 'entregado')
     LIMIT 1),
  (SELECT id_cliente FROM cliente WHERE email = 'cliente2@ejemplo.com'),
  NULL
);

INSERT INTO compra (fecha_hora, id_cliente, id_pedido, id_metodo_pago)
SELECT
  to_timestamp(1716142800),
  (SELECT id_cliente FROM cliente WHERE email = 'cliente2@ejemplo.com'),
  id_pedido,
  (SELECT id_metodo_pago FROM metodo_pago WHERE nombre='efectivo')
FROM pedido
WHERE numero_orden = 1002;

-- Detalles del pedido 2
-- 1) McRaulo Veggie (con queso extra)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  'Con queso extra',
  10.74,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1002),
  (SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie')
);

-- agregar ingrediente (queso extra) para el detalle recién creado
INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT
  (SELECT id_detalle_pedido FROM detalle_pedido
     WHERE id_pedido = (SELECT id_pedido FROM pedido WHERE numero_orden = 1002)
       AND id_producto = (SELECT id_producto FROM producto WHERE nombre='McRaulo Veggie')
     ORDER BY id_detalle_pedido DESC
     LIMIT 1),
  i.id_ingrediente,
  1::DECIMAL,
  TRUE
FROM ingrediente i
WHERE i.nombre = 'Queso cheddar';

-- 2) McRaulo Pollo (sin tomate, bien cocido)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  'Sin tomate, bien cocido',
  9.49,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1002),
  (SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo')
);

-- agregar personalización (quitamos tomate -> cantidad 0)
INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT
  (SELECT id_detalle_pedido FROM detalle_pedido
     WHERE id_pedido = (SELECT id_pedido FROM pedido WHERE numero_orden = 1002)
       AND id_producto = (SELECT id_producto FROM producto WHERE nombre='McRaulo Pollo')
     ORDER BY id_detalle_pedido DESC
     LIMIT 1),
  i.id_ingrediente,
  0::DECIMAL,
  FALSE
FROM ingrediente i
WHERE i.nombre = 'Tomate';

-- 3) Papas con cheddar
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  NULL,
  5.99,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1002),
  (SELECT id_producto FROM producto WHERE nombre='Papas con cheddar')
);

-- 4) Limonada (con poco hielo)
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  'Con poco hielo',
  3.50,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1002),
  (SELECT id_producto FROM producto WHERE nombre='Limonada')
);

-- ========== PEDIDO 3 ==========
-- Fecha: to_timestamp(1716229200) | estado: en_preparacion | total: 45.96 | método: tarjeta

INSERT INTO estado_pedido (nombre_cliente, fecha_ingreso, fecha_salida, id_estado)
VALUES (
  'Cliente Web 1',
  to_timestamp(1716229200),
  NULL,
  (SELECT id_estado FROM estado WHERE nombre_estado = 'en_preparacion')
);

INSERT INTO pedido (fecha_hora, total, numero_orden, id_estado_pedido, id_cliente, id_cupon)
VALUES (
  to_timestamp(1716229200),
  45.96,
  1003,
  (SELECT id_estado_pedido FROM estado_pedido
     WHERE nombre_cliente = 'Cliente Web 1'
       AND fecha_ingreso = to_timestamp(1716229200)
       AND id_estado = (SELECT id_estado FROM estado WHERE nombre_estado = 'en_preparacion')
     LIMIT 1),
  (SELECT id_cliente FROM cliente WHERE email = 'cliente1@ejemplo.com'),
  NULL
);

INSERT INTO compra (fecha_hora, id_cliente, id_pedido, id_metodo_pago)
SELECT
  to_timestamp(1716229200),
  (SELECT id_cliente FROM cliente WHERE email = 'cliente1@ejemplo.com'),
  id_pedido,
  (SELECT id_metodo_pago FROM metodo_pago WHERE nombre='tarjeta')
FROM pedido
WHERE numero_orden = 1003;

-- Detalles del pedido 3 (3 McRaulo Cheese)

-- 1) Normal, sin modificaciones
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  'Normal, sin modificaciones',
  8.99,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1003),
  (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
);

-- 2) Sin lechuga, con bacon extra
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  'Sin lechuga, con bacon extra',
  10.49,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1003),
  (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
);

INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT
  (SELECT id_detalle_pedido FROM detalle_pedido
     WHERE id_pedido = (SELECT id_pedido FROM pedido WHERE numero_orden = 1003)
       AND id_producto = (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
     ORDER BY id_detalle_pedido DESC
     LIMIT 1),
  i.id_ingrediente,
  x.cantidad,
  x.es_extra
FROM (
  VALUES
    ('Lechuga', 0::DECIMAL, FALSE),
    ('Bacon', 2::DECIMAL, TRUE)
) AS x(nombre, cantidad, es_extra)
JOIN ingrediente i ON i.nombre = x.nombre;

-- 3) Sin cebolla, sin tomate, doble queso, con guacamole
INSERT INTO detalle_pedido (notas, subtotal, id_pedido, id_producto)
VALUES (
  'Sin cebolla, sin tomate, doble queso, con guacamole',
  11.49,
  (SELECT id_pedido FROM pedido WHERE numero_orden = 1003),
  (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
);

INSERT INTO detalle_pedido_ingrediente (id_detalle_pedido, id_ingrediente, cantidad, es_extra)
SELECT
  (SELECT id_detalle_pedido FROM detalle_pedido
     WHERE id_pedido = (SELECT id_pedido FROM pedido WHERE numero_orden = 1003)
       AND id_producto = (SELECT id_producto FROM producto WHERE nombre='McRaulo Cheese')
     ORDER BY id_detalle_pedido DESC
     LIMIT 1),
  i.id_ingrediente,
  x.cantidad,
  x.es_extra
FROM (
  VALUES
    ('Cebolla', 0::DECIMAL, FALSE),
    ('Tomate', 0::DECIMAL, FALSE),
    ('Queso cheddar', 1::DECIMAL, TRUE),
    ('Guacamole', 1::DECIMAL, TRUE)
) AS x(nombre, cantidad, es_extra)
JOIN ingrediente i ON i.nombre = x.nombre;

-- FIN DEL SCRIPT
