# ---- DATA FOR SOCIAL VULNERABILITY INDEX (ENGLAND & WALES) ----

# Data sourced from Github repository:
# https://anonymous.4open.science/r/Msc-Dissertation-60BC/

# ---- Setup ----
library(tidyverse)
library(janitor)

msoa <- read_csv("inst/extdata/msoa/msoa_21.csv") |>
  select(
    msoa_code = MSOA21CD,
    msoa_name = MSOA21CD
  )

# ---- Age ----
age <- read_csv("inst/extdata/age_msoa.csv") |>
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
edu_qualif <- read_csv("inst/extdata/education/education_qualification_msoa.csv") |>
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

edu_english <- read_csv("inst/extdata/education/education_english_msoa.csv") |>
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
health_disability <- read_csv("inst/extdata/health/health_disability_msoa.csv") |>
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

health_longterm <- read_csv("inst/extdata/health/health_longterm_msoa.csv") |>
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
socio_classify <- read_csv("inst/extdata/socioeconomic/socio_occupation_msoa.csv") |>
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

socio_unpaid <- read_csv("inst/extdata/socioeconomic/socio_unpaid_msoa.csv") |>
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
household_size <- read_csv("inst/extdata/household/household_size_msoa.csv") |>
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

household_composition <- read_csv("inst/extdata/household/household_composition_msoa.csv") |>
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

household_car <- read_csv("inst/extdata/household/household_car_msoa.csv") |>
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

# ---- Housing ----
housing_tenure <- read_csv("inst/extdata/housing/housing_tenure_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code,
         tenure_code = tenure_of_household_7_categories_code,
         tenure_number = observation) |>
  filter(tenure_code %in% c(2, 3, 4, 5)) |>
  pivot_wider(names_from = tenure_code, values_from = tenure_number) |>
  rename(socialrent1 = "2",
         socialrent2 = "3",
         privaterent1 = "4",
         privaterent2 = "5") |>
  mutate(social_total = socialrent1 + socialrent2) |>
  mutate(privaterent_total = privaterent1 + privaterent2) |>
  left_join(household_size) |>
  mutate(socialrent_normalised = (social_total / total_household) * 100) |>
  mutate(privaterent_normalised = (privaterent_total / total_household) * 100) |>
  select(msoa_code, socialrent_normalised, privaterent_normalised)

housing_occupancy <- read_csv("inst/extdata/housing/housing_occupancy_rating_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code, 
         occupancy_code = occupancy_rating_for_rooms_5_categories_code,
         occupancy_number = observation) |>
  filter(occupancy_code %in% c(1, 2, 4)) |>
  pivot_wider(names_from = occupancy_code, values_from = occupancy_number) |>
  rename(underoccupied2 = "1",
         unoccupied1 = "2",
         overcrowded = "4") |>
  mutate(underoccupied_total = underoccupied2 + unoccupied1) |>
  left_join(household_size) |>
  mutate(underoccupied_normalised = (underoccupied_total / total_household)*100) |>
  mutate(overcrowded_normalised = (overcrowded / total_household)*100) |>
  select(msoa_code, underoccupied_normalised, overcrowded_normalised)

mobile_home <- read_csv("inst/extdata/housing/mobile_home_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code,
         mobile_code = accommodation_by_type_of_dwelling_9_categories_code,
         mobile_number= observation) |>
  filter(mobile_code == 8) |>
  pivot_wider(names_from = mobile_code, values_from = mobile_number) |>
  rename(mobile1 = "8") |>
  left_join(household_size) |>
  mutate(mobile_normalised = (mobile1 / total_household)*100) |>
  select(msoa_code, mobile_normalised)

# ---- Migration & Ethnicity ----
migrant <- read_csv("inst/extdata/migration_ethnicity/migration_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code,
         migrant_code = migrant_indicator_5_categories_code,
         migrant_number = observation) |>
  filter(migrant_code %in% c(2, 3)) |>
  pivot_wider(names_from = migrant_code, values_from = migrant_number) |>
  rename(migrant_insideUK = "2",
         migrant_outsideUK = "3") |>
  left_join(population) |>
  mutate(migrant_insideUK_normalised = (migrant_insideUK / population_msoa)*100) |>
  mutate(migrant_outsideUK_normalised = (migrant_outsideUK / population_msoa)*100) |>
  select(msoa_code, migrant_insideUK_normalised, migrant_outsideUK_normalised)

ethnicity <- read_csv("inst/extdata/migration_ethnicity/ethnicity_msoa.csv") |>
  clean_names() |>
  select(msoa_code = middle_layer_super_output_areas_code, 
         ethnic_code = ethnic_group_6_categories_code,
         ethnic_number = observation) |>
  filter(ethnic_code %in% c(1, 2, 3, 5)) |>
  pivot_wider(names_from = ethnic_code, values_from = ethnic_number) |>
  rename(asian = "1",
         black = "2",
         mixed = "3",
         other = "5") |>
  left_join(population) |>
  mutate(asian_normalised = (asian / population_msoa)*100,
         black_normalised = (black / population_msoa)*100,
         mixed_normalised = (mixed / population_msoa)*100,
         other_normalised = (other / population_msoa)*100) |>
  select(msoa_code, 
         asian_normalised, 
         black_normalised, 
         mixed_normalised,
         other_normalised)

# ---- Aggregate data: Social Vulnerability Index Dataset ----
indic_msoa_eng_wales <- msoa |>
  left_join(age) |>
  left_join(edu_english) |>
  left_join(edu_qualif) |>
  left_join(health_disability) |>
  left_join(health_longterm) |>
  left_join(household_composition) |>
  left_join(household_car) |>
  left_join(housing_occupancy) |>
  left_join(housing_tenure) |>
  left_join(mobile_home) |>
  left_join(migrant) |>
  left_join(socio_classify) |>
  left_join(socio_unpaid) |>
  left_join(ethnicity)

use_data(indic_msoa_eng_wales, overwrite = TRUE)
