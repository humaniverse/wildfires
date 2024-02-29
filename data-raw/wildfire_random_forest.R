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
background_points_spring <- spsample(countries_uk_sp, n=9448, "random")
background_points_summer <- spsample(countries_uk_sp, n=5221, "random")

# ---- More raster processing ----
# SPRING
# Raster extraction from the environmental covariates on to points
uk_fires_env_spring <- raster::extract(zscore_spring_stack, fires_spring_uk)
background_points_env_spring <- raster::extract(zscore_spring_stack, background_points_spring)

# Convert large matrix objects to data frame objects and add outcome `fire` indicator
uk_fires_env_spring <- data.frame(uk_fires_env_spring, fire = 1)
background_points_env_spring <-data.frame(background_points_env_spring, fire = 0)

# SUMMER
uk_fires_env_summer <- raster::extract(zscore_summer_stack, fires_summer_uk)
background_points_env_summer <- raster::extract(zscore_summer_stack, background_points_summer)

uk_fires_env_summer <-data.frame(uk_fires_env_summer, fire = 1)
background_points_env_summer <-data.frame(background_points_env_summer, fire = 0)

# ---- SPLITTING THE DATA ----
set.seed(20000430)
# SPRING
# split data into 4 equal parts: 25% for test, 75% for training
select <- kfold(uk_fires_env_spring, 4)
uk_fires_env_spring_test <- uk_fires_env_spring[select==1,]
uk_fires_env_spring_train <- uk_fires_env_spring[select!=1,]

# repeat the process for the background points
select2 <- kfold(background_points_env_spring, 4)
background_points_env_spring_test <- background_points_env_spring[select2==1,]
background_points_env_spring_train <- background_points_env_spring[select2!=1,]

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
uk_fires_env_summer_test <- uk_fires_env_summer[select3==1,]
uk_fires_env_summer_train <- uk_fires_env_summer[select3!=1,]

# repeat the process for the background points
select4 <- kfold(background_points_env_summer, 4)
background_points_env_summer_test <- background_points_env_summer[select4==1,]
background_points_env_summer_train <- background_points_env_summer[select4!=1,]

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

confusion_matrix <- table(predictions_spring, testing_data_spring$fire)

print(confusion_matrix)
print(paste0("Accuracy: ",  sum(diag(confusion_matrix)) / sum(confusion_matrix)))
print(paste0("Precision: ", confusion_matrix[2, 2] / sum(confusion_matrix[, 2])))
print(paste0("Recall: ", confusion_matrix[2, 2] / sum(confusion_matrix[2, ])))

# SUMMER
rf_model_summer <- randomForest(fire ~ ., data = training_data_summer)

# Evaluate performances
predictions_summer <- predict(rf_model_summer, newdata = testing_data_summer)

confusion_matrix <- table(predictions_summer, testing_data_summer$fire)

print(confusion_matrix)
print(paste0("Accuracy: ",  sum(diag(confusion_matrix)) / sum(confusion_matrix)))
print(paste0("Precision: ", confusion_matrix[2, 2] / sum(confusion_matrix[, 2])))
print(paste0("Recall: ", confusion_matrix[2, 2] / sum(confusion_matrix[2, ])))