-- ============================================================
-- PROYECTO 1 - Script 05: carga mensual de PRODUCTOS
-- Orden cada mes: 05 productos -> 07 inventario (compras) -> 06 ventas
-- ============================================================
USE tienda;

-- Limpia versiones anteriores (las tablas finales NO se tocan)
DROP PROCEDURE IF EXISTS sp_carga_semanal;
DROP PROCEDURE IF EXISTS sp_carga_mensual;
DROP TABLE IF EXISTS carga_semanal;
DROP TABLE IF EXISTS carga_mensual;
DROP PROCEDURE IF EXISTS sp_carga_productos;

-- 1. Tabla de paso: aquí se importa el CSV de productos
CREATE TABLE IF NOT EXISTS carga_productos (
    id_codigo        VARCHAR(20),
    nombre_producto  VARCHAR(100),
    id_departamento  CHAR(3),
    departamento     VARCHAR(30),
    precio_costo     DECIMAL(10,2),
    precio_venta     DECIMAL(10,2),
    tipo_venta       VARCHAR(10)
);

-- 2. Procedimiento: alimenta SOLO la tabla productos.
--    Solo acepta los 7 departamentos actuales; una fila con otro
--    departamento se queda en carga_productos para revisarla.
DELIMITER //
CREATE PROCEDURE sp_carga_productos()
BEGIN
    START TRANSACTION;

    -- a) Productos que ya existen: se actualizan todos sus datos
    UPDATE productos p
    INNER JOIN carga_productos c ON p.id_codigo = c.id_codigo
    SET p.nombre_producto = c.nombre_producto,
        p.id_departamento = c.id_departamento,
        p.departamento    = c.departamento,
        p.precio_costo    = c.precio_costo,
        p.precio_venta    = c.precio_venta,
        p.tipo_venta      = c.tipo_venta
    WHERE c.id_departamento IN ('ABA','CIG','DUL','PAN','PAP','REF','APO');

    -- b) Productos nuevos: se dan de alta
    --    (GROUP BY por si el CSV repite un código)
    INSERT INTO productos (id_codigo, nombre_producto, id_departamento,
                           departamento, precio_costo, precio_venta, tipo_venta)
    SELECT c.id_codigo, MAX(c.nombre_producto), MAX(c.id_departamento),
           MAX(c.departamento), MAX(c.precio_costo), MAX(c.precio_venta),
           MAX(c.tipo_venta)
    FROM carga_productos c
    LEFT JOIN productos p ON c.id_codigo = p.id_codigo
    WHERE p.id_codigo IS NULL
      AND c.id_departamento IN ('ABA','CIG','DUL','PAN','PAP','REF','APO')
    GROUP BY c.id_codigo;

    -- c) Mismo nombre y departamento en ventas e inventario
    UPDATE ventas v
    INNER JOIN productos p ON v.id_codigo = p.id_codigo
    SET v.nombre_producto = p.nombre_producto,
        v.id_departamento = p.id_departamento,
        v.departamento    = p.departamento;

    UPDATE inventario i
    INNER JOIN productos p ON i.id_codigo = p.id_codigo
    SET i.nombre_producto = p.nombre_producto,
        i.id_departamento = p.id_departamento,
        i.departamento    = p.departamento;

    -- d) Borrar de la tabla de paso solo lo que sí se cargó
    DELETE FROM carga_productos
    WHERE id_departamento IN ('ABA','CIG','DUL','PAN','PAP','REF','APO');

    COMMIT;
END //
DELIMITER ;

-- ============================================================
-- Uso cada mes:
-- 1. Clic derecho en carga_productos > Table Data Import Wizard (CSV).
-- 2. SET SQL_SAFE_UPDATES = 0;
--    CALL sp_carga_productos();
--    SET SQL_SAFE_UPDATES = 1;
-- 3. Revisar lo que no se cargó (departamento no válido):
--    SELECT * FROM carga_productos;
-- ============================================================
