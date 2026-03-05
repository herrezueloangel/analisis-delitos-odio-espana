-- =========================================
-- 1. CREACIÓN DE BASE DE DATOS
-- =========================================

CREATE DATABASE proyecto_odio;
USE proyecto_odio;

-- =========================================
-- 2. CARGA DE DATOS DELITOS DE ODIO
-- =========================================

CREATE TABLE delitos_odio (
    comunidad VARCHAR(100),
    tipologia_penal VARCHAR(200),
    ambito VARCHAR(150),
    calificacion VARCHAR(100),
    año INT,
    total INT
);

LOAD DATA INFILE '06001-utf8.csv'
INTO TABLE delitos_odio
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================================
-- 3. DELITOS DE ODIO TOTALES POR AÑO
-- =========================================

CREATE TABLE delitos_odio_nacional AS
SELECT 
    año,
    SUM(total) AS total_delitos
FROM delitos_odio
WHERE comunidad = 'TOTAL NACIONAL'
  AND calificacion = 'INFRACC. PENALES'
GROUP BY año;

-- =========================================
-- 4. EVOLUCIÓN POR ÁMBITO
-- =========================================

CREATE TABLE delitos_odio_por_ambito AS
SELECT 
    año,
    ambito,
    SUM(total) AS total_delitos
FROM delitos_odio
WHERE comunidad = 'TOTAL NACIONAL'
  AND calificacion = 'INFRACC. PENALES'
  AND ambito NOT LIKE 'TOTAL%'
GROUP BY año, ambito;

-- =========================================
-- 5. CRECIMIENTO INTERANUAL
-- =========================================

SELECT 
    año,
    total_delitos,
    ROUND(
        (total_delitos - LAG(total_delitos) OVER (ORDER BY año))
        / LAG(total_delitos) OVER (ORDER BY año) * 100,
        2
    ) AS crecimiento_pct
FROM delitos_odio_nacional;

-- =========================================
-- 6. TABLA DE RESULTADOS ELECTORALES
-- =========================================

CREATE TABLE elecciones_resultados (
    año INT,
    eleccion VARCHAR(20),
    partido VARCHAR(50),
    porcentaje_voto FLOAT
);

-- INSERTS AQUÍ

-- =========================================
-- 7. DATASET FINAL PARA POWER BI
-- =========================================

CREATE TABLE analisis_politico_delitos_odio AS
SELECT
    d.año,
    d.total_delitos AS delitos_odio,
    t.total_delitos AS delitos_totales,
    ROUND(d.total_delitos / t.total_delitos * 100,4) AS peso_delitos_odio_pct,
    e.partido,
    e.porcentaje_voto
FROM delitos_odio_nacional d
LEFT JOIN delitos_totales t
ON d.año = t.año
LEFT JOIN elecciones_resultados e
ON d.año = e.año;