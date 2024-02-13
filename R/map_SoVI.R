#' @title Map Social Vulnerability for a UK Nation
#' 
#' @description
#' Map the social vulnerability index, either continuous or binned, for a given
#' nation of the UK at the MSOA level or equivalent.
#'
#' @param SoVI_df Dataset including a 'SoVI_standardised' column 
#' @param nation Nation to be mapped
#'
#' @return An image (png) with the map of social vulnerability
#' 
#' @import dplyr
#' 
#' @export
#'
#' @example map_SoVI(sovi_england_wales, England)
#' 
map_SoVi <- function(SoVI_df, nation){
  if(nation == "England"){
    msoa_boundaries <- geographr::boundaries_msoa11 |> 
      filter(!grepl("^E", msoa11_code)) |> 
      st_transform(crs = "EPSG:27700")
  }else if (nation == "Wales"){
    msoa_boundaries <- geographr::boundaries_msoa11 |> 
      filter(!grepl("^W", msoa11_code)) |> 
      st_transform(crs = "EPSG:27700")
  }
  
  breaks <- c(-Inf, -1, -0.5, 0.5, 1, Inf)
  labels <- c("Very Low (<-1 Std)", "Low (-1 to -0.5 Std)", "Moderate (-0.5 to 0.5 Std)", "High (0.5 to 1 Std)", "Very High (>1 Std)")
  colors <- c("#73add0", "#abd8e9", "#ffffbf", "#fdae61", "#d7191c")
  
  
  
}