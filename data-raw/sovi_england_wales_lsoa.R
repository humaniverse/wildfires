# ---- Creation of socioeconomic vulnerability dataset for England & Wales ----

# Data sourced from Github repository:
# https://anonymous.4open.science/r/Msc-Dissertation-60BC/

# ---- Setup ----
library(tidyverse)
library(janitor)

msoa <- read_csv("data/msoa/msoa_21.csv") |>
  select(
    msoa_code = MSOA21CD,
    msoa_name = MSOA21CD
  )

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


# ---- Education ----
edu_qualif <- read_csv("data/education/education_qualification_msoa.csv") |>
  clean_names() |>
  select(
    msoa_code = middle_layer_super_output_areas_code,
    qualif_code = highest_level_of_qualification_7_categories_code,
    qualif_cat = highest_level_of_qualification_7_categories,
    edu_qualif_number = observation
  ) |>
  filter(qualif_code == 0) |>
  left_join(population) |>
  mutate(no_qualification_normalised = (edu_qualif_number / population_msoa) * 100) |>
  select(msoa_code, no_qualification_normalised)

edu_english <- read_csv("data/education/education_english_msoa.csv") |>
  clean_names() |>
  select(
    msoa_code = middle_layer_super_output_areas_code,
    prof_code = proficiency_in_english_language_5_categories_code,
    edu_english_number = observation
  ) |>
  filter(prof_code == 3 | prof_code == 4) |>
  pivot_wider(names_from = prof_code, values_from = edu_english_number) |>
  rename(
    english_not_well = "3",
    english_cannot = "4"
  ) |>
  mutate(total_english = english_not_well + english_cannot) |>
  left_join(population) |>
  mutate(english_normalised = (total_english / population_msoa) * 100) |>
  select(msoa_code, english_normalised)

# ---- Health ----
health_disability <- read_csv("data/health/health_disability_msoa.csv") |>
  clean_names() |>
  select(
    msoa_code = middle_layer_super_output_areas_code,
    dis_code = number_of_disabled_people_in_household_4_categories_code,
    dis_number = observation
  ) |>
  filter(dis_code == 1 | dis_code == 2) |>
  pivot_wider(names_from = dis_code, values_from = dis_number) |>
  rename(
    disable_1 = "1",
    disable_2 = "2"
  ) |>
  mutate(total_disabled = disable_1 + disable_2) |>
  left_join(population) |>
  mutate(disabled_normalised = (total_disabled / population_msoa) * 100) |>
  select(msoa_code, disabled_normalised)

health_longterm <- read_csv("data/health/health_longterm_msoa.csv") |>
  clean_names() |>
  select(
    msoa_code = middle_layer_super_output_areas_code,
    longterm_code = number_of_people_in_household_with_a_long_term_heath_condition_but_are_not_disabled_4_categories_code,
    longterm_number = observation
  ) |>
  filter(longterm_code == 1 | longterm_code == 2) |>
  pivot_wider(names_from = longterm_code, values_from = longterm_number) |>
  rename(
    longterm_1 = "1",
    longterm_2 = "2"
  ) |>
  mutate(total_longtermhealth = longterm_1 + longterm_2) |>
  left_join(population) |>
  mutate(longtermhealth_normalised = (total_longtermhealth / population_msoa) * 100) |>
  select(msoa_code, longtermhealth_normalised)

# ---- Socioeconomic status ----
socio_classify <- read_csv("data/socioeconomic/socio_occupation_msoa.csv") |>
  clean_names() |>
  select(
    msoa_code = middle_layer_super_output_areas_code,
    socio_code = national_statistics_socio_economic_classification_ns_se_c_10_categories_code,
    classify_number = observation
  ) |>
  filter(socio_code == 6 | socio_code == 7 | socio_code == 8) |>
  pivot_wider(names_from = socio_code, values_from = classify_number) |>
  rename(
    semi_routine = "6",
    routine = "7",
    unemployed_neverworked = "8"
  ) |>
  mutate(total_lowoccupation = semi_routine + routine) |>
  left_join(population, ) |>
  mutate(lowoccupation_normalised = (total_lowoccupation / population_msoa) * 100) |>
  mutate(unemployed_neverworked_normalised = (unemployed_neverworked / population_msoa) * 100) |>
  select(msoa_code, unemployed_neverworked_normalised, lowoccupation_normalised)

socio_unpaid <- read_csv("data/socioeconomic/socio_unpaid_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code, 
  unpaid_code = number_of_unpaid_carers_in_household_6_categories_code, 
  unpaid_number = observation) |>
  filter(unpaid_code == 1 | unpaid_code == 2 | unpaid_code == 3 | unpaid_code == 4) |>
  pivot_wider(names_from = unpaid_code, values_from = unpaid_number) |>
  rename(
    unpaid1 = "1",
    unpaid2 = "2",
    unpaid3 = "3",
    unpaid4 = "4"
  ) |>
  mutate(total_unpaid = unpaid1 + unpaid2 + unpaid3 + unpaid4) |>
  left_join(population) |>
  mutate(unpaid_normalised = (total_unpaid / population_msoa) * 100) |>
  select(msoa_code, unpaid_normalised)

# ---- Household characteristics ----
household_size <- read_csv("data/household/household_size_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code, 
         size_code = household_size_5_categories_code,
         size_number = observation) |>
  pivot_wider(names_from = size_code, values_from = size_number)|>
  rename(h0 = "0",
         h1 = "1",
         h2 = "2",
         h3 = "3",
         h4 = "4") |> 
  mutate(total_household = h0 + h1 + h2 + h3 + h4) |> 
  select(msoa_code, total_household)

household_composition <- read_csv("data/household/household_composition_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code, 
         comp_code = household_composition_15_categories_code,
         comp_number = observation) |>
  filter(comp_code == 1 | comp_code == 3 | comp_code == 10) |>
  pivot_wider(names_from = comp_code, values_from = comp_number) |>
  rename(oneperson_66 = "1",
         singlefamily_all66 = "3",
         loneparent_dependent = "10") |>
  left_join(household_size) |>
  mutate(oneperson_66_normalised = (oneperson_66 / total_household)*100) |>
  mutate(singlefamily_all66_normalised = (singlefamily_all66 / total_household)*100) |>
  mutate(loneparent_dependent_normalised = (loneparent_dependent / total_household)*100) |>
  select(
    msoa_code, 
    oneperson_66_normalised, 
    singlefamily_all66_normalised, 
    loneparent_dependent_normalised)

household_car <- read_csv("data/household/household_car_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code, 
         car_code = car_or_van_availability_3_categories_code,
         car_number = observation) |>
  pivot_wider(names_from = car_code, values_from = car_number)|>
  rename(notapp = "-8",
         nocar = "0",
         car = "1") |>
  left_join(household_size) |>
  mutate(nocar_normalised = (nocar / total_household)* 100) |>
  select(msoa_code, nocar_normalised)
