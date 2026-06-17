# Análisis de Churn y Segmentación de Clientes en Tarjetas de Crédito (SQL & BI) 💳📊

## 🎯 Objetivo del Proyecto
[cite_start]Este proyecto implementa un modelo analítico avanzado mediante una Vista en SQL para monitorear la salud financiera, la evolución del consumo y el riesgo de fuga (*churn*) de clientes de tarjetas de crédito[cite: 4]. [cite_start]En lugar de reaccionar de forma tardía ante la baja del servicio, el modelo procesa transacciones mensuales, montos móviles y niveles de satisfacción para encender alarmas tempranas y permitir acciones comerciales proactivas[cite: 5].

---

## 📊 Reporte de Negocio e Insights (PDF)
El desarrollo técnico está respaldado por un informe ejecutivo detallado que traduce las métricas del script en estrategias comerciales de retención.

* 📄 **[Ver Reporte Completo: Modelo Proactivo de Mitigación de Churn - Tarjeta X](./Modelo%20Proactivo%20de%20Mitigación%20de%20Churn%20-%20Tarjeta%20X.pdf)**

### 💡 Hallazgos y Acciones Quirúrgicas Destacadas:
[cite_start]El análisis identificó patrones específicos según las ventanas temporales de consumo (Inicios, mediados y cierres de mes)[cite: 26, 27]:
* [cite_start]**Caso Camila Gómez (Optimización de Ticket Alto):** Concentra volumen a mitad de mes pero su ticket promedio estalla un +$65.000 después del día 20[cite: 29]. [cite_start]*Acción:* Campañas de financiación en cuotas sin interés exclusivas para fin de mes[cite: 30].
* [cite_start]**Caso Ana María Silva (Asegurar Primer Medio de Pago):** Registra alta regularidad pero su mayor facturación ocurre del 1 al 10[cite: 31]. [cite_start]*Acción:* Incentivos de *Cashback* a principio de mes para garantizar que use Tarjeta X apenas percibe sus ingresos[cite: 32].

---

## 🧠 La Evolución de la Lógica (El "Detrás de Escena")
[cite_start]Llegar a la estabilidad analítica del modelo requirió entender la naturaleza del negocio transaccional mediante un proceso iterativo[cite: 9]:
* [cite_start]**Fase 1 (Micro-operaciones):** Se intentó medir la diferencia de días entre compras individuales, resultando en un exceso de falsos positivos debido a las pausas habituales de consumo[cite: 10, 11].
* [cite_start]**Fase 2 (Volatilidad Monetaria):** El análisis de montos mensuales individuales hacía que los clientes saltaran de categoría A a C continuamente por compras estacionales o extraordinarias[cite: 12].
* [cite_start]**Fase 3 (Solución Definitiva):** Se implementó una **ventana móvil de 90 días** para suavizar tendencias de gasto y una **grilla base transaccional** para visibilizar los meses sin actividad (`CROSS JOIN`)[cite: 13].

---

## 🛠️ Tecnologías y Conceptos Avanzados Aplicados
* **Motor:** T-SQL (SQL Server) / Standard SQL
* [cite_start]**Estructura Matricial:** Uso de `CROSS JOIN` para asegurar continuidad temporal eliminando "huecos" de meses sin transacciones[cite: 13, 16].
* [cite_start]**Ventanas Temporales Avanzadas:** Uso de `LAG` para contrastar variaciones transaccionales inmediatas y `SUM OVER ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` para estabilizar el comportamiento del gasto a 90 días[cite: 17, 18].
* [cite_start]**Análisis de Pareto (Segmentación ABC):** Clasificación dinámica de la cartera por fecha de cierre para identificar al Top 20% de clientes que representan la mayor relevancia de ingresos[cite: 12, 19].
* [cite_start]**Lógica de Control de Churn:** Fórmulas condicionales (`CASE WHEN`) combinadas con desvíos del promedio histórico para etiquetar la salud del usuario (`ACTIVO`, `ALERTA LEVE`, `ALERTA CRÍTICA` o `INACTIVO`)[cite: 19, 25].

---

## ⚙️ Arquitectura de la Consulta (Estructura de las CTEs)
[cite_start]El script optimiza el procesamiento de datos a través de una cadena de Common Table Expressions (CTEs) secuenciales[cite: 15]:
1. [cite_start]`grilla_base`: Cruza masivamente clientes y fechas para garantizar que ningún usuario inactivo desaparezca del reporte[cite: 16].
2. `monto_real` / `monto1`: Consolida métricas reales de negocio (Monto Total, Ticket Promedio, Satisfacción) mapeando los meses inactivos con valor cero (`ISNULL`).
3. [cite_start]`metricas_con_lag`: Evalúa la variación frente al mes anterior (`LAG`) y acumula los últimos 90 días de facturación para suavizar la tendencia[cite: 17, 18].
4. [cite_start]`pareto_estado`: Clasifica dinámicamente la cartera en categorías A, B o C y define el estado de alerta final del cliente[cite: 19, 25]. [cite_start]*Esta salida técnica es la base que alimenta los tableros y las propuestas del informe ejecutivo[cite: 23, 24].*

---

## 🚀 Impacto en el Negocio
[cite_start]El output de este modelo permite al negocio ejecutar tres estrategias de alto impacto[cite: 33]:
1. [cite_start]**Retención Quirúrgica Temporal:** Al cruzar la alerta con la ventana de consumo preferida del cliente, el equipo de Marketing puede automatizar un disparo de retención días antes de su ventana habitual, ganándole de mano a la inactividad[cite: 36, 37].
2. [cite_start]**Blindaje de Clientes Top (Fuga Silenciosa):** El modelo detecta si un cliente Pareto "A" mantiene sus consumos pero su satisfacción promedio cae por debajo de 4 puntos, disparando una alerta automática a Customer Experience (CX) antes de que se traduzca en abandono[cite: 38, 39, 41].
3. **Optimización del Presupuesto de Marketing:** Evita la canibalización de margen. [cite_start]Las acciones de alto costo (tasas preferenciales o bonificaciones) se reservan para los segmentos A y B bajo alerta, aplicando flujos digitales de bajo costo para el segmento C[cite: 42, 43].
