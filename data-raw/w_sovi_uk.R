# ---- COMBINATION OF SUMMER WILDFIRE RISK AND SOCIAL VULNERABILITY INDEX ----
# ---- Setup ----
# devtools::load_all(".")
library(tidyverse)
library(sf)

# ---- England ----
data("sovi_england")
data("wildfire_risk_summer_england")

w_sovi_england <- sovi_england |> 
  left_join(wildfire_risk_summer_england) |> 
  mutate(sovi_decile = ntile(SoVI_standardised, 10),
         wildfire_decile = ntile(wildfire_risk_summer_standardised, 10),
         is_worst_deciles = ifelse(
           (sovi_decile >= 8) & (wildfire_decile >= 8),
           "yes",
           NA)) |> 
  select(msoa21_code,
         ltla21_code,
         SoVI_standardised,
         wildfire_risk_summer_standardised,
         is_worst_deciles)

# ---- Wales ----
data("sovi_wales")
data("wildfire_risk_summer_wales")

w_sovi_wales <- sovi_wales |> 
  left_join(wildfire_risk_summer_wales) |> 
  mutate(sovi_decile = ntile(SoVI_standardised, 10),
         wildfire_decile = ntile(wildfire_risk_summer_standardised, 10),
         is_worst_deciles = ifelse(
           (sovi_decile >= 8) & (wildfire_decile >= 8),
           "yes",
           NA)) |> 
  select(msoa21_code,
         ltla21_code,
         SoVI_standardised,
         wildfire_risk_summer_standardised,
         is_worst_deciles)

# ---- Scotland ----
data("sovi_scotland")
data("wildfire_risk_summer_scotland")

w_sovi_scotland <- sovi_scotland |> 
  left_join(wildfire_risk_summer_scotland, by = "iz11_code") |> 
  mutate(sovi_decile = ntile(SoVI_standardised, 10),
         wildfire_decile = ntile(wildfire_risk_summer_standardised, 10),
         is_worst_deciles = ifelse(
           (sovi_decile >= 8) & (wildfire_decile >= 8),
           "yes",
           NA)) |> 
  select(msoa21_code = iz11_code,
         ltla21_code,
         SoVI_standardised,
         wildfire_risk_summer_standardised,
         is_worst_deciles)

# ---- Northern Ireland ----
data("sovi_ni")
data("wildfire_risk_summer_ni")

w_sovi_ni <- sovi_ni |> 
  left_join(wildfire_risk_summer_ni) |> 
  mutate(sovi_decile = ntile(SoVI_standardised, 10),
         wildfire_decile = ntile(wildfire_risk_summer_standardised, 10),
         is_worst_deciles = ifelse(
           (sovi_decile >= 8) & (wildfire_decile >= 8),
           "yes",
           NA)) |> 
  select(msoa21_code = sdz21_code,
         ltla21_code,
         SoVI_standardised,
         wildfire_risk_summer_standardised,
         is_worst_deciles)

# --- Merge datasets ----
w_sovi_uk <- rbind(w_sovi_england, w_sovi_wales, w_sovi_scotland, w_sovi_ni)

usethis::use_data(w_sovi_uk, overwrite = TRUE)

# --- Save as shapefile at MSOA level ---
boundaries_msoa_ni <- geographr::boundaries_sdz21 |>
  rename(msoa21_code = sdz21_code) 

boundaries_msoa_scotland <- geographr::boundaries_iz11 |>
  rename(msoa21_code = iz11_code) 

boundaries_msoa_uk <- bind_rows(
  geographr::boundaries_msoa21, boundaries_msoa_ni,
  boundaries_msoa_scotland
) 

w_sovi_uk_msoa <- w_sovi_uk |>
  left_join(boundaries_msoa_uk) |>
  mutate(area_name = coalesce(sdz21_name, iz11_name, msoa21_name)) |>
  select(msoa21_code, `Area name` = area_name, `Vulnerable to wildfire in Summer?` = is_worst_deciles, geometry)


st_write(w_sovi_uk_msoa, "data/shapefile/wildfire_sovi_uk_summer.shp", append = FALSE)

