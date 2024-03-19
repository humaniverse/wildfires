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

#' Socioeconomic Indicators for England and Wales at MSOA Level
#'
#' This dataset provides a comprehensive collection of socioeconomic variables
#' for Middle Layer Super Output Areas (MSOAs) in England and Wales. Derived
#' primarily from Census data, these indicators have been used for constructing
#' the Social Vulnerability Index (SoVI).
#'
#' @format A tibble with 7,264 rows and 26 variables:
#'
#' \describe{
#'   \item{msoa_code}{\code{character} MSOA code uniquely identifying each area.}
#'   \item{msoa_name}{\code{character} Descriptive name of the MSOA.}
#'   \item{pop_age_15below_normalised}{\code{double} Percentage of the population aged below 15 years old.}
#'   \item{pop_age_65over_normalised}{\code{double} Percentage of the population aged over 65 years old.}
#'   \item{no_qualification_normalised}{\code{double} Percentage of the population without educational qualifications.}
#'   \item{...}{Other socioeconomic indicators such as disability, health status, household composition, housing status, employment, and ethnicity, all normalised by MSOA population.}
#' }
#'
#' @details
#' The indicators within this dataset were selected based on a comprehensive literature review
#' that identified key factors contributing to social vulnerability, particularly in the context
#' of wildfire risk. The normalisation process facilitates comparison across different MSOAs
#' and enhances the dataset's utility in spatial analyses.
#'
#' @references
#' The selection of variables is based on the methodology and literature review
#' conducted in "Spatial Assessment of Wildfire Vulnerability in England and
#' Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility"
#' by Hasan Guler.
#'
"indic_msoa_eng_wales"

#' Socioeconomic Indicators for Northern Ireland's Super Data Zones
#'
#' This dataset encapsulates a range of socioeconomic indicators derived from the 2021 Census
#' for Super Data Zones (SDZs) in Northern Ireland.
#'
#' @format A tibble with 850 rows and 16 variables:
#'
#' \describe{
#'   \item{sdz21_code}{\code{character} Unique identifier for each Super Data Zone.}
#'   \item{under15_normalised}{\code{double} Proportion of the population under 15 years.}
#'   \item{over65_normalised}{\code{double} Proportion of the population over 65 years.}
#'   \item{no_qual_normalised}{\code{double} Proportion of the population without any formal qualifications.}
#'   \item{disabled_normalised}{\code{double} Proportion of the population with disabilities.}
#'   \item{longterm_condition_normalised}{\code{double} Proportion of the population with long-term health conditions.}
#'   \item{unemployed_normalised}{\code{double} Proportion of the unemployed population.}
#'   \item{skilled_occupation_normalised}{\code{double} Proportion of the population in skilled occupations.}
#'   \item{private_renter_normalised}{\code{double} Proportion of the population living in privately rented accommodations.}
#'   \item{social_renter_normalised}{\code{double} Proportion of the population living in socially rented accommodations.}
#'   \item{no_car_normalised}{\code{double} Proportion of households without access to a car.}
#'   \item{caravan_normalised}{\code{double} Proportion of the population living in caravans or other temporary structures.}
#'   \item{single_person_house_normalised}{\code{double} Proportion of single-person households.}
#'   \item{other_ethnicity_normalised}{\code{double} Proportion of the population belonging to ethnic minorities, excluding the major ethnic groups.}
#'   \item{migrant_inside_normalised}{\code{double} Proportion of the population who migrated from within the UK.}
#'   \item{migrant_outside_normalised}{\code{double} Proportion of the population who migrated from outside the UK.}
#' }
#'
#' @details
#' The indicators within this dataset were selected based on a comprehensive literature review
#' that identified key factors contributing to social vulnerability, particularly in the context
#' of wildfire risk. The normalisation process facilitates comparison across different areas
#' and enhances the dataset's utility in spatial analyses.
#'
#' @references
#' The selection of variables is based on the methodology and literature review
#' conducted in "Spatial Assessment of Wildfire Vulnerability in England and
#' Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility"
#' by Hasan Guler.
#'
#' Northern Ireland Statistics and Research Agency (NISRA) - Census 2021 data.
#'
"indic_sdz_ni"

#' Socioeconomic Indicators for Scotland's Middle Layer Super Output Areas (MSOAs)
#'
#' This dataset contains socioeconomic indicators from the 2021 Census for MSOAs in Scotland,
#' essential for understanding demographic patterns, social vulnerability, and aiding in socio-economic
#' analyses and policy formulation.
#'
#' @format A tibble with 1,279 rows and 20 variables. Key variables include:
#'
#' \describe{
#'   \item{iz11_code}{\code{character} Unique identifier for each MSOA, known as Intermediate Zone (IZ) code.}
#'   \item{iz11_name}{\code{character} Name of the MSOA, known as Intermediate Zone (IZ) name.}
#'   \item{under15_normalised}{\code{double} Normalised proportion of the population under 15 years.}
#'   \item{over65_normalised}{\code{double} Normalised proportion of the population over 65 years.}
#'   \item{no_qualifcations_normalised}{\code{double} Normalised proportion of the population without formal qualifications.}
#'   \item{...}{Other socioeconomic indicators such as employment status, housing conditions, and ethnic diversity, all normalised for comparative analysis.}
#' }
#'
#' @details
#' The indicators within this dataset were selected based on a comprehensive literature review
#' that identified key factors contributing to social vulnerability, particularly in the context
#' of wildfire risk. The normalisation process facilitates comparison across different areas
#' and enhances the dataset's utility in spatial analyses.
#'
#' @references
#' The selection of variables is based on the methodology and literature review
#' conducted in "Spatial Assessment of Wildfire Vulnerability in England and
#' Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility"
#' by Hasan Guler.
#'
#' Northern Ireland Statistics and Research Agency (NISRA) - Census 2021 data.
#'
"indic_msoa_scotland"

#' Social Vulnerability Index (SoVI) for England's MSOAs
#'
#' This dataset quantifies the Social Vulnerability Index (SoVI) across Middle Layer Super Output Areas (MSOAs)
#' in England. The SoVI is a composite measure derived from various socio-economic
#' and demographic variables, providing insights into relative vulnerability across the UK.
#'
#' @format A tibble with 6,856 rows and 4 columns:
#'
#' \describe{
#'   \item{msoa21_code}{\code{character} MSOA code.}
#'   \item{msoa21_name}{\code{character} MSOA name.}
#'   \item{SoVI}{\code{double} Social Vulnerability Index score.}
#'   \item{SoVI_standardised}{\code{double} Standardised Social Vulnerability Index score.}
#' }
#'
#' @details
#' The SoVI is constructed using Principal Component Analysis (PCA) on a set of socio-economic and demographic
#' variables sourced from the Census, as detailed in the referenced study. This index provides insights into the
#' relative vulnerability of communities to social and environmental hazards, with higher scores indicating
#' greater vulnerability.
#'
#' @references
#' The methodology for constructing the SoVI is detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility," by Hasan Guler.
#'
"sovi_england"

#' Social Vulnerability Index (SoVI) for Northern Ireland's Super Data Zones
#'
#' This dataset quantifies the Social Vulnerability Index (SoVI) across Super Data Zones (SDZs)
#' in Northern Ireland. The SoVI is a composite measure derived from various socio-economic
#' and demographic variables, providing insights into relative vulnerability across the UK.
#'
#' @format A tibble with 850 rows and 4 columns:
#'
#' \describe{
#'   \item{sdz21_code}{\code{character} Super Data Zone code.}
#'   \item{sdz21_name}{\code{character} Super Data Zone name.}
#'   \item{SoVI}{\code{double} Social Vulnerability Index score.}
#'   \item{SoVI_standardised}{\code{double} Standardised Social Vulnerability Index score.}
#' }
#'
#' @details
#' The SoVI is constructed using Principal Component Analysis (PCA) on a set of socio-economic and demographic
#' variables sourced from the Census, as detailed in the referenced study. This index provides insights into the
#' relative vulnerability of communities to social and environmental hazards, with higher scores indicating
#' greater vulnerability.
#'
#' @references
#' The methodology for constructing the SoVI is detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility," by Hasan Guler.
#'
"sovi_ni"

#' Social Vulnerability Index (SoVI) for Scotland's Intermediate Zones
#'
#' This dataset presents the Social Vulnerability Index (SoVI) for Intermediate Zones (IZs) in Scotland;
#' The SoVI is a composite measure derived from various socio-economic and demographic variables,
#' providing insights into relative vulnerability across the UK.
#'
#' @format A tibble with 1,279 rows and 4 columns:
#'
#' \describe{
#'   \item{iz11_code}{\code{character} Intermediate Zone code.}
#'   \item{iz11_name}{\code{character} Intermediate Zone name.}
#'   \item{SoVI}{\code{double} Social Vulnerability Index score.}
#'   \item{SoVI_standardised}{\code{double} Standardised Social Vulnerability Index score.}
#' }
#'
#' @details
#' The SoVI is constructed using Principal Component Analysis (PCA) on a set of socio-economic and demographic
#' variables sourced from the Census, as detailed in the referenced study. This index provides insights into the
#' relative vulnerability of communities to social and environmental hazards, with higher scores indicating
#' greater vulnerability.
#'
#' @references
#' The methodology for constructing the SoVI is detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility," by Hasan Guler.
#'
"sovi_scotland"

#' Social Vulnerability Index (SoVI) for Wales' MSOAs
#'
#' This dataset indicates the Social Vulnerability Index (SoVI) for Middle Layer Super Output Areas (MSOAs) in Wales.
#' The SoVI is a composite measure derived from various socio-economic and demographic variables,
#' providing insights into relative vulnerability across the UK.
#'
#' @format A tibble with 408 rows and 4 columns:
#'
#' \describe{
#'   \item{msoa21_code}{\code{character} MSOA code.}
#'   \item{msoa21_name}{\code{character} MSOA name.}
#'   \item{SoVI}{\code{double} Social Vulnerability Index score.}
#'   \item{SoVI_standardised}{\code{double} Standardised SoVI score.}
#' }
#'
#' @details
#' The SoVI is constructed using Principal Component Analysis (PCA) on a set of socio-economic and demographic
#' variables sourced from the Census, as detailed in the referenced study. This index provides insights into the
#' relative vulnerability of communities to social and environmental hazards, with higher scores indicating
#' greater vulnerability.
#'
#' @references
#' The methodology for constructing the SoVI is detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility," by Hasan Guler.
#'
"sovi_wales"

#' Summer Wildfire Risk Prediction for England's MSOAs
#'
#' This dataset provides predicted wildfire risk levels for Middle Layer Super Output Areas (MSOAs)
#' in England in the summer, based on a Random Forest model incorporating various environmental and anthropogenic factors.
#'
#' @format A tibble with 6,856 rows and 5 columns:
#'
#' \describe{
#'   \item{msoa21_name}{\code{character} MSOA name.}
#'   \item{msoa21_code}{\code{character} MSOA code.}
#'   \item{wildfire_risk_summer}{\code{double} Predicted wildfire risk score. Higher values signify greater risk.}
#'   \item{ltla21_code}{\code{character} Local Authority code (higher level geography).}
#'   \item{wildfire_risk_summer_standardised}{\code{double} Standardised wildfire risk score.}
#' }
#'
#' @details
#' Wildfire risk predictions are generated using a Random Forest model, considering climatological,
#' topographical, and land use variables, as detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"wildfire_risk_summer_england"

#' Summer Wildfire Risk Prediction for Northern Ireland's Super Data Zones
#'
#' This dataset outlines predicted wildfire risk levels for Super Data Zones (SDZs) in Northern Ireland in the summer,
#' derived from a Random Forest analysis that integrates environmental and anthropogenic variables.
#'
#' @format A tibble with 850 rows and 5 columns:
#'
#' \describe{
#'   \item{sdz21_name}{\code{character} SDZ name.}
#'   \item{sdz21_code}{\code{character} SDZ code.}
#'   \item{wildfire_risk_summer}{\code{double} Predicted wildfire risk score. Higher values signify greater risk.}
#'   \item{ltla21_code}{\code{character} Local Authority code (higher level geography).}
#'   \item{wildfire_risk_summer_standardised}{\code{double} Standardised wildfire risk score.}
#' }
#'
#' @details
#' Wildfire risk predictions are generated using a Random Forest model, considering climatological,
#' topographical, and land use variables, as detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"wildfire_risk_summer_ni"

#' Summer Wildfire Risk Prediction for Scotland's Intermediate Zones
#'
#' Predicted wildfire risk levels for Intermediate Zones (IZs) in Scotland in the summer, utilizing a Random Forest model
#' that integrates environmental and anthropogenic variables.
#'
#' @format A tibble with 1,279 rows and 5 columns:
#'
#' \describe{
#'   \item{iz11_name}{\code{character} IZ name.}
#'   \item{iz11_code}{\code{character} IZ code.}
#'   \item{wildfire_risk_summer}{\code{double} Predicted wildfire risk score. Higher values signify greater risk.}
#'   \item{ltla21_code}{\code{character} Local Authority code (higher level geography).}
#'   \item{wildfire_risk_summer_standardised}{\code{double} Standardised wildfire risk score.}
#' }
#'
#' @details
#' Wildfire risk predictions are generated using a Random Forest model, considering climatological,
#' topographical, and land use variables, as detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"wildfire_risk_summer_scotland"

#' Summer Wildfire Risk Prediction for Wales' MSOAs
#'
#' This dataset assesses wildfire risk across Middle Layer Super Output Areas (MSOAs) in Wales in the summer,
#' derived from a Random Forest analysis that integrates environmental and anthropogenic variables.
#'
#' @format A tibble with 408 rows and 5 columns:
#'
#' \describe{
#'   \item{msoa21_name}{\code{character} MSOA name.}
#'   \item{msoa21_code}{\code{character} MSOA code.}
#'   \item{wildfire_risk_summer}{\code{double} Predicted wildfire risk score. Higher values signify greater risk.}
#'   \item{ltla21_code}{\code{character} Local Authority code (higher level geography).}
#'   \item{wildfire_risk_summer_standardised}{\code{double} Standardised wildfire risk score.}
#' }
#'
#' @details
#' Wildfire risk predictions are generated using a Random Forest model, considering climatological,
#' topographical, and land use variables, as detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"wildfire_risk_summer_wales"

#' Spring Wildfire Risk Prediction for England's MSOAs
#'
#' This dataset provides predicted wildfire risk levels for Middle Layer Super Output Areas (MSOAs)
#' in England in the spring, based on a Random Forest model incorporating various environmental and anthropogenic factors.
#'
#' @format A tibble with 6,856 rows and 5 columns:
#'
#' \describe{
#'   \item{msoa21_name}{\code{character} MSOA name.}
#'   \item{msoa21_code}{\code{character} MSOA code.}
#'   \item{wildfire_risk_spring}{\code{double} Predicted wildfire risk score. Higher values signify greater risk.}
#'   \item{ltla21_code}{\code{character} Local Authority code (higher level geography).}
#'   \item{wildfire_risk_spring_standardised}{\code{double} Standardised wildfire risk score.}
#' }
#'
#' @details
#' Wildfire risk predictions are generated using a Random Forest model, considering climatological,
#' topographical, and land use variables, as detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"wildfire_risk_spring_england"

#' Spring Wildfire Risk Prediction for Northern Ireland's Super Data Zones
#'
#' This dataset outlines predicted wildfire risk levels for Super Data Zones (SDZs) in Northern Ireland in the spring,
#' derived from a Random Forest analysis that integrates environmental and anthropogenic variables.
#'
#' @format A tibble with 850 rows and 5 columns:
#'
#' \describe{
#'   \item{sdz21_name}{\code{character} SDZ name.}
#'   \item{sdz21_code}{\code{character} SDZ code.}
#'   \item{wildfire_risk_spring}{\code{double} Predicted wildfire risk score. Higher values signify greater risk.}
#'   \item{ltla21_code}{\code{character} Local Authority code (higher level geography).}
#'   \item{wildfire_risk_spring_standardised}{\code{double} Standardised wildfire risk score.}
#' }
#'
#' @details
#' Wildfire risk predictions are generated using a Random Forest model, considering climatological,
#' topographical, and land use variables, as detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"wildfire_risk_spring_ni"

#' Spring Wildfire Risk Prediction for Scotland's Intermediate Zones
#'
#' Predicted wildfire risk levels for Intermediate Zones (IZs) in Scotland in the spring, utilizing a Random Forest model
#' that integrates environmental and anthropogenic variables.
#'
#' @format A tibble with 1,279 rows and 5 columns:
#'
#' \describe{
#'   \item{iz11_name}{\code{character} IZ name.}
#'   \item{iz11_code}{\code{character} IZ code.}
#'   \item{wildfire_risk_spring}{\code{double} Predicted wildfire risk score. Higher values signify greater risk.}
#'   \item{ltla21_code}{\code{character} Local Authority code (higher level geography).}
#'   \item{wildfire_risk_spring_standardised}{\code{double} Standardised wildfire risk score.}
#' }
#'
#' @details
#' Wildfire risk predictions are generated using a Random Forest model, considering climatological,
#' topographical, and land use variables, as detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"wildfire_risk_spring_scotland"

#' Spring Wildfire Risk Prediction for Wales' MSOAs
#'
#' This dataset assesses wildfire risk across Middle Layer Super Output Areas (MSOAs) in Wales in the spring,
#' derived from a Random Forest analysis that integrates environmental and anthropogenic variables.
#'
#' @format A tibble with 408 rows and 5 columns:
#'
#' \describe{
#'   \item{msoa21_name}{\code{character} MSOA name.}
#'   \item{msoa21_code}{\code{character} MSOA code.}
#'   \item{wildfire_risk_spring}{\code{double} Predicted wildfire risk score. Higher values signify greater risk.}
#'   \item{ltla21_code}{\code{character} Local Authority code (higher level geography).}
#'   \item{wildfire_risk_spring_standardised}{\code{double} Standardised wildfire risk score.}
#' }
#'
#' @details
#' Wildfire risk predictions are generated using a Random Forest model, considering climatological,
#' topographical, and land use variables, as detailed in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"wildfire_risk_spring_wales"

#' Combined Summer Wildfire Risk and Social Vulnerability Index (SoVI) for UK MSOAs
#'
#' This dataset integrates the Social Vulnerability Index (SoVI) and summer wildfire risk predictions
#' across Middle Layer Super Output Areas (MSOAs) in the UK. It includes a binary indicator identifying
#' MSOAs within the worst deciles (8th, 9th, or 10th) for both SoVI and wildfire risk.
#'
#' @format A tibble with 9,393 rows and 5 columns:
#'
#' \describe{
#'   \item{msoa21_code}{\code{character} MSOA (or equivalent) code.}
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{SoVI_standardised}{\code{double} Standardised Social Vulnerability Index score.}
#'   \item{wildfire_risk_standardised}{\code{double} Standardised wildfire risk score.}
#'   \item{is_worst_deciles}{\code{character} Indicator for MSOAs in the worst deciles (8th, 9th, or 10th) for both SoVI and wildfire risk. 'yes' indicates presence in the worst deciles, 'NA' denotes otherwise.}
#' }
#'
#' @references
#' The approach for combining SoVI and wildfire risk scores and the methodology for determining
#' the worst deciles are based on principles outlined in "Spatial Assessment of Wildfire Vulnerability
#' in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility" by Hasan Guler.
#'
"w_sovi_uk"
