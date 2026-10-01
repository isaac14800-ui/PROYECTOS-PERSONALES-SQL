-- ============================================================
-- PROYECTO 1 - Script 03: validar que los datos cargaron bien
-- ============================================================
USE tienda;

-- 1. Filas por tabla
--    Esperado: productos 1004, inventario 799, ventas 16483
SELECT 'productos' AS tabla, COUNT(*) AS filas FROM productos
UNION ALL
SELECT 'inventario', COUNT(*) FROM inventario
UNION ALL
SELECT 'ventas', COUNT(*) FROM ventas;

-- 2. Venta total de todos los meses
--    Esperado: 9389638.58
SELECT SUM(total) AS venta_total
FROM ventas;

-- 3. Venta por mes
--    Esperado: 26 filas, de 2024-07-01 a 2026-08-01
SELECT periodo,
       SUM(total) AS venta_mes
FROM ventas
GROUP BY periodo
ORDER BY periodo;

-- 4. Ventas con un código que no existe en productos
--    Esperado: 0
SELECT COUNT(*) AS ventas_sin_producto
FROM ventas v
LEFT JOIN productos p ON v.id_codigo = p.id_codigo
WHERE p.id_codigo IS NULL;

-- 5. Códigos repetidos en el mismo mes
--    Esperado: ninguna fila
SELECT id_codigo, periodo, COUNT(*) AS veces
FROM ventas
GROUP BY id_codigo, periodo
HAVING COUNT(*) > 1;

-- 6. Venta por departamento (de mayor a menor)
SELECT departamento,
       SUM(total) AS venta_departamento
FROM ventas
GROUP BY departamento
ORDER BY venta_departamento DESC;

-- 7. Productos de inventario sin existencia capturada
--    Esperado: 0
SELECT COUNT(*) AS sin_existencia
FROM inventario
WHERE existencia IS NULL;

-- 8. Existencia por departamento
--    Esperado: 6793 piezas en total
SELECT departamento,
       COUNT(*)        AS productos,
       SUM(existencia) AS piezas
FROM inventario
GROUP BY departamento
ORDER BY piezas DESC;

-- 9. Los 10 productos con más existencia
SELECT id_codigo, nombre_producto, departamento, existencia
FROM inventario
ORDER BY existencia DESC
LIMIT 10;

-- 10. Valor del inventario en dinero (a costo y a precio de venta)
--     Esperado: costo $133,476.82, venta $186,220.00
SELECT SUM(i.existencia * p.precio_costo) AS valor_a_costo,
       SUM(i.existencia * p.precio_venta) AS valor_a_venta
FROM inventario i
INNER JOIN productos p ON i.id_codigo = p.id_codigo;

-- 11. Valor del inventario por departamento
SELECT i.departamento,
       SUM(i.existencia * p.precio_costo) AS valor_a_costo,
       SUM(i.existencia * p.precio_venta) AS valor_a_venta
FROM inventario i
INNER JOIN productos p ON i.id_codigo = p.id_codigo
GROUP BY i.departamento
ORDER BY valor_a_costo DESC;
