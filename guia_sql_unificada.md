# Guía SQL unificada — Curso "SQL TOTAL" (MySQL)

Todo lo que has visto en el curso y en nuestras prácticas, en un solo lugar. Junta tus notas de Word (Días 1 a 5), los 6 acordeones del proyecto y lo que resolvimos en el chat (Días 1 a 9).

**Cómo usarla:** busca el tema en el índice. Cada sección tiene la idea clave, la sintaxis y un ejemplo con NetflixDB o EmpresaDB. Al final están tus errores más frecuentes y los errores de MySQL que ya te salieron.

---

## Índice

1. [Bases de datos de práctica](#1-bases-de-datos-de-práctica)
2. [Vocabulario: funciones y cláusulas](#2-vocabulario-funciones-y-cláusulas)
3. [El orden de una consulta](#3-el-orden-de-una-consulta)
4. [SELECT básico: DISTINCT, ORDER BY, LIMIT, alias](#4-select-básico)
5. [Filtrar con WHERE: operadores, IN, BETWEEN, LIKE, REGEXP](#5-filtrar-con-where)
6. [Agregación, GROUP BY y HAVING](#6-agregación-group-by-y-having)
7. [JOINs](#7-joins)
8. [UNION y UNION ALL](#8-union-y-union-all)
9. [Subconsultas](#9-subconsultas)
10. [CTE (WITH)](#10-cte-with)
11. [Funciones de ventana: ROW_NUMBER, RANK, DENSE_RANK, PARTITION BY](#11-funciones-de-ventana)
12. [Funciones condicionales: IF y CASE WHEN](#12-funciones-condicionales)
13. [Conversión, fecha, texto y matemáticas](#13-conversión-fecha-texto-y-matemáticas)
14. [Modelado: llaves, cardinalidad, normalización](#14-modelado-de-bases-de-datos)
15. [DDL, DML y CRUD](#15-ddl-dml-y-crud)
16. [Procedimientos almacenados](#16-procedimientos-almacenados)
17. [Transacciones](#17-transacciones)
18. [Privilegios de usuario (GRANT)](#18-privilegios-de-usuario)
19. [Lo que falta del curso](#19-lo-que-falta-del-curso)
20. [Tus errores más frecuentes](#20-tus-errores-más-frecuentes)
21. [Errores de MySQL que ya te salieron](#21-errores-de-mysql-que-ya-te-salieron)

---

## 1. Bases de datos de práctica

Los scripts completos están en la carpeta del proyecto:
- `ejemplos_sql/Netflix_schema.sql` y `ejemplos_sql/Netflix_data.sql`
- `ejemplos_sql/EmpresaDB_schema.sql` y `ejemplos_sql/EmpresaDB_data.sql`

### NetflixDB (la de casi todos los ejercicios)

| Tabla | Columnas |
|---|---|
| `Series` | `serie_id` (PK, AI), `titulo`, `descripcion`, `año_lanzamiento` (INT), `genero` |
| `Episodios` | `episodio_id` (PK, AI), `serie_id` (FK), `titulo`, `duracion` (INT, minutos), `rating_imdb` (DECIMAL(3,1)), `temporada`, `descripcion`, `fecha_estreno` (DATE) |
| `Actores` | `actor_id` (PK, AI), `nombre`, `fecha_nacimiento` (DATE) |
| `Actuaciones` | `actor_id` (FK), `serie_id` (FK), `personaje`. PK compuesta (`actor_id`, `serie_id`). Es la tabla puente muchos a muchos entre Actores y Series |

**Series por id** (útil para los `WHERE serie_id = ...`):

| id | Serie | Género | id | Serie | Género |
|---|---|---|---|---|---|
| 1 | Breaking Bad | Drama | 8 | Arcane | Animación |
| 2 | Stranger Things | Ciencia ficción | 9 | Peaky Blinders | Drama histórico |
| 3 | The Crown | Drama histórico | 10 | Sherlock | Drama |
| 4 | Black Mirror | Ciencia ficción | 11 | Narcos | Biografía |
| 5 | The Witcher | Fantasía | 12 | Game of Thrones | Fantasía |
| 6 | The Mandalorian | Ciencia ficción | 13 | The Office | Comedia |
| 7 | BoJack Horseman | Comedia | | | |

Ojo: los nombres de columna no llevan tilde (`titulo`, `descripcion`, `duracion`) pero `año_lanzamiento` sí lleva ñ. `rating_imdb` y `duracion` viven en **Episodios**, no en Series. `genero` vive en **Series**.

### EmpresaDB (procedimientos y transacciones)

| Tabla | Columnas |
|---|---|
| `Departamentos` | `depto_id` (PK, AI), `nombre`, `ubicacion` |
| `Empleados` | `empleado_id` (PK, AI), `nombre`, `apellido`, `email` (UNIQUE), `depto_id` (FK, `ON DELETE SET NULL`) |
| `Proyectos` | `proyecto_id` (PK, AI), `nombre`, `descripcion`, `fecha_inicio`, `fecha_fin` |
| `AsignacionesDeProyectos` | `asignacion_id` (PK, AI), `proyecto_id` (FK), `empleado_id` (FK), `horas_asignadas` |
| `LogEmpleados` | `log_id` (PK, AI), `empleado_id` (FK), `fecha_registro` (DATETIME). Empieza vacía |

---

## 2. Vocabulario: funciones y cláusulas

A todo esto se le llama **funciones y cláusulas SQL**. Una *cláusula* es una parte de la consulta (`WHERE`, `GROUP BY`). Una *función* recibe valores y devuelve un resultado (`COUNT()`, `UPPER()`). Una *query* es una consulta completa.

| Categoría | Qué hacen | Cuáles |
|---|---|---|
| Funciones de agregación | Muchas filas → un solo valor | `SUM`, `COUNT`, `AVG`, `MAX`, `MIN` |
| Funciones de texto | Transforman texto | `UPPER`, `LOWER`, `CONCAT`, `SUBSTRING`, `LEFT`, `RIGHT`, `LENGTH` |
| Funciones de fecha | Trabajan con fechas | `YEAR`, `MONTH`, `DATE_ADD`, `DATEDIFF`, `CURDATE` |
| Funciones condicionales | Deciden un valor según una condición | `IF`, `CASE WHEN` |
| Funciones de conversión | Cambian el tipo de dato | `CAST` |
| Funciones matemáticas | Redondean | `ROUND`, `CEILING`, `FLOOR` |
| Funciones de ventana | Numeran o rankean filas sin juntarlas | `ROW_NUMBER`, `RANK`, `DENSE_RANK` + `PARTITION BY` |
| Cláusulas de filtrado y orden | Filtran, agrupan, ordenan, limitan | `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `DISTINCT`, `LIMIT` |
| Operadores lógicos y de comparación | Arman condiciones | `AND`, `OR`, `NOT`, `=`, `<>`, `>`, `<`, `>=`, `<=`, `IN`, `BETWEEN`, `LIKE`, `REGEXP` |
| Combinación de tablas | Juntan tablas o resultados | `JOIN` (INNER, LEFT, RIGHT), `UNION`, `UNION ALL`, subconsultas, CTE |

---

## 3. El orden de una consulta

**Cómo se escribe** (siempre en este orden):

```sql
SELECT columnas
FROM tabla
JOIN otra_tabla ON ...
WHERE condición_de_filas
GROUP BY columna
HAVING condición_de_grupos
ORDER BY columna
LIMIT n;
```

**Cómo lo ejecuta MySQL:** `FROM/JOIN` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY` → `LIMIT`.

Por eso `WHERE` no puede usar `COUNT()` (todavía no hay grupos) y por eso en `HAVING` repites la función en lugar de usar el alias.

---

## 4. SELECT básico

| Cláusula | Para qué |
|---|---|
| `SELECT *` | Todas las columnas |
| `SELECT DISTINCT col` | Quita valores repetidos |
| `ORDER BY col ASC/DESC` | Ordena (ASC menor→mayor, DESC mayor→menor) |
| `LIMIT n` | Solo las primeras n filas. Va sola con el número, al final |
| `AS alias` | Le pone nombre a una columna o tabla |

```sql
-- Géneros sin repetir
SELECT DISTINCT genero FROM series;

-- Top 5 episodios por rating
SELECT titulo, serie_id, rating_imdb FROM episodios
ORDER BY rating_imdb DESC
LIMIT 5;

-- Actores del más joven al mayor
SELECT nombre, fecha_nacimiento FROM actores
ORDER BY fecha_nacimiento DESC;
```

**Regla del "top N":** si quieres **filas completas** (las 3 series más antiguas, el episodio más largo), usa `ORDER BY` + `LIMIT`. No uses `MAX`/`MIN` ni `GROUP BY` para eso.

```sql
-- Correcto: el episodio más largo
SELECT * FROM episodios ORDER BY duracion DESC LIMIT 1;
```

**Alias con espacios:** entre comillas simples al crearlo (`AS 'Rating Promedio'`), y con comillas invertidas al usarlo después (`` `Rating Promedio` ``).

---

## 5. Filtrar con WHERE

`WHERE` filtra **filas individuales**, antes de agrupar.

**Comillas:** texto y fechas **con** comillas simples (`'Drama'`, `'2006-04-27'`). Números, enteros o decimales, **sin** comillas (`2010`, `9.0`).

### Operadores
- Comparación: `=`, `<>` (diferente), `>`, `<`, `>=`, `<=`
- Lógicos: `AND`, `OR`, `NOT`

```sql
SELECT titulo, duracion, rating_imdb FROM episodios
WHERE duracion > 45 AND rating_imdb >= 9;
```

### OR vs IN
`=` compara con un solo valor. Para varios valores, repite la columna con `OR` o usa `IN`.

```sql
WHERE genero = 'Fantasía' OR genero = 'Biografía'
WHERE genero IN ('Fantasía', 'Biografía')      -- igual, más corto
WHERE genero NOT IN ('Drama')                  -- todo menos Drama
WHERE genero <> 'Drama'                        -- igual que la anterior
```

**Regla de paréntesis:** `IN` y `NOT IN` **siempre** llevan paréntesis, aunque sea un solo valor. `=`, `<>`, `LIKE` y `BETWEEN` **nunca** los llevan.

### BETWEEN (rango, incluye ambos extremos)
```sql
SELECT * FROM series WHERE año_lanzamiento BETWEEN 2010 AND 2016;
```

### LIKE (texto parcial)
El `%` va **dentro** de las comillas.

| Patrón | Significa |
|---|---|
| `'The%'` | Empieza con "The" |
| `'%s'` | Termina con "s" |
| `'%Crown%'` | Contiene "Crown" |

```sql
SELECT * FROM actores WHERE nombre LIKE '%z%';
SELECT * FROM actores WHERE nombre NOT LIKE '%a%';
```

### REGEXP (patrones más flexibles)
```sql
SELECT titulo, descripcion FROM series
WHERE descripcion REGEXP '(?i)más';   -- (?i) = ignora mayúsculas
```

---

## 6. Agregación, GROUP BY y HAVING

### Funciones de agregación
| Función | Hace |
|---|---|
| `COUNT(*)` / `COUNT(col)` | Cuenta filas (sin espacio entre COUNT y el paréntesis) |
| `SUM(col)` | Suma |
| `AVG(col)` | Promedio |
| `MAX(col)` / `MIN(col)` | Mayor / menor valor |

Sin `GROUP BY`, la función trabaja sobre toda la tabla y da **una sola fila**. En ese caso no pongas otras columnas sueltas en el `SELECT`.

```sql
SELECT COUNT(episodio_id), AVG(duracion) FROM episodios;
```

### GROUP BY
Una fila de resultado por cada grupo. Agrupas por la **columna original** que quieres juntar (la misma que muestras junto al conteo), nunca por el resultado del conteo.

```sql
-- Series por género
SELECT genero, COUNT(serie_id) FROM series
GROUP BY genero;

-- Actores nacidos por año
SELECT YEAR(fecha_nacimiento), COUNT(nombre) FROM actores
GROUP BY YEAR(fecha_nacimiento)
ORDER BY COUNT(nombre) DESC;
```

No agrupes por algo que ya es único por fila (`nombre` de actor, `episodio_id`): cada grupo tendría una sola fila y el agrupamiento no sirve.

### HAVING
Filtra **grupos ya formados**. Se usa cuando la condición lleva una función de agregación.

```sql
SELECT serie_id, COUNT(episodio_id) AS numero_episodios
FROM episodios
GROUP BY serie_id
HAVING COUNT(episodio_id) > 10;
```

### WHERE + GROUP BY + HAVING juntos
```sql
-- Temporadas de Peaky Blinders (id 9) con más de 3 episodios
SELECT temporada, COUNT(episodio_id) FROM episodios
WHERE serie_id = 9               -- filtra filas ANTES
GROUP BY temporada
HAVING COUNT(episodio_id) > 3;   -- filtra grupos DESPUÉS
```

### Regla de oro: WHERE vs HAVING
Pregúntate: **¿la condición usa `COUNT`, `SUM`, `AVG`, `MAX` o `MIN`?**
- Sí → `HAVING` (va después de `GROUP BY`)
- No, es un dato normal de la fila → `WHERE` (va antes de `GROUP BY`)

**WHERE filtra filas, HAVING filtra grupos.**

---

## 7. JOINs

Un JOIN "pega" dos tablas usando la columna que comparten (normalmente PK = FK).

| Tipo | Trae |
|---|---|
| `INNER JOIN` (o solo `JOIN`) | Solo filas que coinciden en ambas tablas |
| `LEFT JOIN` | Todas las filas de la tabla del `FROM` (izquierda) y lo que coincida de la otra. Lo que no coincide sale en NULL |
| `RIGHT JOIN` | Todas las filas de la tabla después del `JOIN` (derecha) |
| `FULL JOIN`, `CROSS JOIN` | Existen, el curso no los enseña |

"Izquierda" y "derecha" son **posición en la query**, no la tabla en sí. Cualquier RIGHT JOIN se puede reescribir como LEFT JOIN cambiando el orden. En la industria se prefiere LEFT.

```sql
-- Título de la serie, título del episodio y duración, solo Stranger Things
SELECT S.titulo AS titulo_serie, E.titulo AS titulo_episodio, E.duracion
FROM series AS S
JOIN episodios AS E ON S.serie_id = E.serie_id
WHERE S.titulo = 'Stranger Things';

-- Todos los actores, tengan o no actuación
SELECT a.nombre, act.personaje
FROM actores a
LEFT JOIN actuaciones act ON a.actor_id = act.actor_id
ORDER BY a.nombre ASC;

-- Género y duración promedio (genero vive en series, duracion en episodios)
SELECT s.genero, AVG(e.duracion) AS promedio_duracion
FROM series s
JOIN episodios e ON s.serie_id = e.serie_id
GROUP BY s.genero
HAVING AVG(e.duracion) > 50;
```

### Estrella vs cadena
- **Estrella:** varias tablas se unen a una central, cada una por su lado. Series→Episodios y Series→Actuaciones.
- **Cadena:** Actores→Actuaciones→Series. Actores y Series no comparten columna, así que **tienes que pasar por la tabla puente** Actuaciones.

```sql
SELECT a.nombre, s.titulo, act.personaje
FROM actores a
JOIN actuaciones act ON a.actor_id = act.actor_id
JOIN series s ON act.serie_id = s.serie_id;
```

**Cuidado con el fan-out:** unir tablas por la llave equivocada multiplica filas. Revisa siempre que el número de filas tenga sentido.

---

## 8. UNION y UNION ALL

Pegan resultados de dos o más `SELECT` **uno debajo del otro** (JOIN pega columnas lado a lado; UNION pega filas).

| | Duplicados | Velocidad |
|---|---|---|
| `UNION` | Los elimina | Más lento (tiene que comparar) |
| `UNION ALL` | Los deja | Más rápido |

**Requisitos:** mismo número de columnas y tipos compatibles. Los nombres de columna del resultado salen del **primer** SELECT.

```sql
-- Lista combinada de series y actores
SELECT titulo AS nombre, 'Serie' AS tipo FROM series
UNION
SELECT nombre, 'Actor' FROM actores;

-- Ciencia ficción y Drama, conservando todo
SELECT * FROM series WHERE genero = 'Ciencia ficción'
UNION ALL
SELECT * FROM series WHERE genero = 'Drama';
```

---

## 9. Subconsultas

Una consulta dentro de otra, entre paréntesis. Se puede poner en tres lugares:

**1. En el WHERE (como filtro, lo más común):**
```sql
-- Series con rating promedio mayor a 8
SELECT titulo FROM series
WHERE serie_id IN (
    SELECT serie_id FROM episodios
    GROUP BY serie_id
    HAVING AVG(rating_imdb) > 8
);
```

**2. En el FROM o en un JOIN (como tabla derivada, necesita alias):**
```sql
-- Actores que salen en más de una serie
SELECT nombre FROM actores
JOIN (
    SELECT actor_id FROM actuaciones
    GROUP BY actor_id
    HAVING COUNT(serie_id) > 1
) AS ActorMasDeUnaSerie
ON actores.actor_id = ActorMasDeUnaSerie.actor_id;
```

**3. En el SELECT (correlacionada, calcula un valor por cada fila):**
```sql
SELECT titulo,
       (SELECT COUNT(*) FROM episodios
        WHERE episodios.serie_id = series.serie_id) AS total_episodios
FROM series;
```
Aquí no hace falta `GROUP BY`: la condición `episodios.serie_id = series.serie_id` hace el conteo para cada serie.

**Subconsulta vs JOIN:** usa JOIN cuando necesitas **mostrar** columnas de ambas tablas. Usa subconsulta cuando solo necesitas **filtrar** con un cálculo de otra tabla.

**Método de 3 pasos para consultas complejas:**
1. Escribe y corre la subconsulta sola. Revisa que el resultado tenga sentido.
2. Escribe y corre la consulta principal sola.
3. Combínalas.

---

## 10. CTE (WITH)

Una CTE es una **tabla temporal con nombre** que solo existe durante esa consulta. Sirve para dividir un problema en pasos legibles y reutilizar un cálculo.

```sql
WITH NombreCTE AS (
    SELECT ...
),
OtraCTE AS (          -- varias CTE se separan con coma, sin repetir WITH
    SELECT ...
)
SELECT ...
FROM NombreCTE
JOIN OtraCTE ON NombreCTE.llave = OtraCTE.llave;
```

**CTE vs subconsulta:** la subconsulta vive dentro de una parte de la query y si la necesitas dos veces la escribes dos veces. La CTE se define una vez y la llamas por su nombre las veces que quieras.

### Ejemplo: fecha del primer episodio de cada serie
```sql
WITH FechaPrimerEpisodio AS (
    SELECT serie_id, MIN(fecha_estreno) AS primer_estreno
    FROM episodios
    GROUP BY serie_id
),
TituloDeSerie AS (
    SELECT serie_id, titulo FROM series
)
SELECT T.titulo, F.primer_estreno
FROM TituloDeSerie T
JOIN FechaPrimerEpisodio F ON F.serie_id = T.serie_id
ORDER BY F.primer_estreno ASC;
```

### Examen final de CTE (patrón estrella, lo resolviste tú)
"Series más exitosas: título, cantidad de episodios y rating promedio, ordenado por rating y luego por episodios."
```sql
WITH
SerieTitulo AS (
    SELECT serie_id, titulo FROM series
),
RatingIMDB AS (
    SELECT serie_id, AVG(rating_imdb) AS 'Rating Promedio de IMDB'
    FROM episodios GROUP BY serie_id
),
CantidadEpisodios AS (
    SELECT serie_id, COUNT(episodio_id) AS 'Cantidad de Episodios'
    FROM episodios GROUP BY serie_id
)
SELECT SerieTitulo.titulo,
       CantidadEpisodios.`Cantidad de Episodios`,
       RatingIMDB.`Rating Promedio de IMDB`
FROM SerieTitulo
JOIN RatingIMDB ON SerieTitulo.serie_id = RatingIMDB.serie_id
JOIN CantidadEpisodios ON RatingIMDB.serie_id = CantidadEpisodios.serie_id
ORDER BY `Rating Promedio de IMDB` DESC, `Cantidad de Episodios` DESC;
```

### Ejemplo: temporada con más episodios de cada serie (CTE + ventana)
```sql
WITH ConteoPorSerieTemporada AS (
    SELECT serie_id, temporada, COUNT(*) AS total_episodios
    FROM episodios
    GROUP BY serie_id, temporada
),
Ranking AS (
    SELECT serie_id, temporada, total_episodios,
           ROW_NUMBER() OVER (PARTITION BY serie_id ORDER BY total_episodios DESC) AS rn
    FROM ConteoPorSerieTemporada
)
SELECT * FROM Ranking WHERE rn = 1;
```
La segunda CTE lee de la primera, así que no necesita JOIN: es un paso encadenado.

### Cuidados
- No toda consulta necesita CTE. Si un `GROUP BY` + `WHERE` resuelve lo mismo, es mejor.
- Dentro de la CTE trae solo las columnas que vas a usar, no `SELECT *`.
- Un `ORDER BY` dentro de una CTE no sirve de nada salvo que vaya con `LIMIT`. El orden final va en el `SELECT` de afuera.
- Los alias con espacios se crean con `'comillas'` y se leen con `` `comillas invertidas` ``.

---

## 11. Funciones de ventana

Numeran o rankean filas **sin juntarlas** (a diferencia de `GROUP BY`). Van en el `SELECT`:

```sql
FUNCION() OVER (PARTITION BY columna_grupo ORDER BY columna_orden)
```
`PARTITION BY` va **antes** de `ORDER BY` dentro del `OVER`, y es opcional.

| Función | Empates | Con ratings 10, 10, 10, 9 |
|---|---|---|
| `ROW_NUMBER()` | No los respeta, siempre número único | 1, 2, 3, 4 |
| `RANK()` | Comparten número y **deja huecos** | 1, 1, 1, 4 |
| `DENSE_RANK()` | Comparten número **sin huecos** | 1, 1, 1, 2 |

- `ROW_NUMBER`: top N exacto, paginar, quitar duplicados.
- `RANK`: ranking tipo competencia (tres empatados en 1°, el siguiente queda 4°).
- `DENSE_RANK`: niveles o categorías (top 3 valores distintos).
- `PARTITION BY`: reinicia la numeración en cada grupo (top por serie, por género, por temporada).

Ninguna redondea. Solo empatan valores exactamente iguales.

```sql
-- Ranking de episodios dentro de cada temporada de Stranger Things
SELECT temporada, titulo, rating_imdb,
       ROW_NUMBER() OVER (PARTITION BY temporada ORDER BY rating_imdb DESC) AS 'Ranking IMDb'
FROM episodios
WHERE serie_id = 2
ORDER BY temporada;

-- Top 3 series más recientes
WITH OrdenSeries AS (
    SELECT titulo, año_lanzamiento,
           ROW_NUMBER() OVER (ORDER BY año_lanzamiento DESC) AS orden
    FROM series
)
SELECT * FROM OrdenSeries WHERE orden <= 3;
```

No puedes filtrar una ventana con `WHERE` en la misma consulta (se calcula después). Por eso se envuelve en una CTE o subconsulta y se filtra afuera.

---

## 12. Funciones condicionales

### IF (solo 2 resultados)
```sql
SELECT titulo, rating_imdb,
       IF(rating_imdb >= 8, 'ALTO', 'BAJO') AS categoria
FROM episodios;
```

### CASE WHEN (3 o más resultados, la opción por defecto)
```sql
SELECT titulo, año_lanzamiento,
CASE
    WHEN año_lanzamiento >= 2020 THEN 'NUEVA'
    WHEN año_lanzamiento BETWEEN 2010 AND 2019 THEN 'CLASICA'
    ELSE 'ANTIGUA'
END AS categoria
FROM series;
```
Estructura: `CASE` → uno o varios `WHEN condición THEN valor` → `ELSE` opcional → `END AS alias`.

---

## 13. Conversión, fecha, texto y matemáticas

### Tipo de dato y conversión
```sql
DESCRIBE episodios;   -- muestra el tipo de cada columna

SELECT titulo, CAST(año_lanzamiento AS CHAR) AS 'Año de Lanzamiento' FROM series;
SELECT * FROM episodios WHERE CAST(fecha_estreno AS DATE) > '2010-01-01';
```
En MySQL real es `CAST(x AS CHAR)`. El simulador del curso acepta `AS TEXT`, MySQL no.

### Fechas
| Función | Hace |
|---|---|
| `YEAR(fecha)`, `MONTH(fecha)` | Saca el año o el mes. Trabaja fila por fila, no es agregación |
| `DATE_ADD(fecha, INTERVAL 30 DAY)` | Suma tiempo (con `-30` resta). **Lleva coma antes de INTERVAL** |
| `DATEDIFF(fecha1, fecha2)` | Días entre dos fechas |
| `CURDATE()` | Fecha de hoy. `NOW()` da fecha y hora |

```sql
SELECT fecha_estreno, DATE_ADD(fecha_estreno, INTERVAL 30 DAY) FROM episodios;
SELECT *, DATEDIFF(CURDATE(), fecha_estreno) AS dias_transcurridos FROM episodios;
```

### Texto
| Función | Hace | Ejemplo |
|---|---|---|
| `UPPER(t)` / `LOWER(t)` | Mayúsculas / minúsculas | `UPPER(titulo)` |
| `CONCAT(a, b, ...)` | Une textos | `CONCAT(titulo, ' (', año_lanzamiento, ')')` |
| `SUBSTRING(t, inicio, cantidad)` | Extrae un pedazo | `SUBSTRING(titulo, 1, 5)` |
| `LEFT(t, n)` / `RIGHT(t, n)` | n caracteres desde la izquierda / derecha (como en Excel) | `LEFT(titulo, 3)` |
| `LENGTH(t)` | Cuántos caracteres | `LENGTH(titulo)` |

### Matemáticas
| Función | Hace | 0.98 → |
|---|---|---|
| `ROUND(n, decimales)` | Redondeo normal | 1 |
| `CEILING(n)` | Siempre hacia arriba | 1 |
| `FLOOR(n)` | Siempre hacia abajo | 0 |

```sql
SELECT titulo, duracion/60.0 AS horas, ROUND(duracion/60.0, 0) AS horas_redondeado
FROM episodios;
```

---

## 14. Modelado de bases de datos

- **PK (Primary Key):** columna (o conjunto) que identifica cada fila de forma única. No se repite ni cambia.
- **NN (Not Null):** la columna no acepta valores vacíos.
- **AI (Auto Increment):** MySQL genera el id solo. En el `INSERT` no lo incluyes.
- **FK (Foreign Key / clave foránea):** columna cuyos valores corresponden a la PK de otra tabla. Por eso no puedes insertar un `depto_id` que no exista en Departamentos (error 1452).
- **UNIQUE:** no se repite, pero no es la PK (por ejemplo `email`).

### Cardinalidad
Cuántas filas de una tabla se relacionan con cuántas de la otra.
- **Uno a uno:** una persona, un pasaporte.
- **Uno a muchos:** una serie tiene muchos episodios (`Series` → `Episodios`).
- **Muchos a muchos:** un actor sale en muchas series y una serie tiene muchos actores. Se resuelve con una **tabla puente** (`Actuaciones`).

En los diagramas entidad-relación (ER) la cardinalidad se dibuja con símbolos: uno, muchos, uno y solo uno, cero o uno, uno o muchos, cero o muchos.

### Normalización (resumen)
Organizar las tablas para no repetir datos.
- **1FN:** cada celda guarda un solo valor, sin listas ni columnas repetidas.
- **2FN:** cumple 1FN y cada columna depende de toda la PK, no solo de una parte (importa con PK compuestas).
- **3FN:** cumple 2FN y ninguna columna depende de otra columna que no sea la PK. Por ejemplo, el nombre del departamento va en Departamentos, no repetido en cada empleado.

---

## 15. DDL, DML y CRUD

**DDL cambia la estructura. DML cambia los datos. CRUD es el nombre de las 4 operaciones sobre datos.**

### DDL
```sql
CREATE DATABASE IF NOT EXISTS MiBase;
USE MiBase;

CREATE TABLE IF NOT EXISTS Departamentos (
    depto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ubicacion VARCHAR(255)
);

ALTER TABLE Empleados ADD COLUMN telefono VARCHAR(20);      -- agregar columna
ALTER TABLE Empleados MODIFY COLUMN telefono VARCHAR(50);   -- cambiar tipo
ALTER TABLE Empleados RENAME COLUMN telefono TO celular;    -- renombrar columna
ALTER TABLE Empleados DROP COLUMN celular;                  -- borrar columna
ALTER TABLE Empleados RENAME TO Personal;                   -- renombrar tabla

DROP TABLE IF EXISTS Empleados;    -- borra la tabla completa
DROP DATABASE IF EXISTS MiBase;    -- borra el schema completo
```
`IF NOT EXISTS` / `IF EXISTS` evitan el error si la tabla ya existe o no existe. `VARCHAR(255)` es texto de hasta 255 caracteres.

### DML
```sql
-- INSERT: tabla, columnas entre paréntesis, VALUES en el mismo orden. Sin FROM.
INSERT INTO actores (nombre, fecha_nacimiento)
VALUES ('Florence Pugh', '1996-01-03');

-- Varias filas a la vez: separa cada paréntesis con coma
INSERT INTO Empleados (nombre, apellido, email, depto_id) VALUES
('Ana', 'Ruiz', 'ana@correo.com', 1),
('Luis', 'Paz', 'luis@correo.com', 2);

-- UPDATE: tabla, SET columna = valor, WHERE cuál fila
UPDATE series
SET genero = 'Crimen'
WHERE serie_id = 11;

-- DELETE: borra filas, la tabla sigue existiendo
DELETE FROM Empleados WHERE empleado_id = 5;
```
**Siempre pon `WHERE` en UPDATE y DELETE.** Sin WHERE afecta a **todas** las filas. `SET` siempre usa `=`, nunca `IN`.

### CRUD
| CRUD | Comando |
|---|---|
| **C**reate | `INSERT` (crea registros, no tablas) |
| **R**ead | `SELECT` |
| **U**pdate | `UPDATE` |
| **D**elete | `DELETE` |

### Lo que se confunde
- `DELETE FROM tabla` borra filas. `DROP TABLE tabla` borra la tabla. No existe `DELETE TABLE`.
- `UPDATE` cambia datos. `ALTER TABLE` cambia estructura.
- `INSERT` agrega filas. `ALTER TABLE ... ADD COLUMN` agrega columnas.

**En el trabajo:** como analista usarás sobre todo `SELECT`. DDL, INSERT, UPDATE y DELETE normalmente los maneja ingeniería o el DBA. Basta con reconocerlos.

---

## 16. Procedimientos almacenados

Una query (o varias) guardada con nombre dentro de la base. La creas una vez y después solo la llamas con `CALL` y los datos nuevos. Sirve para **reutilizar código**: es tu "machote".

### Estructura
```sql
DROP PROCEDURE IF EXISTS AgregarEmpleado;

DELIMITER //
CREATE PROCEDURE AgregarEmpleado(IN _nombre VARCHAR(255), IN _apellido VARCHAR(255),
                                 IN _email VARCHAR(255), IN _depto_id INT)
BEGIN
    INSERT INTO empleados (nombre, apellido, email, depto_id)
    VALUES (_nombre, _apellido, _email, _depto_id);
END //
DELIMITER ;

CALL AgregarEmpleado('Lulu', 'González', 'lulu@correo.com', 1);
```

| Pieza | Para qué |
|---|---|
| `DROP PROCEDURE IF EXISTS` | Evita el error 1304 si ya existe |
| `DELIMITER //` | Para que MySQL no corte el procedimiento en el primer `;` de adentro |
| `BEGIN ... END //` | El cuerpo |
| `DELIMITER ;` | Regresa a lo normal. **Lleva espacio** |
| `IN _param TIPO` | Valor que recibe. Escríbelo igual en la declaración y en el cuerpo |
| `OUT _param TIPO` | Valor que devuelve en una variable `@` |
| `CALL Nombre(...)` | Lo ejecuta. Valores en el mismo orden que los parámetros. Sin parámetros: `CALL Nombre();` |

### Consultar con filtro
```sql
DELIMITER //
CREATE PROCEDURE EmpleadosPorDepto(IN _depto_id INT)
BEGIN
    SELECT nombre, apellido, email FROM empleados WHERE depto_id = _depto_id;
END //
DELIMITER ;

CALL EmpleadosPorDepto(2);
```

### Devolver un valor (OUT)
```sql
DELIMITER //
CREATE PROCEDURE ContarEmpleados(IN _depto_id INT, OUT _total INT)
BEGIN
    SELECT COUNT(*) INTO _total FROM empleados WHERE depto_id = _depto_id;
END //
DELIMITER ;

CALL ContarEmpleados(1, @total);
SELECT @total;
```

### Comandos útiles
```sql
SHOW PROCEDURE STATUS WHERE Db = 'EmpresaDB';
SHOW CREATE PROCEDURE AgregarEmpleado;
DROP PROCEDURE IF EXISTS AgregarEmpleado;
```

---

## 17. Transacciones

Agrupan varias operaciones en un bloque **todo o nada**: o se guardan todas, o no se guarda ninguna. Sirven para **proteger la integridad** de operaciones que dependen entre sí. El ejemplo clásico es una transferencia bancaria: restar de una cuenta y sumar a otra.

| Comando | Qué hace |
|---|---|
| `START TRANSACTION;` o `BEGIN;` | Abre la transacción |
| `SAVEPOINT nombre;` | Marca un punto de guardado dentro de la transacción |
| `ROLLBACK;` | Deshace **toda** la transacción y la cierra |
| `ROLLBACK TO nombre;` | Deshace solo lo que va **después** del savepoint. La transacción **sigue abierta** |
| `COMMIT;` | Guarda todo de forma permanente y cierra. Después ya no se puede hacer ROLLBACK |

```sql
START TRANSACTION;
UPDATE Empleados SET depto_id = 2 WHERE empleado_id = 5;
INSERT INTO LogEmpleados (empleado_id, fecha_registro) VALUES (5, NOW());
COMMIT;
```

```sql
BEGIN;
SAVEPOINT PreValidacion;
INSERT INTO AsignacionesDeProyectos (proyecto_id, empleado_id, horas_asignadas) VALUES (5, 1, 10);
INSERT INTO AsignacionesDeProyectos (proyecto_id, empleado_id, horas_asignadas) VALUES (5, 2, 15);
-- si las horas se pasan del límite:
ROLLBACK TO PreValidacion;   -- tira solo las inserciones de después del savepoint
COMMIT;                      -- aún hay que cerrar
```

**Analogía:** `ROLLBACK` es reiniciar el nivel del videojuego. `ROLLBACK TO` es regresar al último punto de guardado a mitad del nivel.

**ACID** (propiedades de una transacción): **A**tomicidad (todo o nada), **C**onsistencia (la base queda válida), a**I**slamiento (mientras no hagas COMMIT, otros no ven tus cambios), **D**urabilidad (después del COMMIT, queda guardado aunque se caiga el servidor).

**Workbench tiene autocommit activado:** cada query se guarda sola. Solo dentro de `START TRANSACTION` los cambios quedan pendientes.

**Experimento de 2 minutos:** `START TRANSACTION;` → `DELETE` de una fila → `SELECT` (ya no está) → `ROLLBACK;` → `SELECT` (regresó).

### Procedimientos vs transacciones (tu confusión del Día 9)
Son **dos cajas separadas**:
- **Procedimiento almacenado** = contenedor de código **reutilizable**. Se llama con `CALL`.
- **Transacción** = protección de **integridad** para varias operaciones que van juntas.

Un procedimiento **puede** tener una transacción adentro (cuando hace varias operaciones delicadas), pero **no es obligatorio**. Tu `AgregarEmpleado` no tiene ninguna y funciona perfecto. Las transacciones sí pueden revertir lo que hizo un procedimiento. `COMMIT` y `ROLLBACK` son comandos de transacciones.

**En el trabajo:** como analista las usarás poco. Importan cuando **escribes** datos (cargas, limpiezas, tablas de trabajo). En entrevistas pueden preguntarte "¿qué es una transacción?" o "¿diferencia entre COMMIT y ROLLBACK?".

---

## 18. Privilegios de usuario

Permisos que se dan a un usuario de MySQL (tus notas del Día 5). Los más importantes:

| Privilegio | Permite |
|---|---|
| `ALL PRIVILEGES` | Todo |
| `SELECT` | Leer datos |
| `INSERT`, `UPDATE`, `DELETE` | Escribir, cambiar y borrar filas |
| `CREATE`, `ALTER`, `DROP` | Crear, modificar y borrar bases y tablas |
| `EXECUTE` | Ejecutar procedimientos almacenados |
| `INDEX` | Crear y borrar índices |
| `GRANT OPTION` | Dar o quitar permisos a otros |
| `CREATE USER` | Crear usuarios |
| `SHOW DATABASES` | Ver todas las bases |
| `LOCK TABLES` | Bloquear tablas para uso exclusivo |

Otros de administración: `FILE`, `PROCESS`, `RELOAD`, `REPLICATION CLIENT`, `REPLICATION SLAVE`, `SHUTDOWN`.

Como analista normalmente solo tendrás `SELECT`.

---

## 19. Lo que falta del curso

- **Sesión 10:** vistas, vistas materializadas, triggers.
- **Sesión 11:** AWS RDS (MySQL en la nube) y análisis de datos con SQL en AWS.
- **Sesión 12:** entrevistas técnicas, ejercicios tipo LeetCode y HackerRank.

Cuando los veas, se agregan aquí.

---

## 20. Tus errores más frecuentes

Lo que más se repitió en las prácticas. Revísalo antes de cada examen.

1. **WHERE en lugar de HAVING.** Si la condición lleva `COUNT/SUM/AVG/MAX/MIN`, es `HAVING`, después del `GROUP BY`.
2. **Agrupar por la columna equivocada.** Agrupa por lo que quieres juntar (`genero`, `serie_id`, `temporada`), no por el resultado del conteo ni por algo que ya es único (`nombre`, `episodio_id`).
3. **Usar MAX/MIN o GROUP BY para un "top N".** Para filas completas es `ORDER BY` + `LIMIT`.
4. **LIMIT mal escrito.** Es `LIMIT 3`, no `LIMIT duracion = 3` ni `LIM`.
5. **El `%` fuera de las comillas.** Es `LIKE '%s'`, no `LIKE %'s'`.
6. **IN sin paréntesis.** `IN (4)`, nunca `IN 4`. Y `SET` nunca usa `IN`.
7. **Comillas en números.** `2010` y `9.0` van sin comillas. Texto y fechas sí llevan.
8. **Nombres de columna.** `titulo` sin tilde, `descripcion` sin tilde, `serie_id` (no `series_id`), `episodio_id` (no `episodios_id`), `año_lanzamiento`.
9. **Tabla equivocada.** `rating_imdb` y `duracion` están en `episodios`. `genero` está en `series`. Si necesitas ambos, es JOIN.
10. **Leer mal el enunciado.** "Rating" vs "ranking", "4 series" vs "4 años". Léelo dos veces antes de escribir.
11. **ROW_NUMBER fuera de lugar.** Va dentro del `SELECT` como una columna más, no después del `ON`.
12. **ORDER BY de más dentro de una CTE.** El orden final va afuera.
13. **INSERT con FROM.** El INSERT no lleva `FROM`: `INSERT INTO tabla (cols) VALUES (...)`.

---

## 21. Errores de MySQL que ya te salieron (y dos que te van a salir)

| Código | Mensaje | Causa y solución |
|---|---|---|
| **1046** | No database selected | No hay schema activo. `USE NombreBase;` o doble clic en el schema en Workbench |
| **1304** | PROCEDURE already exists | Ya lo habías creado. Pon `DROP PROCEDURE IF EXISTS` antes del `CREATE` |
| **1452** | Cannot add or update a child row: a foreign key constraint fails | El valor de la FK no existe en la tabla padre. Inserta primero el departamento (o usa un id que exista) |
| **1054** | Unknown column | Nombre de columna o parámetro mal escrito (tildes, `_email` vs `email`) |
| **1064** | Error de sintaxis | Revisa comas, comillas, `DELIMITER ;` con espacio, comillas "volteadas" del celular (`´` en vez de `'`) |

Para renombrar un schema en MySQL no hay comando directo: se crea el nuevo schema y se mueven las tablas con `RENAME TABLE vieja.tabla TO nueva.tabla;`.
