# Wildfire Risk and Social Vulnerability in the UK </a>

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

<!-- badges: end -->

The `wildfires` package provides easy access to data on the intersection between
social vulnerability and wildfire risk for the UK’s nations:

-   England: Middle Layer Super Output Area (MSOA)
-   Wales: MSOA
-   Scotland: Intermediate Zones
-   Northern Ireland: Super Data Zones

This package is based on Hasan Guler's thesis "Spatial Assessment of Wildfire Vulnerability in England and Wales: Coupling Social Vulnerability with Predicted Wildfire Susceptibility," aiming to spatially assess wildfire vulnerability in England and Wales by coupling social and biophysical vulnerability.

The impact of wildfire widely vary based on the resilience of exposed communities, influenced by the time and location of the incident in conjunction with socioeconomic variables. It is therefore necessary to gain a deeper understanding of how socioeconomic disparities intersect with environmental hazards, to enable targeted interventions and informed decision-making in measures to decrease hazard exposure. 

## Installation

Install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("humaniverse/wildfires")
```

## Usage and Key Datasets

The package provides a comprehensive toolkit for analyzing social vulnerability and wildfire risks, including:

- Calculation of the Social Vulnerability Index (SoVI) using PCA.
- Wildfire risk prediction using Random Forest models.
- Combined datasets highlighting areas at high risk due to both social vulnerability and wildfire susceptibility.

### Social Vulnerability Index (SoVI)

-   England: `wildfires::sovi_england`
-   Wales: `wildfires::sovi_wales`
-   Nothern Ireland: `wildfires::sovi_ni`
-   Scotland: `wildfires::sovi_scotland`

**Indicators of social vulnerability**, which have been used to create
the SoVI are also available for all UK nations.

-   England & Wales: `wildfires::indic_msoa_eng_wales`
-   Nothern Ireland: `wildfires::indic_sdz_ni`
-   Scotland: `wildfires::indic_msoa_scotland`


### Wildfire Risk (Summer)

-   England: `wildfires::wildfire_risk_england`
-   Wales: `wildfires::wildfire_risk_wales`
-   Nothern Ireland: `wildfires::wildfire_risk_ni`
-   Scotland: `wildfires::wildfire_risk_scotland`

## Methodology

### Creation of the Social Vulnerability Index via Principal Component Analysis

### Prediction of Summer Wildfire Risk via Random Forest

[Add model performance measures]

## Getting help

If you encounter a clear bug, please file an issue with a minimal
reproducible example on
[GitHub](https://github.com/humaniverse/wildfires/issues).

------------------------------------------------------------------------

Please note that this project is released with a [Contributor Code of
Conduct](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).
By participating in this project you agree to abide by its terms.
