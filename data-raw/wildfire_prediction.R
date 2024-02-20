# ---- WILDFIRE PREDICTION ----
# ---- SETUP ----
library("sf")
library("tmap")
library("raster")
library("tidyverse")
library("geographr")
library("httr2")
library("fs")

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

countries_uk_wgs84 <- geographr::boundaries_countries20 |> 
  st_transform(crs = "+proj=longlat +datum=WGS84")

# ---- FIRE POINT DATA ----
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

# Visualisations
tm_shape(fire_modis_all) +
  tm_dots(col = "red", size = 0.05, shape = 16, border.col = "black", title = "Wildfires") +
  tm_layout(frame = FALSE)

ggplot(fire_modis_all_yearly, aes(x = year, y = num_wildfires)) +
  geom_line() +
  labs(x = "Year", y = "Number of Wildfires") +
  ggtitle("Number of Wildfires Over Years") +
  scale_x_continuous(breaks = as.integer(fire_modis_all_yearly$year))+
  theme_minimal()

# ---- INDEPENDENT VARIABLES ----
# ---- Topography ----
# Source: https://www.worldclim.org/data/worldclim21.html
topography_url <- "https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/wc2.1_2.5m_elev.zip"

download <- tempfile()

request(topography_url) |>
  req_progress() |> 
  req_perform(download)

elevation_raw <- raster(unzip(download))
unlink(download)

elevation_uk <- crop(elevation_raw, countries_uk_wgs84)
elevation_uk_mask <- mask(elevation_uk, countries_uk_wgs84)

# Reduce number of missing values
sum(is.na(elevation_uk[]))
filled_elevation <- focal(elevation_uk, w=matrix(1, nrow=3, ncol=3), fun=mean, na.rm=TRUE)
elevation_uk[is.na(elevation_uk)] <- filled_elevation[is.na(elevation_uk)]

# Calculate slope & aspect using the terrain function
slope_raster <- terrain(elevation_uk, opt = "slope")
slope_raster_mask <- mask(slope_raster, countries_uk_wgs84)

aspect_raster <- terrain(elevation_uk, opt = "aspect")
aspect_raster_mask <- mask(aspect_raster, countries_uk_wgs84)

# Visualisation
tm_shape(elevation_uk_mask) +
  tm_raster(style = "cont", 
            title = "Elevation", 
            palette= "-Spectral", 
            midpoint = NA) +
  tm_layout(frame = FALSE, 
            legend.position = c("right", "top"), 
            title.position = c("left", "bottom"))

tm_shape(slope_raster_mask) +
  tm_raster(style = "cont", 
            title = "Slope", 
            palette = "-Spectral", 
            midpoint = NA) +
  tm_layout(frame = FALSE, 
            legend.position = c("right", "top"), 
            title.position = c("left", "bottom"))

tm_shape(aspect_raster_mask) +
  tm_raster(style = "cont", 
            title = "Aspect", 
            palette = "-Spectral", 
            midpoint = NA)+
  tm_layout(frame = FALSE, 
            legend.position = c("right", "top"), 
            title.position = c("left", "bottom"))

# ---- Climate variables ----
# Source: https://www.worldclim.org/data/monthlywth.html

# Minimum temperatures
tmin_url_1 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmin_2000-2009.zip"
tmin_url_2 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmin_2010-2019.zip"
tmin_url_3 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmin_2020-2021.zip"

download <- tempfile()

request(tmin_url_1) |>
  req_progress() |> 
  req_perform(download)

unzip(download, list = TRUE)

# unlink(download)

avg_seasonal_temperature <- function(zip, season) {
  files <- unzip(zip)
  
  # Define the pattern based on the specified season
  if (season == "spring") {
    pattern <- "wc2.1_2.5m_tmin_\\d{4}-(03|04|05)\\.tif"
  } else if (season == "summer") {
    pattern <- "wc2.1_2.5m_tmin_\\d{4}-(06|07|08)\\.tif"
  } else {
    stop("Invalid season. Supported values: 'spring' or 'summer'")
  }

  filtered_files <- files[grepl(pattern, files)]
  
  rasters <- lapply(filtered_files, raster)
  stacked_raster <- stack(rasters)
  
  avg_temperature <- mean(stacked_raster, na.rm = TRUE)
  
  return(avg_temperature)
}



# Maximum temperatures
tmax_url_1 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmax_2000-2009.zip"
tmax_url_2 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmax_2010-2019.zip"
tmax_url_3 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmax_2020-2021.zip"



# Precipitations
prec_url_1 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_prec_2000-2009.zip"
prec_url_2 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_prec_2010-2019.zip"
prec_url_3 <- "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_prec_2020-2021.zip"



# Wind speed






