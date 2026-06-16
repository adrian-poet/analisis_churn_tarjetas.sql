CREATE VIEW vista_analisis_clientes_churn As

WITH clientes_unicos AS (
SELECT DISTINCT 
	Cliente 
FROM vista_tabla_completa
),
fechas_cierre_unicas AS (
SELECT DISTINCT 
	Fecha_Cierre_Ciclo AS Fecha_Cierre 
FROM vista_tabla_completa
),
grilla_base AS (
SELECT 
	c.Cliente, 
	f.Fecha_Cierre
FROM clientes_unicos c
CROSS JOIN fechas_cierre_unicas f
),
monto_real AS(
Select
	Cliente,
	Fecha_Cierre_Ciclo AS Fecha_Cierre,
	ROUND(AVG(CAST(Monto_Pesos AS FLOAT)),2) AS Ticket_Promedio,
	SUM(Monto_Pesos) AS Monto_Total,
	COUNT(Id_Transaccion) AS Numero_Compras,
	ROUND(AVG(CAST(Satisfaccion_Cliente AS FLOAT)),2) AS Satisfaccion_Promedio
FROM vista_tabla_completa
GROUP BY Cliente, Fecha_Cierre_Ciclo
),
monto1 AS (
SELECT
        g.Cliente,               -- Sentamos los datos reales sobre la grilla (Los huecos se hacen 0)
        g.Fecha_Cierre,
        ISNULL(m.Numero_Compras, 0) AS Numero_Compras,
        ISNULL(m.Ticket_Promedio, 0) AS Ticket_Promedio,
        ISNULL(m.Monto_Total, 0) AS Monto_Total,
		ISNULL(m.Satisfaccion_Promedio, 0) AS Satisfaccion_Promedio
FROM grilla_base g
LEFT JOIN monto_real m ON g.Cliente = m.Cliente AND g.Fecha_Cierre = m.Fecha_Cierre
),
metricas_con_lag AS (
Select												-- Ventanas temporales(tomo 3 meses)
	*,
	SUM(Monto_Total) OVER (PARTITION BY Cliente ORDER BY Fecha_Cierre ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Monto_Ultimos_90_Dias,
	LAG(Numero_Compras) OVER (PARTITION BY Cliente ORDER BY Fecha_Cierre) AS Compra_Anterior
FROM monto1
),
comportamiento_clientes AS(
Select
		*,
        CASE
			WHEN Numero_Compras = Compra_Anterior THEN 'ESTABLE'
            WHEN Numero_Compras > Compra_Anterior THEN 'SUBIO'
            WHEN Numero_Compras < Compra_Anterior THEN 'BAJO'
            ELSE 'PRIMER MES'
        END AS Comportamiento_Compras
FROM metricas_con_lag
),
monto_porcentajes AS(
Select 
	*,
	ROUND(Monto_Ultimos_90_Dias / NULLIF(SUM(CAST(Monto_Ultimos_90_Dias AS FLOAT)) OVER(PARTITION BY Fecha_Cierre),0) * 100,2) AS Porcentaje_Monto
From comportamiento_clientes
),
monto_acumulado AS(
Select
	*,
	SUM(Porcentaje_Monto) OVER(PARTITION BY Fecha_Cierre ORDER BY Monto_Ultimos_90_Dias DESC) AS Porcentaje_Acumulado,
	ROUND(AVG(CAST(Numero_Compras AS FLOAT)) OVER(PARTITION BY Cliente),2) AS Promedio_Compras_Mensual_Historico
From monto_porcentajes
),
pareto_estado AS(
select 
	*,
	CASE
		WHEN Porcentaje_Acumulado <=80 THEN 'A'
		WHEN Porcentaje_Acumulado <=95 THEN 'B'
		ELSE 'C'
		END AS Pareto_ABC,
	
	CASE
    WHEN Numero_Compras IS NULL OR Numero_Compras = 0 THEN 'INACTIVO EN EL MES'
    
    -- Si está dentro del 80% o más de su promedio, considerarlo saludable (Estable)
    WHEN Numero_Compras >= (Promedio_Compras_Mensual_Historico * 0.8) THEN 'ACTIVO (Creciendo/Estable)'
    
    -- Si cayó por debajo del 80% pero supera el 40%, es una alerta leve
    WHEN Numero_Compras >= (Promedio_Compras_Mensual_Historico * 0.4) THEN 'ALERTA LEVE (Bajo Promedio)'
    
    -- Si cayó a menos del 40% de su ritmo habitual, ahí sí es crítico
    ELSE 'ALERTA CRÍTICA (Caída Fuerte)'
	END AS Estado_Cliente_Mensual
from monto_acumulado 
)
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
FROM pareto_estado
ORDER BY Cliente ASC, Fecha_Cierre ASC
