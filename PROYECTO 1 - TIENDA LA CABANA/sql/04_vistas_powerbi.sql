-- ============================================================
-- PROYECTO 1 - Script 04: vistas que lee Power BI
-- ============================================================
USE tienda;

-- 1. Ventas por mes: nominales (precio de ese mes) vs reales
--    (a precio de venta actual, para quitar el efecto de la inflación)
CREATE VIEW vw_ventas_mensuales AS
SELECT v.periodo,
       SUM(v.total)                              AS ventas_nominales,
       ROUND(SUM(v.cantidad * p.precio_venta), 2) AS ventas_reales,
       SUM(v.cantidad)                           AS unidades
FROM ventas v
INNER JOIN productos p ON v.id_codigo = p.id_codigo
GROUP BY v.periodo;

-- 2. Ventas por departamento en cada mes
CREATE VIEW vw_ventas_departamento_mes AS
SELECT periodo,
       departamento,
       SUM(total)    AS ventas,
       SUM(cantidad) AS unidades
FROM ventas
GROUP BY periodo, departamento;

-- 3. Ventas acumuladas por producto (para el Top 10)
CREATE VIEW vw_ventas_producto AS
SELECT id_codigo,
       nombre_producto,
       departamento,
       SUM(total)    AS total_vendido,
       SUM(cantidad) AS unidades
FROM ventas
GROUP BY id_codigo, nombre_producto, departamento;

-- 4. Inventario valorizado: cuánto vale lo que hay en existencia
CREATE VIEW vw_inventario_valorizado AS
SELECT i.id_codigo,
       i.nombre_producto,
       i.departamento,
       i.existencia,
       ROUND(i.existencia * p.precio_costo, 2) AS valor_a_costo,
       ROUND(i.existencia * p.precio_venta, 2) AS valor_a_venta
FROM inventario i
INNER JOIN productos p ON i.id_codigo = p.id_codigo;
