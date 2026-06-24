/*
================================================================================
PROYECTO: Predicción de Churn & Modelo Pareto ABC - Tarjeta de Crédito
AUTOR: Adrián Poet | Data Analyst & BI Specialist
FECHA: Junio 2026
DESCRIPCIÓN: Pipeline analítico avanzado integrado en una VIEW con CTEs modulares.
             Implementa detección de inactividad, ventanas móviles (90 días),
             análisis de comportamiento de compra, segmentación Pareto 80/20
             y un modelo dinámico de alertas de Churn basado en desvíos históricos.
================================================================================
*/

CREATE VIEW vista_analisis_clientes_churn AS

-- =============================================================================
-- PASO 1: CONSTRUCCIÓN DE LA GRILLA BASE (GENERACIÓN DE UNIVERSO COMPLETO)
-- =============================================================================

-- Aislamiento de la población única de clientes
WITH clientes_unicos AS (
    SELECT DISTINCT 
        Cliente 
    FROM vista_tabla_completa
),

-- Identificación de la línea temporal de cierres de ciclo
fechas_cierre_unicas AS (
    SELECT DISTINCT 
        Fecha_Cierre_Ciclo AS Fecha_Cierre 
    FROM vista_tabla_completa
),

-- Cross Join matricial para asegurar registros mensuales, incluso en periodos de inactividad
grilla_base AS (
    SELECT 
        c.Cliente, 
        f.Fecha_Cierre
    FROM clientes_unicos c
    CROSS JOIN fechas_cierre_unicas f
),

-- =============================================================================
-- PASO 2: AGREGACIÓN DE MÉTRICAS TRANSACCIONALES REALES
-- =============================================================================
monto_real AS (
    SELECT
        Cliente,
        Fecha_Cierre_Ciclo AS Fecha_Cierre,
        ROUND(AVG(CAST(Monto_Pesos AS FLOAT)), 2) AS Ticket_Promedio,
        SUM(Monto_Pesos) AS Monto_Total,
        COUNT(Id_Transaccion) AS Numero_Compras,
        ROUND(AVG(CAST(Satisfaccion_Cliente AS FLOAT)), 2) AS Satisfaccion_Promedio
    FROM vista_tabla_completa
    GROUP BY Cliente, Fecha_Cierre_Ciclo
),

-- =============================================================================
-- PASO 3: RELLENO DE HUECOS LOGÍSTICOS ( TRATAMIENTO DE NULLS )
-- =============================================================================
monto1 AS (
    SELECT
        g.Cliente,
        g.Fecha_Cierre,
        ISNULL(m.Numero_Compras, 0) AS Numero_Compras,
        ISNULL(m.Ticket_Promedio, 0) AS Ticket_Promedio,
        ISNULL(m.Monto_Total, 0) AS Monto_Total,
        ISNULL(m.Satisfaccion_Promedio, 0) AS Satisfaccion_Promedio
    FROM grilla_base g
    LEFT JOIN monto_real m 
        ON g.Cliente = m.Cliente 
        AND g.Fecha_Cierre = m.Fecha_Cierre
),

-- =============================================================================
-- PASO 4: ANÁLISIS TEMPORAL MÓVIL Y EVOLUTIVO ( WINDOW FUNCTIONS )
-- =============================================================================

-- Cálculo de ventanas acumuladas de 90 días e identificación del mes inmediato anterior
metricas_con_lag AS (
    SELECT
        *,
        SUM(Monto_Total) OVER (
            PARTITION BY Cliente 
            ORDER BY Fecha_Cierre 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Monto_Ultimos_90_Dias,
        LAG(Numero_Compras) OVER (
            PARTITION BY Cliente 
            ORDER BY Fecha_Cierre
        ) AS Compra_Anterior
    FROM monto1
),

-- Identificación cualitativa de la tendencia de uso de la tarjeta
comportamiento_clientes AS (
    SELECT
        *,
        CASE
            WHEN Numero_Compras = Compra_Anterior THEN 'ESTABLE'
            WHEN Numero_Compras > Compra_Anterior THEN 'SUBIO'
            WHEN Numero_Compras < Compra_Anterior THEN 'BAJO'
            ELSE 'PRIMER MES'
        END AS Comportamiento_Compras
    FROM metricas_con_lag
),

-- =============================================================================
-- PASO 5: MODELADO FINANCIERO PARETO ( 80 / 20 ) Y ALERTAS DE CHURN
-- =============================================================================

-- Determinación del peso porcentual del cliente sobre el volumen de la cartera móvil
monto_percentages AS (
    SELECT 
        *,
        ROUND(Monto_Ultimos_90_Dias / NULLIF(SUM(CAST(Monto_Ultimos_90_Dias AS FLOAT)) OVER(PARTITION BY Fecha_Cierre), 0) * 100, 2) AS Porcentaje_Monto
    FROM comportamiento_clientes
),

-- Acumulación de Pareto e histórico promedio de transaccionalidad individual
monto_acumulado AS (
    SELECT
        *,
        SUM(Porcentaje_Monto) OVER(
            PARTITION BY Fecha_Cierre 
            ORDER BY Monto_Ultimos_90_Dias DESC
        ) AS Porcentaje_Acumulado,
        ROUND(AVG(CAST(Numero_Compras AS FLOAT)) OVER(PARTITION BY Cliente), 2) AS Promedio_Compras_Mensual_Historico
    FROM monto_percentages
),

-- Segmentación final ABC y matriz lógica preventiva de Abandono (Churn)
pareto_estado AS (
    SELECT 
        *,
        -- Clasificación de Clientes Estratégicos (Pareto)
        CASE
            WHEN Porcentaje_Acumulado <= 80 THEN 'A'
            WHEN Porcentaje_Acumulado <= 95 THEN 'B'
            ELSE 'C'
        END AS Pareto_ABC,
        
        -- Algoritmo de Alerta Preventiva de Fuga (Basado en Ritmo Habitual del Cliente)
        CASE
            WHEN Numero_Compras IS NULL OR Numero_Compras = 0 THEN 'INACTIVO EN EL MES'
            
            -- Tracción Saludable: Transacciona al 80% o más de su promedio histórico
            WHEN Numero_Compras >= (Promedio_Compras_Mensual_Historico * 0.8) THEN 'ACTIVO (Creciendo/Estable)'
            
            -- Alerta Temprana: Caída por debajo del promedio pero por encima del límite crítico
            WHEN Numero_Compras >= (Promedio_Compras_Mensual_Historico * 0.4) THEN 'ALERTA LEVE (Bajo Promedio)'
            
            -- Riesgo Crítico de Churn: Actividad desplomada a menos del 40% de su ritmo habitual
            ELSE 'ALERTA CRÍTICA (Caída Fuerte)'
        END AS Estado_Cliente_Mensual
    FROM monto_acumulado 
)

-- =============================================================================
-- EXTRACCIÓN Y FORMATEO EJECUTIVO FINAL
-- =============================================================================
SELECT 
    Cliente,
    Fecha_Cierre,
    UPPER(FORMAT(Fecha_Cierre, 'MMMM', 'es-AR')) AS Mes,
    YEAR(Fecha_Cierre) AS Anio,
    Numero_Compras,
    Comportamiento_Compras,
    Promedio_Compras_Mensual_Historico,
    Ticket_Promedio,
    Monto_Total,
    Porcentaje_Monto,
    Satisfaccion_Promedio,
    Pareto_ABC,
    Estado_Cliente_Mensual
FROM pareto_estado;
