# ---- DATA FOR SOCIAL VULNERABILITY INDEX (SCOTLAND) ----
# MSOA == IZ / LSOA == DZ

# ---- Setup and load data source files ----
library(tidyverse)
library(httr2)
library(readxl)
library(janitor)
library(geographr)
library(demographr)

# ---- Lookups ----
lookup_iz_dz <- geographr::lookup_dz11_iz11_ltla20 |> 
  select(-ltla20_name, -ltla20_code)

population_dz <-
  population20_dz11 |> 
  select(dz11_code, total_population, sex)|>
  filter(sex == "All") |>
  select(-sex)

# ---- Indicators from CACI ----
# July 2023 data modelled by CACI - cannot be shared publicly
CACI_lsoa <- read_excel(
  path = "inst/extdata/Northern Ireland & Scotland Up to Date Demographics_July 2023.xlsx",
  range = "A11:CL7877") |> 
  clean_names() |>
  filter(str_detect(lsoa, "^S")) 


# ---- Indicators from Scottish Index of Multiple Deprivation 2020 ----
# Source: https://www.gov.scot/publications/scottish-index-of-multiple-deprivation-2020-indicator-data2/
url <- "https://www.gov.scot/binaries/content/documents/govscot/publications/statistics/2020/01/scottish-index-of-multiple-deprivation-2020-indicator-data/documents/simd_2020_indicators/simd_2020_indicators/govscot%3Adocument/SIMD_2020_Indicators.xlsx"
download <- tempfile(fileext = ".xlsx")
request(url) |>
  req_perform(download)

imd_indicators = read_excel(download, sheet = "Data")

imd_social_dz = imd_indicators |> 
  select(dz11_code = Data_Zone, Intermediate_Zone, no_qualifications, Employment_rate, overcrowded_rate)

rm(download, imd_indicators)


# ---- Indicators from OCSI data (used in covid-19 vulnerability) ----
# Source: https://github.com/britishredcrosssociety/covid-19-vulnerability/tree/master/data/OCSI
url2 <- "https://github.com/britishredcrosssociety/covid-19-vulnerability/raw/master/data/OCSI/Scotland_COVID_19_Dataset_IMZ.xlsx"
download <- tempfile(fileext = ".xlsx")
request(url2) |>
  req_perform(download)

ocsi_sco = read_excel(download, col_names = FALSE)

ocsi_sco <- ocsi_sco |> 
  janitor::remove_empty("cols")

# Change cell values to get a row of consistent variable names
ocsi_sco[3,1] <- ocsi_sco[8,1]
ocsi_sco[3,2] <- ocsi_sco[8,2]

# Replace NA values with empty strings so string concatenation doesn't fail in later step
ocsi_sco[6,1] <- ""                
ocsi_sco[6,2] <- ""

# Remove metadata
ocsi_sco <- ocsi_sco %>% slice(c(-1, -2, -4, -5, -7, -8))

# drop Excel "LINK" columns
# ocsi_sco = ocsi_sco[,-c(20, 35, 48, 71, 106)]

# Combine first two rows to create new col names
column_names <- str_c(str_replace_na(ocsi_sco[1,]), str_replace_na(ocsi_sco[2,]), sep = " ")

# Rename columns
names(ocsi_sco) <- column_names

# Remove first two rows used to create new column names and
# COVID-19 column
ocsi_sco <- ocsi_sco %>% 
  slice(-1:-2) %>% 
  select(-`COVID-19 vulnerability index Score`)

# Rename Aged columns to make variables clear
ocsi_sco <- ocsi_sco %>%
  rename_at(vars(starts_with("Aged")), ~ str_c("Proportion of Population ", .))

# Remove whitespace and convert MSOA Code to upper case
ocsi_sco <- ocsi_sco %>% 
  rename(Code = `Intermediate Zone Code `) %>% 
  mutate(Code = str_to_upper(Code)) %>% 
  select(-`Intermediate Zone Name `)

# Convert all columns to numeric except Code
ocsi_sco_code <- ocsi_sco %>% 
  select(Code)

ocsi_sco_numeric <- ocsi_sco %>% 
  select(-Code) %>% 
  mutate_if(is.character, as.numeric)

ocsi_sco <- bind_cols(ocsi_sco_code,
                      ocsi_sco_numeric)

rm(ocsi_sco_code, ocsi_sco_numeric, column_names)

# --- Age ----
age <- demographr::population20_dz11 |>
  filter(sex == "All") |>
  rowwise() |>
  mutate(under15_normalised =(sum(c_across(4:19)))/total_population,
         over65_normalised = (sum(c_across(69:94)))/total_population) |>
  select(dz11_code, under15_normalised, over65_normalised) 
 
# ---- Education ----
# No qualifications is a standardised ratio, 100 is the Scotland average for a
# population with the same age and sex profile
# No data on proficiency in English
education <- imd_social_dz |>
  select(dz11_code, 
         no_qualifcations_normalised = no_qualifications)

# ---- Health ----
health <- ocsi_sco |>
  select(iz11_code = Code,
         disability_normalised = `Disability benefit (DLA) Rate`,
         longterm_health_normalised = `People with a limiting long-term illness (aged 16-64) Rate`
         )

# ---- Socio-economic status ----
# No data on unpaid carers
socio <- CACI_lsoa |>
  select(lsoa, persons_16_74, never_worked, long_term_unemployed, x7_routine_occupations,
         x7_routine_occupations) |>
  mutate(unemployed_normalised = 
           never_worked/persons_16_74 + long_term_unemployed/persons_16_74,
         low_income_occupation_normalised = 
           x7_routine_occupations/persons_16_74 + x7_routine_occupations/persons_16_74
  ) |>
  select(dz11_code = lsoa, unemployed_normalised, low_income_occupation_normalised) 
  

# ---- Housing and household ----
# No data on underoccupied housing
housing <- CACI_lsoa |>
  select(dz11_code = lsoa, 
         total_households_39, social_renting_from_local_authority, social_renting_from_housing_association_or_other_provider,
         private_renting, rent_free_and_other,
         total_households_47, caravan_or_other_mobile_or_temporary_structure,
         total_households_55, no_cars_or_vans) |>
  mutate(social_rented_normalised = 
           social_renting_from_local_authority/total_households_39 + 
           social_renting_from_housing_association_or_other_provider/total_households_39,
        private_rented_normalised = private_renting/total_households_39 + rent_free_and_other/total_households_39,
        mobile_homes_normalised = caravan_or_other_mobile_or_temporary_structure/total_households_47,
        households_no_cars_normalised = no_cars_or_vans/total_households_55
) |>
  left_join(imd_social_dz)|>
  select(dz11_code, social_rented_normalised, private_rented_normalised, mobile_homes_normalised, households_no_cars_normalised,
         overcrowded_normalised = overcrowded_rate)

# ---- Social networking ----
# No data on one-person household aged 66 over
# No data on single familt household aged 66 over
social_network <- CACI_lsoa |>
  select(dz11_code = lsoa,total_households_66, lone_parents_with_dependent_children, 
         lone_parents_with_all_children_non_dependent) |>
  mutate(lone_parents_non_dependent_children_normalised =lone_parents_with_all_children_non_dependent/total_households_66,
         lone_parents_dependent_children_normalised = lone_parents_with_dependent_children/total_households_66) |>
  select(dz11_code, lone_parents_non_dependent_children_normalised, lone_parents_dependent_children_normalised )

# ---- Migration and Ethnicity ---- 
# No data on recent migration
ethnicity <- CACI_lsoa |>
  select(dz11_code = lsoa, total_population_2, black, mixed, other, 
         south_asian_india_pakistan_bangladesh) |>
  mutate(black_normalised = black/total_population_2,
         mixed_normalised = mixed/total_population_2,
         other_normalised = other/total_population_2,
         south_asia_normalised = south_asian_india_pakistan_bangladesh/total_population_2
         ) |>
  select(dz11_code, black_normalised, mixed_normalised, other_normalised, south_asia_normalised)

# ---- Combine and aggregate dfs ----
indic_msoa_scotland <- age |> # Combine all dfs except health as it is already at iz level
  left_join(education) |>
  left_join(socio) |>
  left_join(housing) |>
  left_join(social_network) |>
  left_join(ethnicity) |> 

# Aggregate from DZ to IZ using weighted population mean
  left_join(lookup_iz_dz) |>
  left_join(population_dz) |>
  select(-dz11_name) |>
  group_by(iz11_code, iz11_name) |> 
  summarise(across(.cols = contains("normalised"), .fns = ~ weighted.mean(., w = total_population, na.rm = TRUE))) |>
  left_join(health) # health already at iz level

usethis:: use_data(indic_msoa_scotland, overwrite = TRUE)

