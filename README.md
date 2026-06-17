# Análisis de Churn y Segmentación de Clientes en Tarjetas de Crédito (SQL & BI) 💳📊

## 🎯 Objetivo del Proyecto
Este proyecto implementa un modelo analítico avanzado mediante una Vista en SQL para monitorear la salud financiera, la evolución del consumo y el riesgo de fuga (*churn*) de clientes de tarjetas de crédito. En lugar de reaccionar de forma tardía ante la baja del servicio, el modelo procesa transacciones mensuales, montos móviles y niveles de satisfacción para encender alarmas tempranas y permitir acciones comerciales proactivas.

---

## 📊 Reporte de Negocio e Insights (PDF)
El desarrollo técnico está respaldado por un informe ejecutivo detallado que traduce las métricas del script en estrategias comerciales de retención.

* 📄 **[Ver Reporte Completo: Modelo Proactivo de Mitigación de Churn - Tarjeta X](./Modelo%20Proactivo%20de%20Mitigación%20de%20Churn%20-%20Tarjeta%20X.pdf)**

### 💡 Hallazgos y Acciones Quirúrgicas Destacadas:
El análisis identificó patrones específicos según las ventanas temporales de consumo divididas en tres tramos mensuales (del 1 al 10, del 11 al 20, y después del 20):
* **Caso Camila Gómez (Optimización de Ticket Alto):** Concentra volumen a mitad de mes pero su ticket promedio estalla un +$65.000 después del día 20. *Acción:* Campañas de financiación en cuotas sin interés exclusivas para fin de mes.
* **Caso Ana María Silva (Asegurar Primer Medio de Pago):** Registra alta regularidad pero su mayor facturación ocurre del 1 al 10. *Acción:* Incentivos de *Cashback* a principio de mes para garantizar que use Tarjeta X apenas percibe sus ingresos.

---

## 🧠 La Evolución de la Lógica (El "Detrás de Escena")
Llegar a la estabilidad analítica del modelo requirió entender la naturaleza del negocio transaccional mediante un proceso iterativo:
* **Fase 1 (Micro-operaciones):** Se intentó medir la diferencia de días entre compras individuales, resultando en un exceso de falsos positivos debido a las pausas habituales de consumo.
* **Fase 2 (Volatilidad Monetaria):** El análisis de montos mensuales individuales hacía que los clientes saltaran de categoría A a C continuamente por compras estacionales o extraordinarias.
* **Fase 3 (Solución Definitiva):** Se implementó una **ventana móvil de 90 días** para suavizar tendencias de gasto y una **grilla base transaccional** para visibilizar los meses sin actividad (`CROSS JOIN`).

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

## 💻 Código Fuente
El desarrollo completo de la vista analítica con el script optimizado se encuentra documentado y listo para su ejecución en la sección de archivos del repositorio:

* 💾 **[Ver Script SQL Completo](./script_churn.sql)** 
