-- 1. Crear la base de datos y usarla
CREATE DATABASE tienda;
USE tienda;

-- 2. Tabla PRODUCTOS (catálogo de artículos)
--    id_codigo es texto porque hay códigos con letras (ej. 'OLV')
CREATE TABLE productos (
    id_codigo        VARCHAR(20) PRIMARY KEY,   -- código de barras
    nombre_producto  VARCHAR(100),
    id_departamento  CHAR(3),                   -- ABA, REF, PAP...
    departamento     VARCHAR(30),
    precio_costo     DECIMAL(10,2),
    precio_venta     DECIMAL(10,2),
    tipo_venta       VARCHAR(10)                -- UNIDAD o GRANEL
);

-- 3. Tabla VENTAS (una fila por producto por mes)
CREATE TABLE ventas (
    id_venta         INT AUTO_INCREMENT PRIMARY KEY,  -- número consecutivo
    id_codigo        VARCHAR(20),
    nombre_producto  VARCHAR(100),
    cantidad         DECIMAL(10,3),             -- 3 decimales para productos a granel
    precio_usado     DECIMAL(10,2),
    total            DECIMAL(12,2),
    periodo          DATE,                      -- primer día del mes
    id_departamento  CHAR(3),
    departamento     VARCHAR(30),
    FOREIGN KEY (id_codigo) REFERENCES productos (id_codigo)
);

-- 4. Tabla INVENTARIO (una fila por producto)
--    id_codigo es PK (no se repite) y también FK hacia productos
CREATE TABLE inventario (
    id_codigo        VARCHAR(20) PRIMARY KEY,
    nombre_producto  VARCHAR(100),
    id_departamento  CHAR(3),
    departamento     VARCHAR(30),
    existencia       INT NULL,                  -- se llena después
    FOREIGN KEY (id_codigo) REFERENCES productos (id_codigo)
);
