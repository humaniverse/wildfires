# ---- WILDFIRE PREDICTION ----

# ---- Setup ----
library("sf")
library("tmap")
library("tidyverse")
library("geographr")

# MSOA (or equivalent) boundaries for all UK nations
msoa <- geographr::boundaries_msoa21

iz <- geographr::boundaries_iz11 |> 
  rename(msoa21_name = iz11_name,
         msoa21_code = iz11_code)

sdz <- geographr::boundaries_sdz21|> 
  rename(msoa21_name = sdz21_name,
         msoa21_code = sdz21_code)

msoa_uk <- rbind(msoa, iz, sdz) |> 
  st_make_valid() |> 
  mutate(area_km2 = as.numeric(st_area(geometry) / 1e6))

# ---- Fire point data ----
fire_all <- 
  read_sf("inst/extdata/DL_FIRE_M-C61_427984/fire_archive_M-C61_427984.shp") |> 
  select(LATITUDE, LONGITUDE, ACQ_DATE, geometry) |> 
  mutate(year = year(ACQ_DATE),
         month = month(ymd(ACQ_DATE))) |> 
  select(- ACQ_DATE) |> 
  filter(between(year, 2002, 2022))

fires_spring_uk <- fire_all |> 
  filter(month %in% c(3:5))

fires_summer_uk <- fire_all |> 
  filter(month %in% c(6:9))

# Attribute fires to MSOA
fires_spring_uk_2 <- st_transform(fires_spring_uk, crs = st_crs(msoa_uk))
fires_spring_msoa <- st_join(msoa_uk, fires_spring_uk_2)

fires_summary <- fires_spring_msoa |> 
  group_by(msoa21_code) |> 
  summarize(total_fires = n())









# ---- Visualisations ----
tm_shape(fire_modis_all) +
  tm_dots(col = "red", size = 0.05, shape = 16, border.col = "black", title = "Wildfires") +
  tm_layout(frame = FALSE)


ggplot(fire_modis_all_yearly, aes(x = year, y = num_wildfires)) +
  geom_line() +
  labs(x = "Year", y = "Number of Wildfires") +
  ggtitle("Number of Wildfires Over Years") +
  scale_x_continuous(breaks = as.integer(fire_modis_all_yearly$year))+
  theme_minimal()
