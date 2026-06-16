# Análisis de Churn y Segmentación de Clientes en Tarjetas de Crédito (SQL) 💳📊

### 🎯 Objetivo del Proyecto
Este proyecto implementa un modelo analítico avanzado mediante una Vista en SQL para monitorear la salud financiera, la evolución del consumo y el riesgo de fuga (churn) de clientes de tarjetas de crédito. El script procesa transacciones agrupadas por ciclos de cierre para segmentar a los usuarios según su relevancia y disparar alertas críticas basadas en su comportamiento histórico.

### 🛠️ Tecnologías y Conceptos Avanzados Aplicados
- **Motor:** T-SQL (SQL Server) / Standard SQL
- **Estructura Matricial:** Generación de `CROSS JOIN` para crear una grilla base temporal eliminando los "huecos" de meses sin transacciones.
- **Ventanas Temporales Avanzadas:** Uso de `LAG` para analizar evolución inmediata y `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` para calcular montos móviles de los últimos 90 días.
- **Análisis de Pareto (Segmentación ABC):** Cálculo de porcentajes acumulados dinámicos para clasificar a los clientes según la regla del 80/20.
- **Lógica de Control de Churn:** Fórmulas condicionales (`CASE WHEN`) parametrizadas para identificar caídas de actividad inferiores al 80% y 40% del ritmo habitual del cliente.

### 🧠 Arquitectura de la Consulta (Estructura de las CTEs)
El script optimiza el procesamiento de datos a través de una cadena de Common Table Expressions (CTEs):
1. `grilla_base`: Cruza todos los clientes con todas las fechas de cierre para asegurar continuidad temporal.
2. `monto_real` y `monto1`: Consolida métricas reales de negocio (Monto Total, Ticket Promedio, Nivel de Satisfacción) mapeando los meses inactivos con valor cero (`ISNULL`).
3. `metricas_con_lag`: Evalúa la actividad frente al mes anterior y acumula los últimos 90 días de facturación.
4. `pareto_estado`: Ejecuta la lógica final de negocio dividiendo la cartera en categorías A, B o C y etiquetando la salud del cliente (`ACTIVO`, `ALERTA LEVE`, `ALERTA CRÍTICA` o `INACTIVO`).
