
#Módulo 2. Realizar una auditoría de calidad de los datos aplicando técnicas de limpieza

# Instalación de paquetes

install.packages("readr")
install.packages("here")
install.packages("dplyr")
install.packages("tidyverse")
install.packages("tible")
install.packages("tidyr")
install.packages("janitor")
install.packages("skimr")


# Carga de librerías

library(readr)
library(here)
library(dplyr)
library(tidyverse)
library(tibble)
library(tidyr)
library(janitor)
library(skimr)


# 1. INGESTA DE DATOS

# 1.1. Carga del dataset en archio CSV

datos_incendios_csv <- read_csv(here("data", "raw", "incendios1.csv"), locale =locale(encoding = "UTF-8"))


# 2. AUDITORÍA DEL DATASET

# 2.1. Inspección de la estructura del dataset

str(datos_incendios_csv)
glimpse(datos_incendios_csv)
summary(datos_incendios_csv)
skim(datos_incendios_csv)
dim(datos_incendios_csv)

# 2.2 Búsqueda de inconsistencias

duplicated(datos_incendios_csv)
unique(datos_incendios_csv)

# 3. DOCUMENTACIÓN DE LO ENCONTRADO

# 3.1 Qué se encontró

# Hay inconsistencias en los nombres de las columnas, por ejemplo, en algunos casos dice 
# "Clave" y en otros casos deice "CVE".

# Hay columnas con valores numéricos, específicamente "0" en lugar de cadenas de texto.

# Se encontraron varias columnas con valores nulos (NA) en todas sus filas.

# No se encontraron datos duplicados.


# 3.2 Qué hacer y por qué

# Normalizar los nombres de las columnas para evitar confusiones con determinados términos.

# Reemplazar "cve" por "clave" en los nombres de las columnas para homogenizar los términos usados y evitar confusiones.

# Eliminar la columnas connombres diferentes pero con datos repetidos

# Normalizar textos para para homogenizar nombres en minúsculas, pues la mayoría están en minúscula 
# la primera letra y minúsculas las demás y algunos completamente en mayúsculas.

# Reemplazar el valor numérico "0" por "Desconocida" en las columnas "causa" y "causa_especifica" para no 
# tener confusiones entre este número y los caracteres.

# Eliminar las columnas con datos nulos porque no aportan ninguna información al análisis.


# 4. LIMPIEZA DE DATOS

# 4.1 Normalizar nombres de columnas

datos_normalizados_csv <-janitor::clean_names(datos_incendios_csv)


# 4.2 Normalizar textos en columna "predio"

datos_normalizados_csv$predio <- str_to_lower(datos_normalizados_csv$predio)


# 4.3 Renombrar columnas (clave en lugar de cve)

colnames(datos_normalizados_csv)[c(1, 2, 5, 8, 9, 10)] <- c("año", "clave_incendio", "clave_municipio_repetida", "clave_entidad", "clave_municipio", "clave_geografica")


# 4.4 Eliminar columnas con datos repetidos "clave_municipio_repetida" y "entidad" por presentar los mismos datos que la columna "clave_municipio"
# y la columna "estado", respectivamente.

datos_normalizados_csv <- datos_normalizados_csv %>%
  select(-clave_municipio_repetida)

datos_normalizados_csv <- datos_normalizados_csv %>%
  select(-entidad)


# 4.5 Reemplazar el caracter numérico "0" por "Desconocida" en las columnas causa y causa_especifica

datos_normalizados_csv <- datos_normalizados_csv %>%
  mutate(causa = case_when(causa == "0" ~ "Desconocida", TRUE ~ causa))

datos_normalizados_csv <- datos_normalizados_csv %>%
  mutate(causa_especifica = case_when(causa_especifica == "0" ~ "Desconocida", TRUE ~ causa_especifica))

# 4.6 Eliminar columnas con NA (el nombre de todas empieza con "fn_")

datos_limpios_csv <- datos_normalizados_csv %>% select(-starts_with("fn_"))


