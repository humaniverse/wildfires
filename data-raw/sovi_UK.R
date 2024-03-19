# ---- CREATION OF SOCIAL VULNERABILITY INDEX WITH PCA ----

# Code from Github repository:
# https://anonymous.4open.science/r/Msc-Dissertation-60BC/

# ---- Setup ----
# devtools::load_all(".")
library(tidyverse)
library(psych)
library(ggcorrplot)
library(factoextra)
library(sf)

# ==========================
# ---- ENGLAND & WALES ----
data(indic_msoa_eng_wales)

# ---- Prepare and test data for PCA  ----
# Scale using z-score
scaled_df <- indic_msoa_eng_wales |>
  select(-msoa_code, -msoa_name) |>
  mutate_all(~ scale(.))

# Visualise correlation
# Visually confirm that indicators are correlated
corr_matrix <- cor(scaled_df)
ggcorrplot(corr_matrix) # Quite a few indicators are correlated

# KMO and Bartlett's test
# KMO score is 0.78, which is >0.6 indicating variables overlap and there is partial correlation
# Barlett's test p-value is less than 0, reject null hypothesis that there is no correlation
kmo_result <- KMO(scaled_df)
bartlett_result <- cortest.bartlett(scaled_df)
print(kmo_result)
print(bartlett_result)

# ---- PCA ----
# Instantiate model using varimax to increase interpretability + reduce # variables
pca <- principal(scaled_df, nfactors = 5, rotate = "varimax")

# Check variance explained
eigenvalues <- pca$values
variance_proportion <- eigenvalues / sum(eigenvalues)
print(variance_proportion)

# Check loadings
factor_loadings <- pca$loadings
loadings_table <- data.frame(
  Variable = colnames(scaled_df),
  Factor1 = factor_loadings[, 1],
  Factor2 = factor_loadings[, 2],
  Factor3 = factor_loadings[, 3],
  Factor4 = factor_loadings[, 4],
  Factor5 = factor_loadings[, 5]
)

# ---- Creation of the Social Vulnerability Index ----
scores <- as.data.frame(pca$scores)

# SoVI score = each rotated component * its variance / cum variance
scores$SoVI <- ((scores$RC1 * variance_proportion[1]) +
  (scores$RC2 * variance_proportion[2]) +
  (scores$RC3 * variance_proportion[3]) +
  (scores$RC4 * variance_proportion[4]) +
  (scores$RC5 * variance_proportion[5]) /
    (variance_proportion[1] + variance_proportion[2] + variance_proportion[3] + variance_proportion[4]))

sovi_england_wales <- tibble(
  msoa21_code = indic_msoa_eng_wales$msoa_code,
  msoa21_name = indic_msoa_eng_wales$msoa_name,
  SoVI = scores$SoVI
)

sovi_england <- sovi_england_wales |>
  filter(grepl("^E", msoa21_code)) |>
  mutate(SoVI_standardised = scale(SoVI)[, 1])

sovi_wales <- sovi_england_wales |>
  filter(grepl("^W", msoa21_code)) |>
  mutate(SoVI_standardised = scale(SoVI)[, 1])

# ---- Save datasets ----
usethis::use_data(sovi_england, overwrite = TRUE)
usethis::use_data(sovi_wales, overwrite = TRUE)

# ==========================
# ---- NORTHERN IRELAND ----
data(indic_sdz_ni)

# ---- Prepare and test data for PCA  ----
# Scale using z-score
scaled_df <- indic_sdz_ni |>
  select(-sdz21_code) |>
  mutate_all(~ scale(.))

# Visualise correlation
# Visually confirm that indicators are correlated
corr_matrix <- cor(scaled_df)
ggcorrplot(corr_matrix) # Quite a few indicators are correlated

# KMO and Bartlett's test
# KMO score is 0.78, which is >0.6 indicating variables overlap and there is partial correlation
# Barlett's test p-value is less than 0, reject null hypothesis that there is no correlation
kmo_result <- KMO(scaled_df)
bartlett_result <- cortest.bartlett(scaled_df)
print(kmo_result)
print(bartlett_result)

# ---- PCA ----
# Instantiate model using varimax to increase interpretability + reduce # variables
pca <- principal(scaled_df, nfactors = ncol(scaled_df), rotate = "varimax")

# Identify % variance explained by each component
eigenvalues <- pca$values
variance_proportion <- eigenvalues / sum(eigenvalues)
print(variance_proportion)

# Plot scree to identify number of PC to retain
screeplot <-
  plot(1:length(eigenvalues),
    eigenvalues,
    type = "b",
    pch = 19,
    xlab = "Component Number",
    ylab = "Eigenvalue",
    main = "Scree Plot",
    frame.plot = TRUE,
    xlim = c(1, length(eigenvalues)),
    ylim = c(0, max(eigenvalues))
  )
# Elbow is around 3-4  PCs, 5th PC is <1 so, retain 4 PCs

# View correlations between each variable and the PCs using loadings
# Use 4 PCs
factor_loadings <- pca$loadings
loadings_table <- data.frame(
  Variable = colnames(scaled_df),
  Factor1 = factor_loadings[, 1],
  Factor2 = factor_loadings[, 2],
  Factor3 = factor_loadings[, 3],
  Factor4 = factor_loadings[, 4]
)

# ---- Creation of the Social Vulnerability Index ----
# Create df of PCA scores per SDZ
scores <- as.data.frame(pca$scores)

# SoVI score = each rotated component * its variance / cum variance
scores$SoVI <- ((scores$RC1 * variance_proportion[1]) +
  (scores$RC2 * variance_proportion[2]) +
  (scores$RC3 * variance_proportion[3]) +
  (scores$RC4 * variance_proportion[4]) /
    (variance_proportion[1] + variance_proportion[2] + variance_proportion[3] + variance_proportion[4]))

sovi_ni <- tibble(
  sdz21_code = indic_sdz_ni$sdz21_code,
  SoVI = scores$SoVI,
  SoVI_standardised = scale(scores$SoVI)[, 1]
) |>
  left_join(geographr::boundaries_sdz21) |>
  st_drop_geometry() |>
  select(-geometry) |>
  relocate(sdz21_name, .after = sdz21_code)

# ---- Save dataset ----
usethis::use_data(sovi_ni, overwrite = TRUE)

# ==========================
# ---- SCOTLAND ----
data(indic_msoa_scotland)

# ---- Prepare and test data for PCA  ----
# Scale using z-score
scaled_df <- indic_msoa_scotland |>
  ungroup() |>
  select(-iz11_code, -iz11_name) |>
  mutate_all(~ scale(.))

# Visualise correlation
# Visually confirm that indicators are correlated
corr_matrix <- cor(scaled_df)
ggcorrplot(corr_matrix) # Quite a few indicators are correlated

# KMO and Bartlett's test
# KMO score is 0.89, which is >0.6 indicating variables overlap and there is partial correlation
# Barlett's test p-value is 0, reject null hypothesis that there is no correlation
kmo_result <- KMO(scaled_df)
bartlett_result <- cortest.bartlett(scaled_df)
print(kmo_result)
print(bartlett_result)

# ---- PCA ----
# Instantiate model using varimax to increase interpretability + reduce # variables
pca <- principal(scaled_df, nfactors = ncol(scaled_df), rotate = "varimax")

# Identify % variance explained by each component
eigenvalues <- pca$values
variance_proportion <- eigenvalues / sum(eigenvalues)
print(variance_proportion)

# Plot scree to identify number of PC to retain
screeplot <-
  plot(1:length(eigenvalues),
    eigenvalues,
    type = "b",
    pch = 19,
    xlab = "Component Number",
    ylab = "Eigenvalue",
    main = "Scree Plot",
    frame.plot = TRUE,
    xlim = c(1, length(eigenvalues)),
    ylim = c(0, max(eigenvalues))
  )
# Elbow is around 3-4  PCs, 4th PC is >1 so, retain 4 PCs

# View correlations between each variable and the PCs using loadings
# Use 4 PCs
factor_loadings <- pca$loadings
loadings_table <- data.frame(
  Variable = colnames(scaled_df),
  Factor1 = factor_loadings[, 1],
  Factor2 = factor_loadings[, 2],
  Factor3 = factor_loadings[, 3],
  Factor4 = factor_loadings[, 4]
)

# ---- Creation of the Social Vulnerability Index ----
# Create df of PCA scores per SDZ
scores <- as.data.frame(pca$scores)

# SoVI score = each rotated component * its variance / cum variance
scores$SoVI <- ((scores$RC1 * variance_proportion[1]) +
  (scores$RC2 * variance_proportion[2]) +
  (scores$RC3 * variance_proportion[3]) +
  (scores$RC4 * variance_proportion[4]) /
    (variance_proportion[1] + variance_proportion[2] + variance_proportion[3] + variance_proportion[4]))

sovi_scotland <- tibble(
  iz11_code = indic_msoa_scotland$iz11_code,
  iz11_name = indic_msoa_scotland$iz11_name,
  SoVI = scores$SoVI,
  SoVI_standardised = scale(scores$SoVI)[, 1]
)

# ---- Save dataset ----
usethis::use_data(sovi_scotland, overwrite = TRUE)
