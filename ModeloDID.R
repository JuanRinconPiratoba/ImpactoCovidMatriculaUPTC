
# Script R: Diferencias en Diferencias (DID) - UPTC (Boyacá)
# Objetivo: ejecutar DID (presencial vs virtual) sobre Total Matriculados (2015-2021)


# ---------------------------
# 0) Paquetes requeridos
# ---------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, tidyr, ggplot2, fixest, janitor, broom, scales)


# ---------------------------
# 1) Cargar datos
# ---------------------------
# Se asume que el archivo Excel se llama 'base.xlsx' y está en el directorio de trabajo.
# Si tu archivo tiene otro nombre de hoja, ajusta sheet = "NombreHoja".
base <- readxl::read_excel("./base.xlsx")


# Echar un vistazo rápido
glimpse(base)
colnames(base)

# Limpiar nombres
base <- janitor::clean_names(base)

# ---------------------------
# 2) Preparar variables (treatment, post, labels)
# ---------------------------

# Renombrar año si viene con tilde
if ("año" %in% colnames(base)) {
  base <- base %>% dplyr::rename(ano = `año`)
}

# Convertir tipos
base <- base %>% 
  mutate(
    id_programa = as.character(id_programa),
    ano = as.integer(ano),
    idmetodologia = as.integer(idmetodologia),
    total_matriculados = as.numeric(total_matriculados)
  )

# ---------------------------
# NUEVA LÓGICA DE TRATAMIENTO (RECOMENDADA)
# treatment = 1 si metodología PRESENCIAL
# Virtual (3) sirve como grupo control
# ---------------------------
base <- base %>% 
  mutate(
    treatment = ifelse(idmetodologia == 1, 1, 0),     # 1 = PRESENCIAL
    post = ifelse(ano >= 2020, 1, 0),                # periodo post-COVID
    modality_label = case_when(
      idmetodologia == 1 ~ "Presencial",
      idmetodologia == 2 ~ "Semipresencial",
      idmetodologia == 3 ~ "Virtual",
      TRUE ~ "Otro"
    )
  )

# Mantener SOLO presencial y virtual
data_did <- base %>% filter(idmetodologia %in% c(1, 3)) %>%
  arrange(id_programa, ano)

# ---------------------------
# 3) Descriptiva básica
# ---------------------------
sample_sizes <- data_did %>% 
  group_by(treatment, post) %>% 
  summarise(
    n_programas = n_distinct(id_programa),
    obs = n(),
    .groups = "drop"
  )
print(sample_sizes)

# Promedios por año para gráficos
group_year <- data_did %>% 
  group_by(modality_label, ano) %>% 
  summarise(
    avg_matriculados = mean(total_matriculados, na.rm = TRUE),
    median_matriculados = median(total_matriculados, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# ---------------------------
# 4) Tendencias paralelas (pre y completo)
# ---------------------------
p_trends <- ggplot(group_year, aes(x = ano, y = avg_matriculados,
                                   color = modality_label,
                                   group = modality_label)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(title = "Promedio de matriculados por modalidad (2015–2021)",
       x = "Año", y = "Promedio de Matriculados") +
  theme_minimal()

print(p_trends)

# Pre COVID (2015–2019)
group_pre <- group_year %>% filter(ano <= 2019)

p_pre <- ggplot(group_pre, aes(x = ano, y = avg_matriculados,
                               color = modality_label,
                               group = modality_label)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(title = "Pre-trends: promedio de matriculados (2015–2019)",
       x = "Año", y = "Promedio de Matriculados") +
  theme_minimal()

print(p_pre)

# Post COVID (2020–2021)
group_post <- group_year %>% filter(ano >= 2020)

p_post <- ggplot(group_post,
                 aes(x = ano,
                     y = avg_matriculados,
                     color = modality_label,
                     group = modality_label)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(
    title = "Post-COVID: promedio de matriculados (2020–2021)",
    x = "Año",
    y = "Promedio de matriculados",
    color = "Modalidad"
  ) +
  theme_minimal()

print(p_post)


# ---------------------------
# 5) DID simple
# ---------------------------
model_simple <- lm(total_matriculados ~ treatment + post + treatment:post,
                   data = data_did)
summary(model_simple)


library(stargazer)
stargazer(
  model_simple,
  type = "html",
  out  = "DID_simple_matriculados.html",
  
  title = "Modelo DID simple: efecto de la virtualidad sobre matriculados",
  
  dep.var.labels = "Total de matriculados",
  
  covariate.labels = c(
    "Tratamiento (Virtual)",
    "Post-pandemia",
    "Tratamiento × Post"
  ),
  
  omit.stat = c("f", "ser"),
  digits = 3
)


# ---------------------------
# 6) DID con efectos fijos
# ---------------------------
model_fe <- fixest::feols(
  total_matriculados ~ treatment*post | id_programa + ano,
  data = data_did,
  cluster = "id_programa"
)
summary(model_fe)

modelsummary(
  model_fe,
  output = "tabla_did_clasico.html", # Nombre del archivo
  stars = TRUE, # Muestra las estrellas de significancia (***, **, *)
  coef_map = c("treatment:post" = "Efecto DiD (Tratado x Post)"), # Renombra la variable clave
  gof_map = c("nobs", "adj.r.squared", "rmse", "fe") # Incluye N, R2, RMSE y los Efectos Fijos (fe)
)
# ---------------------------
# 7) DID manual (para explicación en el informe)
# ---------------------------
avg_pre_post <- data_did %>% 
  mutate(period = ifelse(post == 1, "After", "Before")) %>% 
  group_by(modality_label, period) %>% 
  summarise(avg = mean(total_matriculados, na.rm = TRUE), .groups = "drop")

pres_before <- avg_pre_post %>% filter(modality_label == "Presencial", period == "Before") %>% pull(avg)
pres_after  <- avg_pre_post %>% filter(modality_label == "Presencial", period == "After") %>% pull(avg)
virt_before <- avg_pre_post %>% filter(modality_label == "Virtual", period == "Before") %>% pull(avg)
virt_after  <- avg_pre_post %>% filter(modality_label == "Virtual", period == "After") %>% pull(avg)

pres_change <- pres_after - pres_before
virt_change <- virt_after - virt_before
did_manual <- pres_change - virt_change

print(avg_pre_post)
print(paste("DID manual:", round(did_manual,3)))

# ---------------------------
# 8) Robustez con controles
# ---------------------------
model_fe_controls <- fixest::feols(
  total_matriculados ~ treatment*post +
    factor(idnivelformacion) + factor(idarea) |
    id_programa + ano,
  data = data_did,
  cluster = "id_programa"
)
summary(model_fe_controls)
modelsummary(
  model_fe_controls,
  output = "tabla_did_controles.html", # Nombre del archivo
  stars = TRUE,
  coef_map = c("treatment:post" = "Efecto DiD (Tratado x Post)"), # Renombra la variable clave
  gof_map = c("nobs", "adj.r.squared", "rmse", "fe")
)
# ---------------------------
# 9) Event Study (test formal de paralelismo)
# ---------------------------
event_model <- feols(
  total_matriculados ~ i(ano, treatment, ref = 2019) |
    id_programa,
  cluster = "id_programa",
  data = data_did
)

iplot(event_model)

# Guardar objetos
saveRDS(model_fe, "model_fe.rds")
saveRDS(model_fe_controls, "model_fe_controls.rds")
write.csv(group_year, "group_year_avg.csv", row.names = FALSE)

# FIN DEL SCRIPT

# ---------------------------
# 10) Corrección pre-trends con group-specific trends
# ---------------------------

# Modelo con tendencias individuales por modalidad
# Se permite que cada grupo (treatment/control) tenga su propia pendiente temporal
# model_trend <- fixest::feols(
#   total_matriculados ~ treatment*post + treatment:ano +
#     factor(idnivelformacion) + factor(idarea) + factor(idnucleo) |
#     id_programa,
#   data = data_did,
#   cluster = "id_programa"
# )
# 
# summary(model_trend)
# 
# # Guardar tabla de resultados
# write.csv(broom::tidy(model_trend), "did_trend_corrected_results.csv", row.names = FALSE)

#segunda opción para corregir este supuesto
# Restringir la muestra a 2017-2021
data_did_restricted <- data_did %>% filter(ano >= 2017)

# Event Study corregido en periodo restringido
event_model_restricted <- feols(
  total_matriculados ~ i(ano, treatment, ref = 2019) |
    id_programa,
  cluster = "id_programa",
  data = data_did_restricted
)

# Ver resumen
summary(event_model_restricted)

library(modelsummary)
modelsummary(
  event_model_restricted,
  output = "tabla_modelo_sustentacion.html", # El archivo que puedes abrir
  stars = TRUE, # Muestra las estrellas de significancia (***, **, *)
  coef_map = c("ano::2017:treatment" = "2017 (Pre-Tto)",
               "ano::2018:treatment" = "2018 (Pre-Tto)",
               "ano::2020:treatment" = "2020 (Post-Tto)",
               "ano::2021:treatment" = "2021 (Post-Tto)"), # Renombra las variables
  gof_map = c("nobs", "adj.r.squared", "rmse") # Solo muestra N, R2 y RMSE
)
# Gráfico estático con coefplot para mejor visibilidad
coefplot(event_model_restricted, keep = "treatment",
         main = "Event Study (2017-2021): efecto sobre matriculados por año",
         xlab = "Año", ylab = "Efecto sobre matriculados",
         ylim = c(-5, 10))

# 12) Recalcular promedios y porcentajes 2017-2021
# ---------------------------

# ---------------------------
# BLOQUE FINAL: MODELO RESTRINGIDO 2017-2021
# ---------------------------

library(dplyr)
library(fixest)
library(ggplot2)
library(coefplot)

# 1) Restringir la base a 2017-2021
data_restricted <- data_did %>% filter(ano >= 2017)

# 2) Promedio de matriculados por modalidad y año
avg_by_modality_year <- data_restricted %>%
  group_by(modality_label, ano) %>%
  summarise(
    avg_matriculados = mean(total_matriculados, na.rm = TRUE),
    .groups = "drop"
  )

# 3) Total de matriculados por año
total_by_year <- data_restricted %>%
  group_by(ano) %>%
  summarise(
    total_matriculados_year = sum(total_matriculados, na.rm = TRUE),
    .groups = "drop"
  )

# 4) Porcentaje de matriculados por modalidad y año
percent_by_modality_year <- avg_by_modality_year %>%
  left_join(total_by_year, by = "ano") %>%
  mutate(
    perc_total = (avg_matriculados / total_matriculados_year) * 100
  )

# 5) Guardar tablas para informe
write.csv(avg_by_modality_year, "avg_by_modality_year.csv", row.names = FALSE)
write.csv(percent_by_modality_year, "percent_by_modality_year.csv", row.names = FALSE)

# 6) Modelo Event Study restringido (2017-2021)
event_model_restricted <- feols(
  total_matriculados ~ i(ano, treatment, ref = 2019) |
    id_programa,
  cluster = "id_programa",
  data = data_restricted
)

# 7) Resumen del modelo
summary(event_model_restricted)

# 8) Extraer coeficientes
coefs_df <- broom::tidy(event_model_restricted) %>%
  filter(grepl("treatment", term))  # solo los coef de treatment

# Graficar
ggplot(coefs_df, aes(x = term, y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = estimate - 1.96*std.error,
                    ymax = estimate + 1.96*std.error), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Event Study: efecto sobre matriculados por año (2017-2021)",
       x = "Año", y = "Efecto sobre matriculados") +
  theme_minimal()


# 9) Guardar modelo
saveRDS(event_model_restricted, "event_model_restricted.rds")
