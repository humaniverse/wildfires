#' Spring Wildfires in the UK (2002-2022)
#'
#' A dataset containing point data of all wildfires that happened in the UK in
#' the months of March, April and May between 2002 and 2022. 
#' From the MODIS Collection 6.1 of the NASA FIRMS Archive
#'
#' @format A data frame of class "sf" with 9448 rows and 5 variables:
#' \describe{
#'   \item{LATITUDE}{Latitude of the fire}
#'   \item{LONGITUDE}{Longitude of the fire}
#'   \item{geometry}{Point coordinates of the fire}
#'   \item{year}{Year}
#'   \item{month}{Month}
#' }
#' @source \url{https://firms.modaps.eosdis.nasa.gov/download/}
#' 
#' @author Matteo Larrode
"fires_spring_uk"

#' Summer Wildfires in the UK (2002-2022)
#'
#' A dataset containing point data of all wildfires that happened in the UK in
#' the months of June, July, August, andSeptember between 2002 and 2022. 
#' From the MODIS Collection 6.1 of the NASA FIRMS Archive
#'
#' @format A data frame of class "sf" with 5221 rows and 5 variables:
#' \describe{
#'   \item{LATITUDE}{Latitude of the fire}
#'   \item{LONGITUDE}{Longitude of the fire}
#'   \item{geometry}{Point coordinates of the fire}
#'   \item{year}{Year}
#'   \item{month}{Month}
#' }
#' @source \url{https://firms.modaps.eosdis.nasa.gov/download/}
"fires_summer_uk"

#' Predictors of Spring Wildfires in the UK
#'
#' This RasterStack object contains a collection of raster layers representing
#' various environmental predictors related to spring wildfires in the UK.
#'
#' @format A RasterStack object with the following layers:
#'
#' \describe{
#'   \item{Slope}{Raster layer representing the slope of the terrain.}
#'   \item{Aspect}{Raster layer representing the aspect of the terrain.}
#'   \item{Average.Temperature}{Raster layer representing the average temperature during spring.}
#'   \item{Precipitation}{Raster layer representing precipitation during spring.}
#'   \item{Wind.Speed}{Raster layer representing average wind speed during spring.}
#'   \item{Proximity.to.Major.Roads}{Raster layer representing proximity to major roads.}
#'   \item{Population.Counts}{Raster layer representing population counts in the UK.}
#' }
#'
#' @details
#' The RasterStack has the following properties:
#' \itemize{
#'   \item \code{class}: RasterStack
#'   \item \code{dimensions}: 263 rows, 250 columns, 65750 cells, 7 layers
#'   \item \code{resolution}: 0.04166667 x 0.04166667 (x, y)
#'   \item \code{extent}: -8.666667, 1.75, 49.875, 60.83333 (xmin, xmax, ymin, ymax)
#'   \item \code{crs}: +proj=longlat +datum=WGS84 +no_defs
#'   \item \code{names}: Slope, Aspect, Average.Temperature, Precipitation, Wind.Speed, Proximity.to.Major.Roads, Population.Counts
#'   \item \code{min values}: 0.00000, 0.00000, 0.00000, 33.96667, 2.93600, -0.09200, 0.00000
#'   \item \code{max values}: 0.0930622, 6.2831853, 10.5779605, 193.2136383, 10.3826666, 68.3430023, 441.3430481
#' }
#'
#' @seealso
#' \code{\link[raster]{raster}}, \code{\link[raster]{stack}}
#'
#' @author Matteo Larrode
"spring_independent_var_stack"

#' Predictors of Summer Wildfires in the UK
#'
#' This RasterStack object contains a collection of raster layers representing
#' various environmental predictors related to summer wildfires in the UK.
#'
#' @format A RasterStack object with the following layers:
#'
#' \describe{
#'   \item{Slope}{Raster layer representing the slope of the terrain.}
#'   \item{Aspect}{Raster layer representing the aspect of the terrain.}
#'   \item{Average.Temperature}{Raster layer representing the average temperature during summer.}
#'   \item{Precipitation}{Raster layer representing precipitation during summer.}
#'   \item{Wind.Speed}{Raster layer representing average wind speed during summer.}
#'   \item{Proximity.to.Major.Roads}{Raster layer representing proximity to major roads.}
#'   \item{Population.Counts}{Raster layer representing population counts in the UK.}
#' }
#'
#' @details
#' The RasterStack has the following properties:
#' \itemize{
#'   \item \code{class}: RasterStack
#'   \item \code{dimensions}: 263 rows, 250 columns, 65750 cells, 7 layers
#'   \item \code{resolution}: 0.04166667 x 0.04166667 (x, y)
#'   \item \code{extent}: -8.666667, 1.75, 49.875, 60.83333 (xmin, xmax, ymin, ymax)
#'   \item \code{crs}: +proj=longlat +datum=WGS84 +no_defs
#'   \item \code{names}: Slope, Aspect, Average.Temperature, Precipitation, Wind.Speed, Proximity.to.Major.Roads, Population.Counts
#'   \item \code{min values}: 0.000000, 0.000000, 8.392517, 44.140907, 2.506667, -0.092000, 0.000000
#'   \item \code{max values}: 0.0930622, 6.2831853, 18.0772878, 203.4393921, 8.6173331, 68.3430023, 441.3430481
#' }
#'
#' @seealso
#' \code{\link[raster]{raster}}, \code{\link[raster]{stack}}
#'
#'
#' @author Matteo Larrode
"summer_independent_var_stack"