# ---- CREATION OF SOCIAL VULNERABILITY INDEX WITH PCA (NI) ----

# Code from Github repository:
# https://anonymous.4open.science/r/Msc-Dissertation-60BC/

# ---- Setup ----
devtools::load_all(".")
library(tidyverse)
library(psych)
library(ggcorrplot)
library(factoextra)

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
pca <- principal(scaled_df, nfactors = ncol(scaled_df))

loadings <- pca$loadings
communalities <- pca$communality

eigenvalues <- pca$values
num_factors <- sum(eigenvalues > 1)

# Original PCA results
print(pca)







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
  msoa11_code = indic_msoa_eng_wales$msoa_code,
  msoa11_name = indic_msoa_eng_wales$msoa_name,
  SoVI = scores$SoVI,
  SoVI_standardised = scale(scores$SoVI)[,1]
)

# ---- Save dataset ----
usethis::use_data(sovi_england_wales, overwrite = TRUE)
