# ---- WILDFIRE PREDICTION USING RANDOM FOREST ----
# ---- SETUP ----
library("sf")
library("raster")
library("tidyverse")

devtools::load_all(".")

data("spring_independent_var_stack")
data("summer_independent_var_stack")
data("fires_spring_uk")
data("fires_summer_uk")


