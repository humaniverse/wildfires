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

saveRDS(fires_spring_uk, file="inst/extdata/rf_outcome/fires_spring_uk.rds")
saveRDS(fires_summer_uk, file="inst/extdata/rf_outcome/fires_summer_uk.rds")

# ---- INDEPENDENT VARIABLES ----
# ---- Topography ----
# Source: https://www.worldclim.org/data/worldclim21.html
topography_url <- "https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/wc2.1_2.5m_elev.zip"

download <- tempfile()

request(topography_url) |>
  req_progress() |> 
  req_perform(download)

temp_dir0 <- tempdir()
elevation_raw <- raster(unzip(download, exdir = temp_dir0))
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

saveRDS(slope_raster, file="inst/extdata/rf_independent/slope_raster.rds")
saveRDS(aspect_raster, file="inst/extdata/rf_independent/aspect_raster.rds")

# ---- Climate variables ----
# Source: https://www.worldclim.org/data/monthlywth.html
# MINIMUM TEMPERATURES
# List of URLs
tmin_urls <- c(
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmin_2000-2009.zip",
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmin_2010-2019.zip",
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmin_2020-2021.zip"
)

# Function to download and extract files from multiple urls
download_and_extract <- function(urls, temp_dir) {
  temp_file <- tempfile(fileext = ".zip")
  
  for (url in urls) {
    request(url) |>
      req_progress() |>
      req_perform(temp_file)
    
    # Extract the contents
    unzip(temp_file, exdir = temp_dir)
  }
}

# Download and extract files
temp_dir <- tempdir()
download_and_extract(tmin_urls, temp_dir)

# Function to calculate average minimum temperature for a specified season
# across the raster
calculate_avg_seasonal_temperature_min <- function(temp_dir, season) {
  files <- list.files(temp_dir, full.names = TRUE)
  
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

spring_avg_min <- calculate_avg_seasonal_temperature_min(temp_dir, "spring")
spring_avg_min_uk <- crop(spring_avg_min, countries_uk_wgs84)

summer_avg_min <- calculate_avg_seasonal_temperature_min(temp_dir, "summer")
summer_avg_min_uk <- crop(summer_avg_min, countries_uk_wgs84)

# Save new RasterLayer objects
save(spring_avg_min_uk, file="inst/extdata/rf_independent/spring_avg_min_uk.rda")
save(summer_avg_min_uk, file="inst/extdata/rf_independent/summer_avg_min_uk.rda")

# MAXIMUM TEMPERATURES
# List of URLs
tmax_urls <- c(
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmax_2000-2009.zip",
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmax_2010-2019.zip",
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_tmax_2020-2021.zip"
)

# Download and extract files
temp_dir2 <- tempdir()
download_and_extract(tmax_urls, temp_dir2)

# Function to calculate average maximum temperature for a specified season
# across the raster
calculate_avg_seasonal_temperature_max <- function(temp_dir, season) {
  files <- list.files(temp_dir, full.names = TRUE)
  
  # Define the pattern based on the specified season
  if (season == "spring") {
    pattern <- "wc2.1_2.5m_tmax_\\d{4}-(03|04|05)\\.tif"
  } else if (season == "summer") {
    pattern <- "wc2.1_2.5m_tmax_\\d{4}-(06|07|08)\\.tif"
  } else {
    stop("Invalid season. Supported values: 'spring' or 'summer'")
  }
  
  filtered_files <- files[grepl(pattern, files)]
  
  rasters <- lapply(filtered_files, raster)
  stacked_raster <- stack(rasters)
  
  avg_temperature <- mean(stacked_raster, na.rm = TRUE)
  
  return(avg_temperature)
}

spring_avg_max <- calculate_avg_seasonal_temperature_max(temp_dir2, "spring")
spring_avg_max_uk <- crop(spring_avg_max, countries_uk_wgs84)

summer_avg_max <- calculate_avg_seasonal_temperature_max(temp_dir2, "summer")
summer_avg_max_uk <- crop(summer_avg_max, countries_uk_wgs84)

# Save new RasterLayer objects
save(spring_avg_max_uk, file="inst/extdata/rf_independent/spring_avg_max_uk.rda")
save(summer_avg_max_uk, file="inst/extdata/rf_independent/summer_avg_max_uk.rda")

# PRECIPITATIONS
prec_urls <- c(
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_prec_2000-2009.zip",
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_prec_2010-2019.zip",
  "https://geodata.ucdavis.edu/climate/worldclim/2_1/hist/cts4.06/2.5m/wc2.1_cruts4.06_2.5m_prec_2020-2021.zip"
)

# Download and extract files
temp_dir3 <- tempdir()
download_and_extract(prec_urls, temp_dir3)

# Function to calculate average precipitations for a specified season
# across the raster
calculate_avg_seasonal_precipitations <- function(temp_dir, season) {
  files <- list.files(temp_dir, full.names = TRUE)
  
  # Define the pattern based on the specified season
  if (season == "spring") {
    pattern <- "wc2.1_2.5m_prec_\\d{4}-(03|04|05)\\.tif"
  } else if (season == "summer") {
    pattern <- "wc2.1_2.5m_prec_\\d{4}-(06|07|08)\\.tif"
  } else {
    stop("Invalid season. Supported values: 'spring' or 'summer'")
  }
  
  filtered_files <- files[grepl(pattern, files)]
  
  rasters <- lapply(filtered_files, raster)
  stacked_raster <- stack(rasters)
  
  avg_precipitations <- mean(stacked_raster, na.rm = TRUE)
  
  return(avg_precipitations)
}

spring_avg_prec <- calculate_avg_seasonal_precipitations(temp_dir3, "spring")
spring_avg_prec_uk <- crop(spring_avg_prec, countries_uk_wgs84)

summer_avg_prec <- calculate_avg_seasonal_precipitations(temp_dir3, "summer")
summer_avg_prec_uk <- crop(summer_avg_prec, countries_uk_wgs84)

# Save new RasterLayer objects
save(spring_avg_prec_uk, file="inst/extdata/rf_independent/spring_avg_prec_uk.rda")
save(summer_avg_prec_uk, file="inst/extdata/rf_independent/summer_avg_prec_uk.rda")

# WIND SPEED
# Source: https://www.worldclim.org/data/worldclim21.html#google_vignette
wind_url <- c("https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/wc2.1_2.5m_wind.zip")

# Download and extract files
temp_dir4 <- tempdir()
download_and_extract(wind_url, temp_dir4)

calculate_avg_wind_speed <- function(temp_dir, season) {
  files <- list.files(temp_dir, full.names = TRUE)
  
  # Define the pattern based on the specified season
  if (season == "spring") {
    pattern <- "_(03|04|05)\\.tif$"
  } else if (season == "summer") {
    pattern <- "_(06|07|08)\\.tif$"
  } else {
    stop("Invalid season. Supported values: 'spring' or 'summer'")
  }
  
  filtered_files <- files[grepl(pattern, files)]
  
  rasters <- lapply(filtered_files, raster)
  stacked_raster <- stack(rasters)
  
  avg_wind_speed <- mean(stacked_raster, na.rm = TRUE)
  
  return(avg_wind_speed)
}

spring_avg_wind_speed <- calculate_avg_wind_speed(temp_dir4, "spring")
spring_avg_wind_speed_uk <- crop(spring_avg_wind_speed, countries_uk_wgs84)

summer_avg_wind_speed <- calculate_avg_wind_speed(temp_dir4, "summer")
summer_avg_wind_speed_uk <- crop(summer_avg_wind_speed, countries_uk_wgs84)

# Save new RasterLayer objects
saveRDS(spring_avg_wind_speed_uk, file="inst/extdata/rf_independent/spring_avg_wind_speed_uk.rds")
saveRDS(summer_avg_wind_speed_uk, file="inst/extdata/rf_independent/summer_avg_wind_speed_uk.rds")

# ---- Vegetation Cover ----
# Source: 


# ---- Anthropogenic Factors ----
# DISTANCE TO ROADS
# Source: https://hub.worldpop.org/geodata/summary?id=17530
dist_road_url <- "https://data.worldpop.org/GIS/Covariates/Global_2000_2020/GBR/OSM/DST/gbr_osm_dst_road_100m_2016.tif"

download_dist_road <- tempfile()

request(dist_road_url) |>
  req_progress() |> 
  req_perform(download_dist_road)

dist_road_uk <- raster(download_dist_road)
dist_road_uk_projected <- projectRaster(dist_road_uk, spring_avg_prec_uk, method = "ngb")

# Save RasterLayer
saveRDS(dist_road_uk_projected, file="inst/extdata/rf_independent/dist_road_uk_projected.rds")

# POPULATION
# Source: https://hub.worldpop.org/geodata/summary?id=50089
pop_url <- "https://data.worldpop.org/GIS/Population/Global_2000_2020_Constrained/2020/BSGM/GBR/gbr_ppp_2020_UNadj_constrained.tif"

download_pop <- tempfile()

request(pop_url) |>
  req_progress() |> 
  req_perform(download_pop)

pop_uk <- raster(download_pop)
pop_uk_projected <- projectRaster(pop_uk, spring_avg_prec_uk, method = "ngb")
pop_uk_projected[is.na(pop_uk_projected)] <- 0

# Save RasterLayer
saveRDS(pop_uk_projected, file="inst/extdata/rf_independent/pop_uk_projected.rds")

# ---- STACKING INDEPENDENT VARIABLES ----
# Load all independent variables
directory_path <- "inst/extdata/rf_independent/"
file_list <- list.files(directory_path, pattern = "\\.rds$|\\.rda$", full.names = TRUE)

for (file_path in file_list) {
  file_name <- tools::file_path_sans_ext(basename(file_path))
  
  if (grepl("\\.rds$", file_path)) {
    assign(file_name, readRDS(file_path))
  }
  
  if (grepl("\\.rda$", file_path)) {
    load(file_path)
    assign(file_name, get(file_name))
  }
}







spring_independent_var_stack <- stack(
  
)
