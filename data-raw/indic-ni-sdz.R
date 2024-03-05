# ---- DATA FOR SOCIAL VULNERABILITY INDEX (NORTHERN IRELAND) ----
# N. Ireland has no MSOA equivalent, use SDZ (LSOA equivalent)

# ---- Setup and load data source files ----
library(tidyverse)
library(httr2)
library(readxl)
library(janitor)
library(geographr)
library(demographr)

# --- Demography data from census ----
# https://www.nisra.gov.uk/publications/census-area-explorer-data
# Census area explorer - demography data (2021)

demography_url <- "https://www.nisra.gov.uk/system/files/statistics/census-area-explorer-demography-data-2021.xlsx"
download_demography <- tempfile(fileext = ".xlsx")
request(demography_url) |>
  req_perform(download_demography)

demography <- read_excel(download_demography, sheet = "SDZ", range = "A4:G9345") |>
  clean_names() |>
  rename(sdz21_code = geocode)

population_dem <- demography |>
  filter(topic == "Broad age bands (years)") |>
  group_by(sdz21_code) |>
  summarise(total_population = sum(count))

# --- Labour market data from census ----
# https://www.nisra.gov.uk/publications/census-area-explorer-data
# Census area explorer - labour market and qualification (2021)

labour_url <- "https://www.nisra.gov.uk/system/files/statistics/census-area-explorer-labour-market-and-qualifications-data-2021.xlsx"
download_labour <- tempfile(fileext = ".xlsx")
request(labour_url) |>
  req_perform(download_labour)

labour_market <- read_excel(download_labour, sheet = "SDZ", range = "A4:G26354") |>
  clean_names() |>
  rename(sdz21_code = geocode)

population_labour <- labour_market |>
  filter(topic == "Highest level of qualifications") |>
  group_by(sdz21_code) |>
  summarise(total_population = sum(count))

population_in_employment <- labour_market |>
  filter(topic == "Occupation") |>
  group_by(sdz21_code) |>
  summarise(total_population_employment = sum(count))

# --- Health data from census ----
# https://www.nisra.gov.uk/publications/census-area-explorer-data
# Census area explorer - health and care data (2021)

health_url <- "https://www.nisra.gov.uk/system/files/statistics/census-area-explorer-health-and-care-data-2021.xlsx"
download_health <- tempfile(fileext = ".xlsx")
request(health_url) |>
  req_perform(download_health)

healthcare <- read_excel(download_health, sheet = "SDZ", range = "A4:G26354") |>
  clean_names() |>
  rename(sdz21_code = geocode)

population_health <- healthcare |>
  filter(topic == "Long-term health conditions") |>
  group_by(sdz21_code) |>
  summarise(total_population = sum(count))

# --- Housing data from census ----
# https://www.nisra.gov.uk/publications/census-area-explorer-data
# Census area explorer - housing and accommodation data (2021)

housing_url <- "https://www.nisra.gov.uk/system/files/statistics/census-area-explorer-housing-and-accommodation-data-2021.xlsx"
download_housing<- tempfile(fileext = ".xlsx")
request(housing_url) |>
  req_perform(download_housing)

housing <- read_excel(download_housing, sheet = "SDZ", range = "A4:G20404") |>
  clean_names() |>
  rename(sdz21_code = geocode)

population_housing <- housing |>
  filter(topic == "Accommodation type") |>
  group_by(sdz21_code) |>
  summarise(total_population = sum(count))

# --- Household structure data from census ----
# https://www.nisra.gov.uk/publications/census-area-explorer-data
# Census area explorer - houehold structure data (2021)

household_url <- "https://www.nisra.gov.uk/system/files/statistics/census-area-explorer-household-structure-data-2021.xlsx"
download_household<- tempfile(fileext = ".xlsx")
request(household_url) |>
  req_perform(download_household)

household <- read_excel(download_household, sheet = "SDZ", range = "A4:G8504") |>
  clean_names() |>
  rename(sdz21_code = geocode)

population_household <- household |>
  filter(topic == "Household composition") |>
  group_by(sdz21_code) |>
  summarise(total_population = sum(count))

# --- Ethnicity data from census ----
# https://www.nisra.gov.uk/publications/census-area-explorer-data
# Census area explorer - religion and ethnicity data (2021)

ethnicity_url <- "https://www.nisra.gov.uk/system/files/statistics/census-area-explorer-religion-and-ethnicity-data-2021.xlsx"
download_ethnicity<- tempfile(fileext = ".xlsx")
request(ethnicity_url) |>
  req_perform(download_ethnicity)

ethnicity <- read_excel(download_ethnicity, sheet = "SDZ", range = "A4:G11054") |>
  clean_names() |>
  rename(sdz21_code = geocode)

population_ethnicity <- ethnicity |>
  filter(topic == "Ethnic group") |>
  group_by(sdz21_code) |>
  summarise(total_population = sum(count))

# --- Migration data from census ----
# https://www.nisra.gov.uk/publications/census-area-explorer-data
# Census area explorer - migration data (2021)

migration_url <- "https://www.nisra.gov.uk/system/files/statistics/census-area-explorer-migration-data-2021.xlsx"
download_migration <- tempfile(fileext = ".xlsx")
request(migration_url) |>
  req_perform(download_migration)

migration <- read_excel(download_migration, sheet = "SDZ", range = "A4:G5954") |>
  clean_names() |>
  rename(sdz21_code = geocode)

population_migration <- migration |>
  filter(topic == "Address one year ago") |>
  group_by(sdz21_code) |>
  summarise(total_population = sum(count))

# ---- Age ----
u15 <- demography |>
  filter(category == "0-14 years") |>
  group_by(sdz21_code) |>
  summarise(under15 = sum(count))

o65 <- demography |>
  filter(category == "65+ years") |>
  group_by(sdz21_code) |>
  summarise(over65 = sum(count))

age <- population_dem |>
  left_join(u15) |>
  left_join(o65) |>
  mutate(under15_normalised = under15/total_population,
         over65_normalised = over65/total_population) |>
  select(-under15, -over65, -total_population)

# ---- Education ----
# No english proficiency data
education <- labour_market |>
  filter(category == "No qualifications") |>
  group_by(sdz21_code) |>
  summarise(no_qual = sum(count)) |>
  left_join(population_labour) |>
  mutate(no_qual_normalised = no_qual/total_population) |>
  select(-no_qual, -total_population)

# ---- Health ----
disability <- healthcare |>
  filter(category == "Limited a lot") |>
  select(sdz21_code, disability = count)

lt_condition <- healthcare |>
  filter(category == "3 or more conditions") |>
  select(sdz21_code, lt_condition = count)

health <- population_health |>
  left_join(disability) |>
  left_join(lt_condition) |>
  mutate(disabled_normalised = disability/total_population,
         longterm_condition_normalised = lt_condition/total_population) |>
  select(-disability, -lt_condition, -total_population)

# ---- Socio-economic status ----
unemployed <- labour_market |>
  filter(category == "Unemployed") |>
  select(sdz21_code, unemployed = count)

skilled_occupation <- labour_market |>
  filter(category == "Skilled trades occupations") |>
  select(sdz21_code, skilled_occupation = count) |>
  left_join(population_in_employment) # uses a diff total population count

socio <- population_labour |>
  left_join(unemployed) |>
  left_join(skilled_occupation) |>
  mutate(unemployed_normalised = unemployed/total_population,
         skilled_occupation_normalised = skilled_occupation/total_population_employment) |>
  select(-unemployed, -skilled_occupation, -total_population_employment, -total_population)


# ---- Housing and households ---- 
# No occupancy rating
private_renter <- housing |>
  filter(category == "Private rented" | category == "Lives rent free") |>
  group_by(sdz21_code) |>
  summarise(private_rented = sum(count))

social_rented <- housing |>
  filter(category == "Social rented") |>
  select(sdz21_code, social_rented = count)

no_car <- housing |>
  filter(category == "No cars or vans") |>
  select(sdz21_code, no_car = count)

caravan <- housing |>
  filter(category == "Caravan or other mobile or temporary structure") |>
  select(sdz21_code, caravan = count)

housing_structure <- population_housing |>
  left_join(private_renter) |>
  left_join(social_rented) |>
  left_join(no_car) |>
  left_join(caravan) |>
  mutate(private_renter_normalised = private_rented/total_population,
         social_renter_normalised = social_rented/total_population,
         no_car_normalised = no_car/total_population,
         caravan_normalised = caravan/total_population) |>
  select(-private_rented, -social_rented, -no_car, -caravan, -total_population)
  
# ---- Social networking ----
social_network <- household |>
  filter(category == "One person household" | category == "Single family: Lone parent family") |>
  group_by(sdz21_code) |>
  summarise(single_person_house = sum(count)) |>
  left_join(population_household) |>
  mutate(single_person_house_normalised = single_person_house/total_population)|>
  select(-single_person_house, -total_population)

# ---- Migration and ethnicity ----
other_ethnicity <- ethnicity |>
  filter(category == "Other ethnic groups") |>
  select(sdz21_code, other_ethnicity = count) |>
  left_join(population_ethnicity) |>
  mutate(other_ethnicity_normalised = other_ethnicity / total_population) |>
  select(-total_population, -other_ethnicity)

migrant_inside_uk <- migration |>
  filter(category == "Different address: Within Northern Ireland") |>
  select(sdz21_code, migrant_inside_uk = count)

migrant_outside_uk <- migration |>
  filter(category == "Different address: Outside Northern Ireland") |>
  select(sdz21_code, migrant_outside_uk = count)

ethnicity_migration <-other_ethnicity |>
  left_join(migrant_inside_uk) |>
  left_join(migrant_outside_uk) |>
  left_join(population_migration) |>
  mutate(migrant_inside_normalised = migrant_inside_uk/total_population,
         migrant_outside_normalised = migrant_outside_uk/total_population
         )|>
  select(-migrant_inside_uk, -migrant_outside_uk, -total_population)
  
# ---- Combine and aggregate dfs ----
indic_sdz_ni <- age |> 
  left_join(education) |>
  left_join(health) |>
  left_join(socio) |>
  left_join(housing_structure) |>
  left_join(social_network) |>
  left_join(ethnicity_migration) 

usethis:: use_data(indic_sdz_ni, overwrite = TRUE)

