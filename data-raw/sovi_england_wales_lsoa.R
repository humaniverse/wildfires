# ---- Creation of socioeconomic vulnerability dataset for England & Wales ----

# Data sourced from Github repository: 
# https://anonymous.4open.science/r/Msc-Dissertation-60BC/

# ---- Setup ----
library(tidyverse)
library(janitor)

msoa <- read_csv("data/msoa/msoa_21.csv") |> 
  select(msoa_code = MSOA21CD,
         msoa_name = MSOA21CD)

# ---- Age ----
age <- read_csv("data/age_msoa.csv") |>
  clean_names() |>
  select(
    msoa_code = middle_layer_super_output_areas_code,
    age_code = age_6_categories_code,
    age_number = observation
  ) |>
  pivot_wider(names_from = age_code, values_from = age_number) |>
  rename(
    age_15below = "1",
    age_2 = "2",
    age_3 = "3",
    age_4 = "4",
    age_5 = "5",
    age_65over = "6"
  ) |>
  mutate(population_msoa = age_15below + age_2 + age_3 + age_4 + age_5 + age_65over) |>
  mutate(pop_age_15below_normalised = (age_15below / population_msoa) * 100) |>
  mutate(pop_age_65over_normalised = (age_65over / population_msoa) * 100) |>
  select(msoa_code, pop_age_15below_normalised, pop_age_65over_normalised, population_msoa)

population <- age |>
  select(msoa_code, population_msoa)

age <- age |>
  select(msoa_code, pop_age_15below_normalised, pop_age_65over_normalised)



