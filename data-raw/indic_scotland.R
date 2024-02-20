# ---- DATA FOR SOCIAL VULNERABILITY INDEX (SCOTLAND) ----

# ---- Setup ----
library(tidyverse)
library(httr2)
library(readxl)
library(janitor)
library(geographr)

lookup_iz_dz <- geographr::lookup_dz11_iz11_ltla20 |> 
  select(-ltla20_name, -ltla20_code)

# ---- Indicators from CACI ----
# July 2023 data modelled by CACI - cannot be shared publicly
CACI_lsoa <- read_excel(
  path = "~/Documents/Internship Red Cross/Northern Ireland & Scotland Up to Date Demographics_July 2023.xlsx",
  range = "A11:CL7877") |> 
  clean_names()


# ---- Indicators from Scottish Index of Multiple Deprivation 2020 ----
# Source: https://www.gov.scot/publications/scottish-index-of-multiple-deprivation-2020-indicator-data2/
url <- "https://www.gov.scot/binaries/content/documents/govscot/publications/statistics/2020/01/scottish-index-of-multiple-deprivation-2020-indicator-data/documents/simd_2020_indicators/simd_2020_indicators/govscot%3Adocument/SIMD_2020_Indicators.xlsx"
download <- tempfile(fileext = ".xlsx")
request(url) |>
  req_perform(download)

imd_indicators = read_excel(download, sheet = "Data")

imd_social_dz = imd_indicators |> 
  select(Data_Zone, Intermediate_Zone, no_qualifications, Employment_rate, overcrowded_rate)

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



usethis::use_data(indic_scotland, overwrite = TRUE)
