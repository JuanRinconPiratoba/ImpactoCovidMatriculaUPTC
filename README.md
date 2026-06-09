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

## Principales Resultados
Los resultados del DiD simple y del DiD con efectos fijos muestran un efecto negativo y  estadísticamente significativo para el grupo de tratamiento en el periodo post-pandemia. Una vez se controlan las tendencias generales y la heterogeneidad entre programas, se evidencia 
que la modalidad presencial fue la más afectada por el choque de 2020, mientras que la modalidad virtual mostró una mayor capacidad de adaptación en el corto plazo. 
No obstante, el análisis del supuesto de tendencias paralelas mediante un Event Study para el periodo completo 2015–2021 revela que este supuesto no se cumple plenamente. Se identifican pre-tendencias significativas en algunos años previos a la pandemia, asociadas 
principalmente a la alta volatilidad de la matrícula virtual antes de 2020, lo que obliga a interpretar con cautela los resultados obtenidos en el periodo largo. Para corregir este problema y fortalecer la validez causal del ejercicio, el análisis se restringió al periodo 2017–2021. Esta restricción mejora sustancialmente el cumplimiento del supuesto de paralelismo, ya que los coeficientes pre-tratamiento son estadísticamente indistinguibles de cero al nivel del 5%, aunque persiste una significancia marginal en 2018. Aun así, este ajuste permite una interpretación causal más creíble de los efectos estimados.

##  Estructura del Repositorio
* `/ModeloDiD.R`: Script principal en R que contiene la limpieza de datos, estadísticas descriptivas, estimación del modelo de Diferencias en Diferencias y gráficos de tendencias paralelas.
* `/Trabajo Final Evaluación de Impacto.pdf`: Documento metodológico extenso con el marco teórico, revisión de literatura, tablas de regresión completas y conclusiones analíticas.
