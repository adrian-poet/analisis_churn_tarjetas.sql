# Modelo Proactivo de Mitigación de Churn - Tarjetas de Crédito 💳📊

## Hallazgo del análisis
Analizando la cartera de tarjetas detecté patrones de consumo que anticipan cancelaciones.
Construí un sistema de alertas tempranas + estrategia de retención quirúrgica.

---
## Solución técnica
- **Funcion Ventana LAG + CASE** para clasificar comportamiento periodo a periodo: **Subio/Bajo/Estable/Primer Mes**. Detecta comportamiento de compra de clientes. Tres periodos seguidos **Bajo** **riesgo de churn**.
- **Alertas por devío** Cantidad de compras vs Promedio historico de compras. 0 compras = **Inactivo en el mes**, compras >= 80 % del promedio = **Activo**, compras >= 40 % del promedio = **Alerta Leve**, compras < 40 % del promedio = **Crítica**.
- **Pareto ABC + Ventana móvil 90 días** para segementar clientes top sin ruido estacional.
- **Analisis Temporal** clasificación por periodos, días: del 1 al 10,  del 11 al 20, después del 20.
- **Satisfacción Promedio** cruzada con volumen para detectar **Fuga silenciosa**

------
## Estrategia Proactiva de Negocio
1. **Retención Quirúrgica Temporal**: Si un Cliente Pareto A entra en Alerta Crtica el sistema identifica su ventana de tiempo preferida por ejemplo **del 1 al 10** Marketing puede automatizar un disparo de retención el día 2 de ese mes, ganándole de mano a la 
inactividad.
2. **Blindaje de Clientes Top (Fuga Silenciosa)**: Pareto A con compras estables pero satisfacción <**4pts** alerta automática para el equipo de CX (Customer Experience) antes de que el malestar se traduzca en abandono. 
3. **Optimización Presupuesto** Bonificacion alto costo solo para clientes A/B en alerta, segmento C se aplican flujos digitales de bajo costo.

-----
## Herramientas y Técnicas Utilizadas
- **SQL Avanzado**: Cross Join para grilla calendario, CTEs, Funciones Ventana LAG + AVG OVER, CASE WHEN
- **Análisis Pareto 80/20**: Segmentacio clientes por facturación + ventana 90 días 
- **Alertas de Retención**: Desvío vs promedio historico mendual 
- **Análisis Temporal**: Patrones consumo por periodo del mes
----

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
