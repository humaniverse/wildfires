# ---- WILDFIRE PREDICTION USING RANDOM FOREST ----
# ---- SETUP ----
library("sf")
library("raster")
library("tidyverse")
library("randomForest")
library("dismo") # for kfold

devtools::load_all(".")

spring_stack <- spring_independent_var_stack
summer_stack <- summer_independent_var_stack
data("fires_spring_uk")
data("fires_summer_uk")

countries_uk_wgs84 <- geographr::boundaries_countries20 |>
  st_transform(crs = "+proj=longlat +datum=WGS84")

msoa <- geographr::boundaries_msoa21

iz <- geographr::boundaries_iz11 |>
  rename(
    msoa21_name = iz11_name,
    msoa21_code = iz11_code
  )

sdz <- geographr::boundaries_sdz21 |>
  rename(
    msoa21_name = sdz21_name,
    msoa21_code = sdz21_code
  )

msoa_uk <- rbind(msoa, iz, sdz) |>
  st_make_valid()

# ---- PRE-PROCESSING ----
# ---- Standardisation ----
zscore_spring_stack <- stack()
zscore_summer_stack <- stack()

# Iterate over each layer in the raster stack
for (i in 1:nlayers(spring_stack)) {
  layer <- spring_stack[[i]]
  zscore <- scale(layer)
  zscore_spring_stack <- addLayer(zscore_spring_stack, zscore)
  rm(layer, zscore)
}

for (i in 1:nlayers(summer_stack)) {
  layer <- summer_stack[[i]]
  zscore <- scale(layer)
  zscore_summer_stack <- addLayer(zscore_summer_stack, zscore)
  rm(layer, zscore)
}

rm(spring_stack, summer_stack)

# ---- Pseudo-background points as absence ----
set.seed(20000430)

# Coerce 'sf' object countries_uk_wgs84 into 'sp' object for spsample to work
countries_uk_sp <- as(countries_uk_wgs84, Class = "Spatial")

# spsample() generates twice number of fire occurrence points randomly within the border
# QUESTION: WHAT DOES N DO? Original are 5475 (spring) and 3157 (summer)
# I use the number of fires for my own data
background_points_spring <- spsample(countries_uk_sp, n = 9448, "random")
background_points_summer <- spsample(countries_uk_sp, n = 5221, "random")

# ---- More raster processing ----
# SPRING
# Raster extraction from the environmental covariates on to points
uk_fires_env_spring <- raster::extract(zscore_spring_stack, fires_spring_uk)
background_points_env_spring <- raster::extract(zscore_spring_stack, background_points_spring)

# Convert large matrix objects to data frame objects and add outcome `fire` indicator
uk_fires_env_spring <- data.frame(uk_fires_env_spring, fire = 1)
background_points_env_spring <- data.frame(background_points_env_spring, fire = 0)

# SUMMER
uk_fires_env_summer <- raster::extract(zscore_summer_stack, fires_summer_uk)
background_points_env_summer <- raster::extract(zscore_summer_stack, background_points_summer)

uk_fires_env_summer <- data.frame(uk_fires_env_summer, fire = 1)
background_points_env_summer <- data.frame(background_points_env_summer, fire = 0)

# ---- SPLITTING THE DATA ----
set.seed(20000430)
# SPRING
# split data into 4 equal parts: 25% for test, 75% for training
select <- kfold(uk_fires_env_spring, 4)
uk_fires_env_spring_test <- uk_fires_env_spring[select == 1, ]
uk_fires_env_spring_train <- uk_fires_env_spring[select != 1, ]

# repeat the process for the background points
select2 <- kfold(background_points_env_spring, 4)
background_points_env_spring_test <- background_points_env_spring[select2 == 1, ]
background_points_env_spring_train <- background_points_env_spring[select2 != 1, ]

training_data_spring <- rbind(uk_fires_env_spring_train, background_points_env_spring_train)
testing_data_spring <- rbind(uk_fires_env_spring_test, background_points_env_spring_test)

# Remove rows with null values
training_data_spring <- training_data_spring[complete.cases(training_data_spring), ]
testing_data_spring <- testing_data_spring[complete.cases(testing_data_spring), ]

# Convert the target variable to a factor
training_data_spring$fire <- as.factor(training_data_spring$fire)
testing_data_spring$fire <- as.factor(testing_data_spring$fire)

# SUMMER
select3 <- kfold(uk_fires_env_summer, 4)
uk_fires_env_summer_test <- uk_fires_env_summer[select3 == 1, ]
uk_fires_env_summer_train <- uk_fires_env_summer[select3 != 1, ]

# repeat the process for the background points
select4 <- kfold(background_points_env_summer, 4)
background_points_env_summer_test <- background_points_env_summer[select4 == 1, ]
background_points_env_summer_train <- background_points_env_summer[select4 != 1, ]

training_data_summer <- rbind(uk_fires_env_summer_train, background_points_env_summer_train)
testing_data_summer <- rbind(uk_fires_env_summer_test, background_points_env_summer_test)

# Remove rows with null values
training_data_summer <- training_data_summer[complete.cases(training_data_summer), ]
testing_data_summer <- testing_data_summer[complete.cases(testing_data_summer), ]

# Convert the target variable to a factor
training_data_summer$fire <- as.factor(training_data_summer$fire)
testing_data_summer$fire <- as.factor(testing_data_summer$fire)

# ---- RUN RANDOM FOREST MODEL ----
# SPRING
rf_model_spring <- randomForest(fire ~ ., data = training_data_spring)

# Evaluate performances
predictions_spring <- predict(rf_model_spring, newdata = testing_data_spring)

confusion_matrix_spring <- table(predictions_spring, testing_data_spring$fire)
accuracy_spring <- sum(diag(confusion_matrix_spring)) / sum(confusion_matrix_spring)
precision_spring <- confusion_matrix_spring[2, 2] / sum(confusion_matrix_spring[, 2])
recall_spring <- confusion_matrix_spring[2, 2] / sum(confusion_matrix_spring[2, ])
f1_score_spring <- 2 * (precision_spring * recall_spring) / (precision_spring + recall_spring)

print(confusion_matrix_spring)
print(paste0("Accuracy: ", accuracy_spring))
print(paste0("Precision: ", precision_spring))
print(paste0("Recall: ", precision_spring))
print(paste0("F1 Score: ", f1_score_spring))

# Feature Importance
ft_importance_spring <- importance(rf_model_spring)
ft_importance_perc_spring <- 100 * ft_importance_spring / sum(ft_importance_spring)
ft_importance_df_spring <-
  data.frame(
    Feature = row.names(ft_importance_spring),
    Importance = as.numeric(ft_importance_perc_spring)
  )

ft_importance_df_spring <-
  ft_importance_df_spring[order(ft_importance_df_spring$Importance, decreasing = TRUE), ]

# SUMMER
rf_model_summer <- randomForest(fire ~ ., data = training_data_summer)

# Evaluate performances
predictions_summer <- predict(rf_model_summer, newdata = testing_data_summer)

confusion_matrix_summer <- table(predictions_summer, testing_data_summer$fire)
accuracy_summer <- sum(diag(confusion_matrix_summer)) / sum(confusion_matrix_summer)
precision_summer <- confusion_matrix_summer[2, 2] / sum(confusion_matrix_summer[, 2])
recall_summer <- confusion_matrix_summer[2, 2] / sum(confusion_matrix_summer[2, ])
f1_score_summer <- 2 * (precision_summer * recall_summer) / (precision_summer + recall_summer)

print(confusion_matrix_summer)
print(paste0("Accuracy: ", accuracy_summer))
print(paste0("Precision: ", precision_summer))
print(paste0("Recall: ", precision_summer))
print(paste0("F1 Score: ", f1_score_summer))

# Feature Importance
ft_importance_summer <- importance(rf_model_summer)
ft_importance_perc_summer <- 100 * ft_importance_summer / sum(ft_importance_summer)
ft_importance_df_summer <-
  data.frame(
    Feature = row.names(ft_importance_summer),
    Importance = as.numeric(ft_importance_perc_summer)
  )

ft_importance_df_summer <-
  ft_importance_df_summer[order(ft_importance_df_summer$Importance, decreasing = TRUE), ]

# ---- CREATE SUMMER WILDFIRE RISK INDEX ----
# Assuming the independent variables used for training the model are in the same order as the raster stack bands
raster_df <- as.data.frame(zscore_summer_stack)
wildfire_probabilities <- predict(rf_model_summer, raster_df, type = "prob")

predicted_raster <- zscore_summer_stack[[1]] # Copy the first layer from the original raster stack
values(predicted_raster) <- wildfire_probabilities[, 2]

predicted_raster_cropped <- crop(predicted_raster, countries_uk_wgs84)
predicted_raster_masked <- mask(predicted_raster_cropped, countries_uk_wgs84)

# Aggregate to MSOA level
# Extract wildfire risk probabilities for each MSOA
msoa_probabilities <- raster::extract(predicted_raster, msoa_uk, fun = mean, na.rm = TRUE, df = TRUE)
msoa_with_probabilities <- cbind(msoa_uk, msoa_probabilities)

wildfire_risk <- msoa_with_probabilities |>
  st_drop_geometry() |>
  select(-ID) |>
  rename(wildfire_risk = Slope)

# Separate the different nations & impute missing values using higher geography
lookup_msoa_ltla <- geographr::lookup_msoa11_msoa21_ltla22 |>
  distinct(msoa21_code, ltla22_code)

lookup_iz_ltla <- geographr::lookup_dz11_iz11_ltla20 |> 
  distinct(iz11_code, ltla20_code)

wildfire_risk_england <- wildfire_risk |>
  filter(grepl("^E", msoa21_code)) |>
  left_join(lookup_msoa_ltla) |>
  group_by(ltla22_code) |>
  mutate(wildfire_risk = ifelse(
    is.na(wildfire_risk),
    mean(wildfire_risk, na.rm = TRUE),
    wildfire_risk
  )) |>
  ungroup() |> 
  # Isle of Scilly is it's own ltla, so still NA: give it mean risk of Penzance (E02003948)
  mutate(wildfire_risk = if_else(msoa21_code == "E02006781", 0.1846667, wildfire_risk),
         wildfire_risk_standardised = scale(wildfire_risk)[,1]) |> 
  select(-ltla22_code)

wildfire_risk_wales <- wildfire_risk |>
  filter(grepl("^W", msoa21_code)) |>
  left_join(lookup_msoa_ltla) |>
  group_by(ltla22_code) |>
  mutate(wildfire_risk = ifelse(
    is.na(wildfire_risk),
    mean(wildfire_risk, na.rm = TRUE),
    wildfire_risk
  )) |>
  ungroup() |> 
  mutate(wildfire_risk_standardised = scale(wildfire_risk)[,1]) |> 
  select(-ltla22_code)

wildfire_risk_scotland <- wildfire_risk |>
  filter(grepl("^S", msoa21_code)) |> 
  rename(iz11_code = msoa21_code,
         iz11_name = msoa21_name) |> 
  left_join(lookup_iz_ltla)|>
  group_by(ltla20_code) |>
  mutate(wildfire_risk = ifelse(
    is.na(wildfire_risk),
    mean(wildfire_risk, na.rm = TRUE),
    wildfire_risk
  )) |>
  ungroup() |> 
  mutate(wildfire_risk_standardised = scale(wildfire_risk)[,1]) |> 
  select(-ltla20_code)
  
wildfire_risk_ni <- wildfire_risk |>
  filter(grepl("^N", msoa21_code)) |> 
  rename(iz11_code = msoa21_code,
         iz11_name = msoa21_name) |> 
  left_join(lookup_iz_ltla)|>
  group_by(ltla20_code) |>
  mutate(wildfire_risk = ifelse(
    is.na(wildfire_risk),
    mean(wildfire_risk, na.rm = TRUE),
    wildfire_risk
  )) |>
  ungroup() |> 
  mutate(wildfire_risk_standardised = scale(wildfire_risk)[,1]) |> 
  select(-ltla20_code)

# Save datasets
usethis::use_data(wildfire_risk_england, overwrite = TRUE)
usethis::use_data(wildfire_risk_wales, overwrite = TRUE)
usethis::use_data(wildfire_risk_scotland, overwrite = TRUE)
