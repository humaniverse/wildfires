# ---- WILDFIRE PREDICTION ----

# ---- Setup ----
library("sf")
library("tmap")
library("tidyverse")

# ---- Data cleaning ----
fire_modis_all <- read_sf("inst/extdata/DL_FIRE_M-C61_427984/fire_archive_M-C61_427984.shp")
fire_modis_all$year <- year(fire_modis_all$ACQ_DATE)

fire_modis_all <- fire_modis_all |> 
  filter(between(year, 2002, 2022)) |> 
  mutate(month = month(ymd(ACQ_DATE)))

fire_modis_all_yearly <- fire_modis_all |> 
  group_by(year) |> 
  summarise(num_wildfires = n())

fire_modis_engwales <- st_intersection(fire_modis_all, england_wales_wgs84)

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
