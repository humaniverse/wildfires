# ---- COMBINATION OF WILDFIRE RISK AND SOCIAL VULNERABILITY INDEX ----
# ---- Setup ----
# devtools::load_all(".")
library(tidyverse)

# ---- England ----
data("sovi_england")
data("wildfire_risk_england")

w_sovi_england <- sovi_england |> 
  left_join(wildfire_risk_england) |> 
  mutate(sovi_decile = ntile(SoVI_standardised, 10),
         wildfire_decile = ntile(wildfire_risk_standardised, 10),
         in_both_quintiles = (sovi_decile >= 8) & (wildfire_decile >= 8)) |> 
  select(msoa21_code,
         SoVI_standardised,
         wildfire_risk_standardised,
         in_both_quintiles)

# ---- Wales ----
data("sovi_wales")
data("wildfire_risk_wales")

w_sovi_wales <- sovi_wales |> 
  left_join(wildfire_risk_wales) |> 
  mutate(sovi_decile = ntile(SoVI_standardised, 10),
         wildfire_decile = ntile(wildfire_risk_standardised, 10),
         in_both_quintiles = (sovi_decile >= 8) & (wildfire_decile >= 8)) |> 
  select(msoa21_code,
         SoVI_standardised,
         wildfire_risk_standardised,
         in_both_quintiles)

# ---- Scotland ----
data("sovi_scotland")
data("wildfire_risk_scotland")

w_sovi_scotland <- sovi_scotland |> 
  left_join(wildfire_risk_scotland) |> 
  mutate(sovi_decile = ntile(SoVI_standardised, 10),
         wildfire_decile = ntile(wildfire_risk_standardised, 10),
         in_both_quintiles = (sovi_decile >= 8) & (wildfire_decile >= 8)) |> 
  select(msoa21_code = iz11_code,
         SoVI_standardised,
         wildfire_risk_standardised,
         in_both_quintiles)

# ---- Northern Ireland ----
data("sovi_ni")
data("wildfire_risk_ni")

w_sovi_ni <- sovi_ni |> 
  left_join(wildfire_risk_ni) |> 
  mutate(sovi_decile = ntile(SoVI_standardised, 10),
         wildfire_decile = ntile(wildfire_risk_standardised, 10),
         in_both_quintiles = (sovi_decile >= 8) & (wildfire_decile >= 8)) |> 
  select(msoa21_code = sdz21_code,
         SoVI_standardised,
         wildfire_risk_standardised,
         in_both_quintiles)

# --- Merge datasets ----
w_sovi_uk <- rbind(w_sovi_england, w_sovi_wales, w_sovi_scotland, w_sovi_ni)

usethis::use_data(w_sovi_uk, overwrite = TRUE)
