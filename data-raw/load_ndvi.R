library(raster)
library(sf)

devtools::load_all(".")

data <- raster("inst/notebook/output.tif")
print(data)
plot(data)

countries_uk_wgs84 <- geographr::boundaries_countries20 |>   
  st_transform(crs = "+proj=longlat +datum=WGS84")

data_cropped <- crop(data, countries_uk_wgs84)

print(data_cropped)
plot(data_cropped)
