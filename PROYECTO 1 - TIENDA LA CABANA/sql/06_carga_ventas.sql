-- ============================================================
-- PROYECTO 1 - Script 06: carga mensual de VENTAS
-- Se corre DESPUÉS del 05 (productos) y del 07 (compras)
-- ============================================================
USE tienda;

DROP PROCEDURE IF EXISTS sp_carga_ventas;

-- 1. Tabla de paso: aquí se importa el CSV de ventas del mes
CREATE TABLE IF NOT EXISTS carga_ventas (
    id_codigo        VARCHAR(20),
    nombre_producto  VARCHAR(100),
    cantidad         DECIMAL(10,3),
    precio_usado     DECIMAL(10,2),
    total            DECIMAL(12,2),
    periodo          DATE             -- primer día del mes
);

-- 2. Procedimiento: alimenta SOLO la tabla ventas (y descuenta
--    inventario). NO crea productos: un código que no existe en
--    productos se queda en carga_ventas para revisarlo.
DELIMITER //
CREATE PROCEDURE sp_carga_ventas()
BEGIN
    START TRANSACTION;

    -- a) Producto que ya tiene fila en ese mes: se suma lo nuevo
    --    (la subconsulta "c" junta los códigos repetidos del CSV)
    UPDATE ventas v
    INNER JOIN (SELECT id_codigo, periodo,
                       SUM(cantidad)     AS cantidad,
                       MAX(precio_usado) AS precio_usado,
                       SUM(total)        AS total
                FROM carga_ventas
                GROUP BY id_codigo, periodo) c
            ON v.id_codigo = c.id_codigo AND v.periodo = c.periodo
    SET v.cantidad     = v.cantidad + c.cantidad,
        v.total        = v.total + c.total,
        v.precio_usado = GREATEST(v.precio_usado, c.precio_usado);

    -- b) Producto sin fila en ese mes: se inserta, con nombre y
    --    departamento tomados de productos
    INSERT INTO ventas (id_codigo, nombre_producto, cantidad, precio_usado,
                        total, periodo, id_departamento, departamento)
    SELECT c.id_codigo, p.nombre_producto, c.cantidad, c.precio_usado,
           c.total, c.periodo, p.id_departamento, p.departamento
    FROM (SELECT id_codigo, periodo,
                 SUM(cantidad)     AS cantidad,
                 MAX(precio_usado) AS precio_usado,
                 SUM(total)        AS total
          FROM carga_ventas
          GROUP BY id_codigo, periodo) c
    INNER JOIN productos p ON c.id_codigo = p.id_codigo
    LEFT JOIN ventas v
           ON v.id_codigo = c.id_codigo AND v.periodo = c.periodo
    WHERE v.id_venta IS NULL;

    -- c) Descontar del inventario lo vendido (nunca menos de 0)
    UPDATE inventario i
    INNER JOIN (SELECT id_codigo, SUM(cantidad) AS cantidad
                FROM carga_ventas
                GROUP BY id_codigo) c
            ON i.id_codigo = c.id_codigo
    SET i.existencia = GREATEST(i.existencia - c.cantidad, 0);

    -- d) Borrar de la tabla de paso solo lo que sí se cargó
    DELETE FROM carga_ventas
    WHERE id_codigo IN (SELECT id_codigo FROM productos);

    COMMIT;
END //
DELIMITER ;

-- ============================================================
-- Uso cada mes:
-- 1. Clic derecho en carga_ventas > Table Data Import Wizard (CSV).
-- 2. SET SQL_SAFE_UPDATES = 0;
--    CALL sp_carga_ventas();
--    SET SQL_SAFE_UPDATES = 1;
-- 3. Revisar lo que no se cargó (código sin producto):
--    SELECT * FROM carga_ventas;
-- 4. SELECT * FROM vw_ventas_mensuales ORDER BY periodo DESC;
-- ============================================================
