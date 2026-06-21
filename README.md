# Modelo Proactivo de Mitigación de Churn - Tarjetas de Crédito 💳📊

## Hallazgo del análisis
Analizando la cartera de tarjetas detecté patrones de consumo que anticipan cancelaciones.
Construí un sistema de alertas tempranas + estrategia de retención quirúrgica.

---
## Solución técnica
**Cross Join** vs




---

## 🛠️ Tecnologías y Conceptos Avanzados Aplicados
* **Motor:** T-SQL (SQL Server) / Standard SQL
* **Estructura Matricial:** Uso de `CROSS JOIN` para asegurar continuidad temporal eliminando "huecos" de meses sin transacciones.
* **Ventanas Temporales Avanzadas:** Uso de `LAG` para contrastar variaciones transaccionales inmediatas y `SUM OVER ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` para estabilizar el comportamiento del gasto a 90 días.
* **Análisis de Pareto (Segmentación ABC):** Clasificación dinámica de la cartera por fecha de cierre para identificar al Top 20% de clientes que representan la mayor relevancia de ingresos.
* **Lógica de Control de Churn:** Fórmulas condicionales (`CASE WHEN`) combinadas con desvíos del promedio histórico para etiquetar la salud del usuario (`ACTIVO`, `ALERTA LEVE`, `ALERTA CRÍTICA` o `INACTIVO`).

---

## ⚙️ Arquitectura de la Consulta (Estructura de las CTEs)
El script optimiza el procesamiento de datos a través de una cadena de Common Table Expressions (CTEs) secuenciales:
1. `grilla_base`: Cruza masivamente clientes y fechas para garantizar que ningún usuario inactivo desaparezca del reporte.
2. `monto_real` / `monto1`: Consolida métricas reales de negocio (Monto Total, Ticket Promedio, Satisfacción) mapeando los meses inactivos con valor cero (`ISNULL`).
3. `metricas_con_lag`: Evalúa la variación frente al mes anterior (`LAG`) y acumula los últimos 90 días de facturación para suavizar la tendencia.
4. `pareto_estado`: Clasifica dinámicamente la cartera en categorías A, B o C y define el estado de alerta final del cliente. *Esta salida técnica es la base que alimenta los tableros y las propuestas del informe ejecutivo.*

---

## 🚀 Impacto en el Negocio
El output de este modelo permite al negocio ejecutar tres estrategias de alto impacto:
1. **Retención Quirúrgica Temporal:** Al cruzar la alerta con la ventana de consumo preferida del cliente, el equipo de Marketing puede automatizar un disparo de retención días antes de su ventana habitual, ganándole de mano a la inactividad.
2. **Blindaje de Clientes Top (Fuga Silenciosa):** El modelo detecta si un cliente Pareto "A" mantiene sus consumos pero su satisfacción promedio cae por debajo de 4 puntos, disparando una alerta automática a Customer Experience (CX) antes de que se traduzca en abandono.
3. **Optimización del Presupuesto de Marketing:** Evita la canibalización de margen. Las acciones de alto costo (tasas preferenciales o bonificaciones) se reservan para los segmentos A y B bajo alerta, aplicando flujos digitales de bajo costo para el segmento C.
## 📊 Reporte de Negocio e Insights (PDF)
El desarrollo técnico está respaldado por un informe ejecutivo detallado que traduce las métricas del script en estrategias comerciales de retención.

* 📄 **[Ver Reporte Completo: Modelo Proactivo de Mitigación de Churn - Tarjeta X](./Modelo%20Proactivo%20de%20Mitigación%20de%20Churn%20-%20Tarjeta%20X.pdf)**
## 💻 Código Fuente
El desarrollo completo de la vista analítica con el script optimizado se encuentra documentado y listo para su ejecución en la sección de archivos del repositorio:

* 💾 **[Ver Script SQL Completo](./script_churn.sql)**

---
## 👤 Autor
* **Adrián Poet** - *Data Analyst & Business Intelligence Specialist*
* [LinkedIn](https://www.linkedin.com/in/adrian-poet)
