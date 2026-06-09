# Impacto del COVID-19 en la Matrícula Académica de la UPTC 

Este proyecto evalúa el **efecto causal** del choque inducido por la pandemia de COVID-19 sobre el número de estudiantes matriculados por programa académico en la Universidad Pedagógica y Tecnológica de Colombia (UPTC), sedes de Boyacá.

La investigación utiliza métodos econométricos de evaluación de impacto para aislar el efecto de la crisis sanitaria de otras tendencias macroeconómicas o sectoriales.

---

## Objetivo del Proyecto
Cuantificar el impacto del choque del COVID-19 en la deserción o atracción de estudiantes a nivel de programa académico, identificando si existieron diferencias heterogéneas según el área de conocimiento o la modalidad del programa.

## Metodología Econométrica
Para la identificación del efecto causal, se implementó un modelo de **Diferencias en Diferencias (Diff-in-Diff / DiD)**. 

* **Grupo de Tratamiento:**.
* **Grupo de Control:**.
* **Variables de Control:** 

El análisis asume el cumplimiento del supuesto de **tendencias paralelas** en el periodo pre-tratamiento.

##  Tecnologías y Herramientas Utilizadas
* **Rstudio:** Procesamiento de datos, estimación del modelo econométrico y pruebas de robustez.
* **Paquetes clave:** `tidyverse` (limpieza), `fixest` o `plm` (modelos de panel/efectos fijos), `ggplot2` (visualización).
* **Fuentes de datos:** Datos institucionales de matrícula de la UPTC / SNIES.

## 📈 Principales Resultados
*(Tip: Agrega un breve resumen de lo que encontraste. Esto demuestra capacidad de análisis y síntesis).*
* Se observó una [reducción/incremento] promedio del **X%** en la matrícula de primer ingreso durante el periodo crítico de la pandemia.
* Los programas del área de [Ej: Ciencias de la Salud o Ingenierías] mostraron mayor resiliencia en comparación con [...].
* Se evidenció que el efecto del choque [se disipó en el mediano plazo / persistió en los años posteriores].

##  Estructura del Repositorio
* `/ModeloDiD.R`: Script principal en R que contiene la limpieza de datos, estadísticas descriptivas, estimación del modelo de Diferencias en Diferencias y gráficos de tendencias paralelas.
* `/Trabajo Final Evaluación de Impacto.pdf`: Documento metodológico extenso con el marco teórico, revisión de literatura, tablas de regresión completas y conclusiones analíticas.
