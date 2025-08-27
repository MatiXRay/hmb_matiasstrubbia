// index.js
import express from 'express';
import dotenv from 'dotenv';
import sql, { testConnection } from './db.js';
import endpointss from './endpoints.js';
// Cargar variables de entorno
dotenv.config();

// Crear aplicación Express
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware para parsear JSON
app.use(express.json());

// Verificar que el servidor está funcionando
app.get('/', (req, res) => {
  res.json({ status: 'OK', message: 'API McRaulo - servidor en funcionamiento' });
});

// 1. Obtener todos los pedidos
app.get('/api/pedidos', async (req, res) => {
  try {
    const pedidos = await sql`
      SELECT p.*, ep.id_estado_pedido, e.nombre_estado AS estado FROM pedido p
LEFT JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
LEFT JOIN estado e ON ep.id_estado = e.id_estado
      ORDER BY fecha_hora DESC;
    `;

    res.json({
      status: 'OK',
      data: pedidos
    });
  } catch (error) {
    console.error('Error al obtener pedidos:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al obtener pedidos', error: error.message });
  }
});

// 2. Obtener detalle de un pedido específico
app.get('/api/pedidos/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const pedido = await sql`
      SELECT p.*, ep.id_estado_pedido, e.nombre_estado AS estado FROM pedido p
LEFT JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
LEFT JOIN estado e ON ep.id_estado = e.id_estado
      WHERE p.id_pedido = ${id};
    `;

    if (pedido.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: `No se encontró el pedido con ID ${id}` });
    }

    // Obtener los productos del pedido con sus detalles
    const productos = await sql`
      SELECT dp.*, p.nombre, p.descripcion, c.nombre
      FROM detalle_pedido dp
      JOIN producto p ON dp.id_producto = p.id_producto
 LEFT JOIN categoria c ON p.id_categoria = c.id_categoria
      WHERE dp.id_pedido = ${id};
    `;

    // Para cada producto, obtener los ingredientes personalizados
    const productosConIngredientes = await Promise.all(
      productos.map(async (producto) => {
        const ingredientes = await sql`
          SELECT ppi.*, i.nombre
          FROM detalle_pedido_ingrediente ppi
          JOIN ingrediente i ON ppi.id_ingrediente = i.id_ingrediente
          WHERE ppi.id_detalle_pedido = ${producto.id_detalle_pedido};
        `;

        return {
          ...producto,
          ingredientes_personalizados: ingredientes
        };
      })
    );

    res.json({
      status: 'OK',
      data: {
        ...pedido[0],
        productos: productosConIngredientes
      }
    });
  } catch (error) {
    console.error(`Error al obtener detalle del pedido ${id}:`, error);
    res.status(500).json({
      status: 'ERROR',
      message: `Error al obtener detalle del pedido ${id}`,
      error: error.message
    });
  }
});

// 3. Crear un nuevo pedido 
app.post('/api/pedidos', async (req, res) => {
  const { productos, metodo_pago } = req.body;

  // Validaciones básicas
  if (!productos || !Array.isArray(productos) || productos.length === 0) {
    return res.status(400).json({
      status: 'ERROR',
      message: 'Debe incluir al menos un producto en el pedido'
    });
  }

  if (!metodo_pago) {
    return res.status(400).json({
      status: 'ERROR',
      message: 'Debe especificar el método de pago'
    });
  }

  // Usar transacción para garantizar la integridad
  try {
    return await sql.begin(async (sql) => {
      let total = 0;

      // Calcular subtotales por cada producto individual
      for (const producto of productos) {
        // Verificar que el producto existe
        const productoInfo = await sql`
          SELECT * FROM producto 
          WHERE id_producto = ${producto.id_producto} 
          ;
        `;

        if (productoInfo.length === 0) {
          throw new Error(`El producto con ID ${producto.id_producto} no existe`);
        }

        // Calcular subtotal del producto (precio base + extras si vienen)
        // Calcular subtotal del producto (precio base + extras si vienen)
        // 👇 Convertimos a número explícitamente
        let subtotal = parseFloat(productoInfo[0].precio_base || productoInfo[0].precio || 0);

        // Si vienen ingredientes personalizados, sumar sus costos si son extras
        if (producto.ingredientes_personalizados && producto.ingredientes_personalizados.length > 0) {
          for (const ingr of producto.ingredientes_personalizados) {
            const ingrInfo = await sql`
      SELECT precio FROM ingrediente WHERE id_ingrediente = ${ingr.id_ingrediente};
    `;
            if (ingrInfo.length > 0 && ingr.es_extra) {
              subtotal += parseFloat(ingrInfo[0].precio || 0) * (ingr.cantidad || 1);
            }
          }
        }

        // Actualizar subtotal del producto
        producto.subtotal = parseFloat(subtotal);
        total += producto.subtotal;

      }

      // Crear nuevo estado_pedido (pendiente) y obtener su id
      const estadoRow = (await sql`SELECT id_estado FROM estado WHERE nombre_estado = 'pendiente';`)[0];
      const fechaHora = new Date();

      const estadoPedidoInsert = await sql`
        INSERT INTO estado_pedido (nombre_cliente, fecha_ingreso, fecha_salida, id_estado)
        VALUES (${req.body.nombre_cliente || 'Cliente Web'}, ${fechaHora}, NULL, ${estadoRow ? estadoRow.id_estado : null})
        RETURNING id_estado_pedido;
      `;
      const idEstadoPedido = estadoPedidoInsert[0].id_estado_pedido;

      // Obtener id_cliente si se envió email
      let clienteRow = null;
      if (req.body.email) {
        const cr = await sql`SELECT id_cliente FROM cliente WHERE email = ${req.body.email};`;
        if (cr.length > 0) clienteRow = cr[0];
      }

      // Calcular siguiente numero de orden
      const nextOrdenRow = (await sql`SELECT COALESCE(MAX(numero_orden), 1000) + 1 AS next FROM pedido;`)[0];
      const numeroOrden = nextOrdenRow ? nextOrdenRow.next : 1001;

      // Crear pedido usando id_estado_pedido
      const nuevoPedido = await sql`
        INSERT INTO pedido (fecha_hora, total, numero_orden, id_estado_pedido, id_cliente, id_cupon)
        VALUES (${fechaHora}, ${total}, ${numeroOrden}, ${idEstadoPedido}, ${clienteRow ? clienteRow.id_cliente : null}, NULL)
        RETURNING *;
      `;

      // Registrar la compra con el método de pago indicado
      const metodoRow = (await sql`SELECT id_metodo_pago FROM metodo_pago WHERE nombre = ${metodo_pago};`)[0];
      if (metodoRow) {
        await sql`
          INSERT INTO compra (fecha_hora, id_cliente, id_pedido, id_metodo_pago)
          VALUES (${fechaHora}, ${clienteRow ? clienteRow.id_cliente : null}, ${nuevoPedido[0].id_pedido}, ${metodoRow.id_metodo_pago});
        `;
      }

      // Insertar productos del pedido (cada producto como fila individual)
      const productosCreados = [];
      for (const producto of productos) {
        const nuevoPedidoProducto = await sql`
          INSERT INTO detalle_pedido (id_pedido, id_producto, subtotal, notas)
          VALUES (
            ${nuevoPedido[0].id_pedido}, 
            ${producto.id_producto}, 
            ${producto.subtotal}, 
            ${producto.notas || null}
          )
          RETURNING *;
        `;
        productosCreados.push(nuevoPedidoProducto[0]);

        // Insertar ingredientes personalizados para ese detalle
        if (producto.ingredientes_personalizados && producto.ingredientes_personalizados.length > 0) {
          for (const ingrediente of producto.ingredientes_personalizados) {
            await sql`
              INSERT INTO detalle_pedido_ingrediente (
                id_detalle_pedido, 
                id_ingrediente, 
                cantidad, 
                es_extra
              )
              VALUES (
                ${nuevoPedidoProducto[0].id_detalle_pedido}, 
                ${ingrediente.id_ingrediente}, 
                ${ingrediente.cantidad}, 
                ${ingrediente.es_extra}
              );
            `;
          }
        }
      }

      return res.status(201).json({
        status: 'OK',
        message: 'Pedido creado correctamente',
        data: {
          id_pedido: nuevoPedido[0].id_pedido,
          fecha_hora: nuevoPedido[0].fecha_hora,
          estado: 'pendiente',
          total: nuevoPedido[0].total,
          metodo_pago: metodo_pago,
          productos_creados: productosCreados.length
        }
      });
    });
  } catch (error) {
    console.error('Error al crear el pedido:', error);
    res.status(500).json({
      status: 'ERROR',
      message: 'Error al crear el pedido',
      error: error.message
    });
  }
});

// 4. Actualizar el estado de un pedido
app.patch('/api/pedidos/:id/estado', async (req, res) => {
  const { id } = req.params;
  const { estado } = req.body;

  // Validar estados válidos
  const estadosValidos = ['pendiente', 'en_preparacion', 'listo', 'entregado', 'cancelado'];

  if (!estadosValidos.includes(estado)) {
    return res.status(400).json({
      status: 'ERROR',
      message: `Estado inválido. Debe ser uno de: ${estadosValidos.join(', ')}`
    });
  }

  try {
    // Verificar que el pedido existe
    const pedidoExistente = await sql`
SELECT p.*, ep.id_estado_pedido, e.nombre_estado AS estado FROM pedido p
LEFT JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
LEFT JOIN estado e ON ep.id_estado = e.id_estado
      WHERE p.id_pedido = ${id};
    `;

    if (pedidoExistente.length === 0) {
      return res.status(404).json({
        status: 'ERROR',
        message: `No se encontró el pedido con ID ${id}`
      });
    }

    // Actualizar el estado (creando un nuevo estado_pedido y linkeando el pedido)
    const estadoRow = (await sql`SELECT id_estado FROM estado WHERE nombre_estado = ${estado};`)[0];
    if (!estadoRow) {
      return res.status(400).json({ status: 'ERROR', message: 'Estado desconocido' });
    }

    // Insertar nuevo registro en estado_pedido
    const nuevaEntrada = await sql`
      INSERT INTO estado_pedido (nombre_cliente, fecha_ingreso, fecha_salida, id_estado)
      VALUES (${pedidoExistente[0].nombre_cliente || 'Cliente Web'}, NOW(), NULL, ${estadoRow.id_estado})
      RETURNING id_estado_pedido;
    `;

    // Actualizar el pedido para apuntar al nuevo estado_pedido
    const pedidoActualizado = await sql`
      UPDATE pedido
      SET id_estado_pedido = ${nuevaEntrada[0].id_estado_pedido}
      WHERE id_pedido = ${id}
      RETURNING *;
    `;

    return res.status(200).json({
      status: 'OK',
      message: `Estado del pedido actualizado a "${estado}"`,
      data: pedidoActualizado[0]
    });
  } catch (error) {
    console.error(`Error al actualizar estado del pedido ${id}:`, error);
    res.status(500).json({
      status: 'ERROR',
      message: `Error al actualizar estado del pedido ${id}`,
      error: error.message
    });
  }
});

// 5. Eliminar un pedido
app.delete('/api/pedidos/:id', async (req, res) => {
  const { id } = req.params;

  try {
    // Verificar que el pedido existe
    const pedidoExistente = await sql`
SELECT p.*, ep.id_estado_pedido, e.nombre_estado AS estado FROM pedido p
LEFT JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
LEFT JOIN estado e ON ep.id_estado = e.id_estado
      WHERE p.id_pedido = ${id};
    `;

    if (pedidoExistente.length === 0) {
      return res.status(404).json({
        status: 'ERROR',
        message: `No se encontró el pedido con ID ${id}`
      });
    }

    // Eliminar detalles e ingredientes relacionados
    await sql`
      DELETE FROM detalle_pedido_ingrediente
      WHERE id_detalle_pedido IN (SELECT id_detalle_pedido FROM detalle_pedido WHERE id_pedido = ${id});
    `;

    await sql`
      DELETE FROM detalle_pedido
      WHERE id_pedido = ${id};
    `;

    // Eliminar compra asociada
    await sql`
      DELETE FROM compra
      WHERE id_pedido = ${id};
    `;

    // Eliminar estado_pedido asociado (opcional: si no lo necesitan conservar)
    await sql`
      DELETE FROM estado_pedido
      WHERE id_estado_pedido = ${pedidoExistente[0].id_estado_pedido};
    `;

    // Eliminar el pedido
    await sql`
      DELETE FROM pedido
      WHERE id_pedido = ${id};
    `;

    res.json({ status: 'OK', message: `Pedido ${id} eliminado correctamente` });
  } catch (error) {
    console.error(`Error al eliminar pedido ${id}:`, error);
    res.status(500).json({ status: 'ERROR', message: `Error al eliminar pedido ${id}`, error: error.message });
  }
});

// 6. Obtener resumen del pedido (resumen por producto y detalle)
app.get('/api/pedidos/:id/resumen', async (req, res) => {
  const { id } = req.params;

  try {
    const pedidoExistente = await sql`
SELECT p.*, ep.id_estado_pedido, e.nombre_estado AS estado FROM pedido p
LEFT JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
LEFT JOIN estado e ON ep.id_estado = e.id_estado
      WHERE p.id_pedido = ${id};
    `;

    if (pedidoExistente.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: `No se encontró el pedido ${id}` });
    }

    const resumenProductos = await sql`
      SELECT dp.id_producto, COUNT(dp.id_detalle_pedido) as cantidad_total,
             SUM(dp.subtotal) as subtotal_total
      FROM detalle_pedido dp
      WHERE dp.id_pedido = ${id}
      GROUP BY dp.id_producto;
    `;

    const productosDetallados = await sql`
      SELECT dp.id_detalle_pedido, dp.id_producto, p.nombre, 
             dp.subtotal, dp.notas
      FROM detalle_pedido dp
      JOIN producto p ON dp.id_producto = p.id_producto
      LEFT JOIN detalle_pedido_ingrediente ppi ON dp.id_detalle_pedido = ppi.id_detalle_pedido
      GROUP BY dp.id_detalle_pedido, dp.id_producto, p.nombre, dp.subtotal, dp.notas
      ORDER BY p.nombre, dp.id_detalle_pedido;
    `;

    res.json({
      status: 'OK',
      data: {
        pedido: pedidoExistente[0],
        resumen_por_producto: resumenProductos,
        productos_detallados: productosDetallados
      }
    });
  } catch (error) {
    console.error(`Error al obtener resumen del pedido ${id}:`, error);
    res.status(500).json({ status: 'ERROR', message: `Error al obtener resumen del pedido ${id}`, error: error.message });
  }
});

// 7. Obtener detalle de un producto específico en un pedido
app.get('/api/pedidos/:idPedido/productos/:idPedidoProducto', async (req, res) => {
  const { idPedido, idPedidoProducto } = req.params;

  try {
    // Verificar que el pedido y el producto existen
    const productoEnPedido = await sql`
      SELECT dp.*, p.nombre, p.descripcion, c.nombre
      FROM detalle_pedido dp
      JOIN producto p ON dp.id_producto = p.id_producto
 LEFT JOIN categoria c ON p.id_categoria = c.id_categoria
      WHERE dp.id_pedido = ${idPedido} AND dp.id_detalle_pedido = ${idPedidoProducto};
    `;

    if (productoEnPedido.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: `No se encontró el producto ${idPedidoProducto} en el pedido ${idPedido}` });
    }

    // Obtener ingredientes personalizados del producto
    const ingredientes = await sql`
      SELECT ppi.*, i.nombre
      FROM detalle_pedido_ingrediente ppi
      JOIN ingrediente i ON ppi.id_ingrediente = i.id_ingrediente
      WHERE ppi.id_detalle_pedido = ${idPedidoProducto};
    `;

    res.json({ status: 'OK', data: { producto: productoEnPedido[0], ingredientes } });
  } catch (error) {
    console.error('Error al obtener producto en pedido:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al obtener producto en pedido', error: error.message });
  }
});

// 8. Estadísticas y tops
app.get('/api/pedidos/estadisticas', async (req, res) => {
  try {
    const totalPedidos = await sql`SELECT COUNT(*)::int AS total FROM pedido;`;

    const pedidosPorEstado = await sql`
      SELECT e.nombre_estado AS estado, COUNT(*) as cantidad
      FROM pedido p
      JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
      JOIN estado e ON ep.id_estado = e.id_estado
      GROUP BY e.nombre_estado;
    `;

    const productosMasVendidos = await sql`
      SELECT p.id_producto, p.nombre, COUNT(dp.id_detalle_pedido) as unidades_vendidas
      FROM detalle_pedido dp
      JOIN producto p ON dp.id_producto = p.id_producto
      GROUP BY p.id_producto, p.nombre
      ORDER BY unidades_vendidas DESC
      LIMIT 10;
    `;

    const ingredientesMasSolicitados = await sql`
      SELECT i.id_ingrediente, i.nombre, COUNT(dpi.id_ingrediente) as total
      FROM detalle_pedido_ingrediente dpi
      JOIN ingrediente i ON dpi.id_ingrediente = i.id_ingrediente
      GROUP BY i.id_ingrediente, i.nombre
      ORDER BY total DESC
      LIMIT 10;
    `;

    const ventasPorMetodoPago = await sql`
      SELECT m.nombre AS metodo_pago, COUNT(*) AS cantidad_pedidos, SUM(p.total) AS total_ventas
      FROM compra c
      JOIN metodo_pago m ON c.id_metodo_pago = m.id_metodo_pago
      JOIN pedido p ON c.id_pedido = p.id_pedido
      GROUP BY m.nombre;
    `;

    // Nueva estadística: Productos con más personalizaciones
    const productosConMasPersonalizaciones = await sql`
      SELECT p.id_producto, p.nombre, c.nombre,
             COUNT(ppi.id_detalle_pedido) as total_personalizaciones,
             COUNT(DISTINCT dp.id_detalle_pedido) as productos_personalizados
      FROM producto p
      JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
      JOIN detalle_pedido_ingrediente ppi ON dp.id_detalle_pedido = ppi.id_detalle_pedido
 LEFT JOIN categoria c ON p.id_categoria = c.id_categoria
      GROUP BY p.id_producto, p.nombre, c.nombre
      ORDER BY total_personalizaciones DESC
      LIMIT 5;
    `;

    res.json({
      status: 'OK',
      data: {
        total_pedidos: totalPedidos[0].total,
        pedidos_por_estado: pedidosPorEstado,
        productos_mas_vendidos: productosMasVendidos,
        ingredientes_extras_mas_solicitados: ingredientesMasSolicitados,
        ventas_por_metodo_pago: ventasPorMetodoPago,
        productos_con_mas_personalizaciones: productosConMasPersonalizaciones
      }
    });
  } catch (error) {
    console.error('Error al obtener estadísticas de pedidos:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al obtener estadísticas de pedidos', error: error.message });
  }
});

// 9. Agregar productos a un pedido existente (MODIFICADO)
app.post('/api/pedidos/:id/productos', async (req, res) => {
  const { id } = req.params;
  const { productos } = req.body;

  if (!productos || !Array.isArray(productos) || productos.length === 0) {
    return res.status(400).json({ status: 'ERROR', message: 'Debe incluir al menos un producto a agregar' });
  }

  try {
    // Verificar que el pedido existe
    const pedidoExistente = await sql`
SELECT p.*, ep.id_estado_pedido, e.nombre_estado AS estado FROM pedido p
LEFT JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
LEFT JOIN estado e ON ep.id_estado = e.id_estado
      WHERE p.id_pedido = ${id};
    `;

    if (pedidoExistente.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: `No se encontró el pedido ${id}` });
    }

    if (['entregado', 'cancelado'].includes(pedidoExistente[0].estado)) {
      return res.status(400).json({ status: 'ERROR', message: `No se pueden agregar productos a un pedido en estado "${pedidoExistente[0].estado}"` });
    }

    let totalAdicional = 0;
    const productosAgregados = [];

    for (const producto of productos) {
      const prodInfo = await sql`SELECT * FROM producto WHERE id_producto = ${producto.id_producto};`;
      if (prodInfo.length === 0) {
        return res.status(404).json({ status: 'ERROR', message: `Producto ${producto.id_producto} no encontrado` });
      }

      // Calcular subtotal
      const subtotal = producto.subtotal || prodInfo[0].precio_base || prodInfo[0].precio || 0;

      const nuevoPedidoProducto = await sql`
        INSERT INTO detalle_pedido (id_pedido, id_producto, subtotal, notas)
        VALUES (
          ${id}, 
          ${producto.id_producto}, 
          ${subtotal}, 
          ${producto.notas || null}
        )
        RETURNING *;
      `;

      productosAgregados.push(nuevoPedidoProducto[0]);

      // Insertar ingredientes personalizados
      if (producto.ingredientes_personalizados && producto.ingredientes_personalizados.length > 0) {
        for (const ingrediente of producto.ingredientes_personalizados) {
          await sql`
            INSERT INTO detalle_pedido_ingrediente (
              id_detalle_pedido, 
              id_ingrediente, 
              cantidad, 
              es_extra
            )
            VALUES (
              ${nuevoPedidoProducto[0].id_detalle_pedido}, 
              ${ingrediente.id_ingrediente}, 
              ${ingrediente.cantidad}, 
              ${ingrediente.es_extra}
            );
          `;
        }
      }

      totalAdicional += subtotal;
    }

    // Actualizar el total del pedido
    const nuevoTotal = pedidoExistente[0].total + totalAdicional;

    const pedidoActualizado = await sql`
      UPDATE pedido
      SET total = ${nuevoTotal}
      WHERE id_pedido = ${id}
      RETURNING *;
    `;

    res.json({ status: 'OK', data: { pedido: pedidoActualizado[0], productos_agregados: productosAgregados } });
  } catch (error) {
    console.error('Error al agregar productos a pedido:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al agregar productos', error: error.message });
  }
});

// 12. NUEVO ENDPOINT: Eliminar un producto específico de un pedido
app.delete('/api/pedidos/:id/productos/:idProducto', async (req, res) => {
  const { id, idProducto } = req.params;

  try {
    // Verificar que el pedido existe
    const pedidoExistente = await sql`
SELECT p.*, ep.id_estado_pedido, e.nombre_estado AS estado FROM pedido p
LEFT JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
LEFT JOIN estado e ON ep.id_estado = e.id_estado
      WHERE p.id_pedido = ${id};
    `;

    if (pedidoExistente.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: `No se encontró el pedido ${id}` });
    }

    if (['entregado', 'cancelado'].includes(pedidoExistente[0].estado)) {
      return res.status(400).json({ status: 'ERROR', message: `No se pueden eliminar productos de un pedido en estado "${pedidoExistente[0].estado}"` });
    }

    // Obtener subtotal del producto a eliminar
    const detalle = await sql`SELECT * FROM detalle_pedido WHERE id_pedido = ${id} AND id_detalle_pedido = ${idProducto};`;
    if (detalle.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: `No se encontró el producto ${idProducto} en el pedido ${id}` });
    }

    const subtotalEliminado = detalle[0].subtotal;

    // Eliminar ingredientes personalizados relacionados
    await sql`
      DELETE FROM detalle_pedido_ingrediente
      WHERE id_detalle_pedido = ${idProducto};
    `;

    // Eliminar el producto del pedido
    await sql`
      DELETE FROM detalle_pedido
      WHERE id_detalle_pedido = ${idProducto};
    `;

    // Actualizar el total del pedido
    const nuevoTotal = pedidoExistente[0].total - subtotalEliminado;

    const pedidoActualizado = await sql`
      UPDATE pedido
      SET total = ${nuevoTotal}
      WHERE id_pedido = ${id}
      RETURNING *;
    `;

    res.json({ status: 'OK', data: { pedido: pedidoActualizado[0] } });
  } catch (error) {
    console.error(`Error al eliminar producto ${idProducto} del pedido ${id}:`, error);
    res.status(500).json({ status: 'ERROR', message: `Error al eliminar producto ${idProducto}`, error: error.message });
  }
});

// 13. Obtener todos los productos
app.get('/api/productos', async (req, res) => {
  try {
    const productos = await sql`SELECT * FROM producto ORDER BY nombre;`;
    res.json({ status: 'OK', data: productos });
  } catch (error) {
    console.error('Error al obtener productos:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al obtener productos', error: error.message });
  }
});

// 14. Obtener detalle de un producto
app.get('/api/productos/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const producto = await sql`SELECT * FROM producto WHERE id_producto = ${id};`;

    if (producto.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: `No se encontró el producto ${id}` });
    }

    // Obtener ingredientes base del producto
    const ingredientesBase = await sql`
      SELECT pib.cantidad, i.id_ingrediente, i.nombre, i.descripcion, 
             i.precio, i.unidad_medida
      FROM ingrediente_producto_base pib
      JOIN ingrediente i ON pib.id_ingrediente = i.id_ingrediente
      WHERE pib.id_producto = ${id}
      ORDER BY i.nombre;
    `;

    res.json({ status: 'OK', data: { ...producto[0], ingredientes_base: ingredientesBase } });
  } catch (error) {
    console.error(`Error al obtener producto ${id}:`, error);
    res.status(500).json({ status: 'ERROR', message: `Error al obtener producto ${id}`, error: error.message });
  }
});

// 15. Obtener productos por categoría
app.get('/api/productos/categoria/:categoria', async (req, res) => {
  const { categoria } = req.params;
  try {
    const categoriaRow = await sql`SELECT id_categoria FROM categoria WHERE nombre = ${categoria};`;
    if (categoriaRow.length === 0) return res.status(404).json({ status: 'ERROR', message: 'Categoría no encontrada' });

    const productos = await sql`SELECT * FROM producto WHERE id_categoria = ${categoriaRow[0].id_categoria} ORDER BY nombre;`;
    res.json({ status: 'OK', data: productos });
  } catch (error) {
    console.error('Error al obtener productos por categoría:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al obtener productos por categoría', error: error.message });
  }
});

// 16. Obtener todos los ingredientes
app.get('/api/ingredientes', async (req, res) => {
  try {
    const ingredientes = await sql`SELECT * FROM ingrediente ORDER BY nombre;`;
    res.json({ status: 'OK', data: ingredientes });
  } catch (error) {
    console.error('Error al obtener ingredientes:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al obtener ingredientes', error: error.message });
  }
});

// 17. Calcular precio de un producto con extras (se usa en checkout)
app.post('/api/productos/:id/calcular', async (req, res) => {
  const { id } = req.params;
  const { ingredientes_personalizados } = req.body;

  try {
    const producto = await sql`SELECT * FROM producto WHERE id_producto = ${id};`;
    if (producto.length === 0) return res.status(404).json({ status: 'ERROR', message: 'Producto no encontrado' });

    let precioTotal = producto[0].precio_base || producto[0].precio || 0;
    const detallePrecios = [{ concepto: 'Precio base', precio: producto[0].precio_base }];

    // Calcular precios de ingredientes extras
    if (ingredientes_personalizados && ingredientes_personalizados.length > 0) {
      for (const ingrediente of ingredientes_personalizados) {
        if (ingrediente.es_extra) {
          const ingredienteInfo = await sql`
            SELECT * FROM ingrediente
            WHERE id_ingrediente = ${ingrediente.id_ingrediente};
          `;

          if (ingredienteInfo.length > 0) {
            const costoExtra = ingredienteInfo[0].precio * ingrediente.cantidad;
            precioTotal += costoExtra;
            detallePrecios.push({
              concepto: `Extra ${ingredienteInfo[0].nombre} (${ingrediente.cantidad} ${ingredienteInfo[0].unidad_medida})`,
              precio: costoExtra
            });
          }
        }
      }
    }

    res.json({ status: 'OK', data: { producto: producto[0].nombre, precio_total: precioTotal, detalle: detallePrecios } });
  } catch (error) {
    console.error('Error al calcular precio:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al calcular precio', error: error.message });
  }
});

// 18. Obtener ingredientes por id
app.get('/api/ingredientes/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const ingrediente = await sql`SELECT * FROM ingrediente WHERE id_ingrediente = ${id};`;

    if (ingrediente.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: `No se encontró el ingrediente con ID ${id}` });
    }

    res.json({ status: 'OK', data: ingrediente[0] });
  } catch (error) {
    console.error('Error al obtener ingrediente:', error);
    res.status(500).json({ status: 'ERROR', message: 'Error al obtener ingrediente', error: error.message });
  }
});

// 19. Obtener pedidos por estado
app.get('/api/pedidos/estado/:estado', async (req, res) => {
  const { estado } = req.params;
  try {
    const pedidos = await sql`
      SELECT p.*, ep.id_estado_pedido, e.nombre_estado AS estado FROM pedido p
LEFT JOIN estado_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
LEFT JOIN estado e ON ep.id_estado = e.id_estado
      WHERE e.nombre_estado = ${estado}
      ORDER BY fecha_hora DESC;
    `;

    res.json({ status: 'OK', data: pedidos });
  } catch (error) {
    console.error(`Error al obtener pedidos con estado ${estado}:`, error);
    res.status(500).json({ status: 'ERROR', message: `Error al obtener pedidos con estado ${estado}`, error: error.message });
  }
});

// 20. Obtener historial de pedidos de un método de pago específico
app.get('/api/pedidos/metodo-pago/:metodo', async (req, res) => {
  const { metodo } = req.params;

  try {
    const pedidos = await sql`
      SELECT p.*, m.nombre AS metodo_pago FROM compra c
      JOIN metodo_pago m ON c.id_metodo_pago = m.id_metodo_pago
      JOIN pedido p ON c.id_pedido = p.id_pedido
      WHERE m.nombre = ${metodo}
      ORDER BY p.fecha_hora DESC;
    `;

    res.json({ status: 'OK', data: pedidos });
  } catch (error) {
    console.error(`Error al obtener pedidos con método de pago ${metodo}:`, error);
    res.status(500).json({ status: 'ERROR', message: `Error al obtener pedidos con método de pago ${metodo}`, error: error.message });
  }
});

app.listen(PORT, async () => {
  console.log(`🚀 Servidor iniciado en http://localhost:${PORT}`);

  // Verificar la conexión a la base de datos al iniciar
  await testConnection();

  // Cerrar el proceso si no se puede conectar a la base de datos
  process.on('SIGINT', async () => {
    console.log('Cerrando conexiones a la base de datos...');
    await sql.end();
    process.exit(0);
  });
});

export default app;
