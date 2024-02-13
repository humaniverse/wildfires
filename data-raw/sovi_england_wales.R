# ---- CREATION OF SOCIAL VULNERABILITY INDEX WITH PCA (ENGLAND & WALES) ----

# Code from Github repository:
# https://anonymous.4open.science/r/Msc-Dissertation-60BC/

# ---- Setup ----
devtools::load_all(".")
library(tidyverse)
library(psych)

# ---- Data Standardisation ----
data(indic_msoa_eng_wales)

scaled_df <- indic_msoa_eng_wales |>
  select(-msoa_code, -msoa_name) |>
  mutate_all(~ scale(.))

# ---- PCA ----
pca_varimax <- principal(scaled_df, nfactors = 5, rotate = "varimax")

# Check variance explained
eigenvalues <- pca_varimax$values
variance_proportion <- eigenvalues / sum(eigenvalues)

# Check loadings
factor_loadings <- pca_varimax$loadings
loadings_table <- data.frame(
  Variable = colnames(scaled_df),
  Factor1 = factor_loadings[, 1],
  Factor2 = factor_loadings[, 2],
  Factor3 = factor_loadings[, 3],
  Factor4 = factor_loadings[, 4],
  Factor5 = factor_loadings[, 5]
)

# ---- Creation of the Social Vulnerability Index ----
scores <- as.data.frame(pca_varimax$scores)
scores$SoVI <- ((scores$RC1 * 0.4331856253) + (scores$RC2 * 0.2174490076) + (scores$RC3 * 0.0742024742) + (scores$RC4 * 0.0640479196) + (scores$RC5 * 0.0438841052)) / (0.4331856253 + 0.2174490076 + 0.0742024742 + 0.0640479196 + 0.0438841052)

sovi_england_wales <- tibble(
  msoa_code = indic_msoa_eng_wales$msoa_code,
  msoa_name = indic_msoa_eng_wales$msoa_name,
  SoVI = scores$SoVI,
  SoVI_standardised = scale(scores$SoVI)[,1]
)

# ---- Save dataset ----
usethis::use_data(sovi_england_wales, overwrite = TRUE)
