-- ============================================================
-- PROYECTO 1 - Script 07: carga mensual de INVENTARIO (compras)
-- Se corre DESPUÉS del 05 (productos) y ANTES del 06 (ventas):
-- primero entra lo que compraste y luego sale lo que vendiste
-- ============================================================
USE tienda;

DROP PROCEDURE IF EXISTS sp_carga_inventario;

-- 1. Tabla de paso: aquí se importa el CSV de compras al proveedor
CREATE TABLE IF NOT EXISTS carga_inventario (
    id_codigo        VARCHAR(20),
    nombre_producto  VARCHAR(100),
    cantidad         INT              -- piezas (o kilos) compradas
);

-- 2. Procedimiento: alimenta SOLO la tabla inventario, SUMANDO
--    lo comprado. Un código que no existe en productos se queda
--    en carga_inventario para revisarlo.
DELIMITER //
CREATE PROCEDURE sp_carga_inventario()
BEGIN
    START TRANSACTION;

    -- a) Producto que ya está en inventario: se suma la compra
    UPDATE inventario i
    INNER JOIN (SELECT id_codigo, SUM(cantidad) AS cantidad
                FROM carga_inventario
                GROUP BY id_codigo) c
            ON i.id_codigo = c.id_codigo
    SET i.existencia = COALESCE(i.existencia, 0) + c.cantidad;

    -- b) Producto que aún no está en inventario: se inserta,
    --    con nombre y departamento tomados de productos
    INSERT INTO inventario (id_codigo, nombre_producto, id_departamento,
                            departamento, existencia)
    SELECT p.id_codigo, p.nombre_producto, p.id_departamento,
           p.departamento, c.cantidad
    FROM (SELECT id_codigo, SUM(cantidad) AS cantidad
          FROM carga_inventario
          GROUP BY id_codigo) c
    INNER JOIN productos p ON c.id_codigo = p.id_codigo
    LEFT JOIN inventario i ON c.id_codigo = i.id_codigo
    WHERE i.id_codigo IS NULL;

    -- c) Borrar de la tabla de paso solo lo que sí se cargó
    DELETE FROM carga_inventario
    WHERE id_codigo IN (SELECT id_codigo FROM productos);

    COMMIT;
END //
DELIMITER ;

-- ============================================================
-- Uso cada mes:
-- 1. Clic derecho en carga_inventario > Table Data Import Wizard (CSV).
-- 2. SET SQL_SAFE_UPDATES = 0;
--    CALL sp_carga_inventario();
--    SET SQL_SAFE_UPDATES = 1;
-- 3. Revisar lo que no se cargó (código sin producto):
--    SELECT * FROM carga_inventario;
-- ============================================================
