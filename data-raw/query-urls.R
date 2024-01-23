query_urls <-
  tibble::tribble(
    # Column Names
    ~data_type, ~level, ~country, ~id, ~query, ~source,
    
    # England & Wales
    "Age", "MSOA", "England & Wales", "age_england_wales", "https://static.ons.gov.uk/datasets/c24fa6b7-52b5-4f98-bce6-112a02d6311d/TS007-2021-3-filtered-2024-01-23T15:11:07Z.csv#get-data", "https://www.ons.gov.uk/datasets/TS007/editions/2021/versions/3",
    "Highest level of qualification", "MSOA", "England & Wales", "highest_qual_england_wales", "https://static.ons.gov.uk/datasets/9681b695-703c-44c4-a18a-5f00fbad3e5d/TS067-2021-3-filtered-2024-01-23T15:17:44Z.csv#get-data", "https://www.ons.gov.uk/datasets/TS067/editions/2021/versions/3/filter-outputs/9681b695-703c-44c4-a18a-5f00fbad3e5d#get-data",
    "Proficiency in English", "MSOA", "England & Wales", "english_proficiency_england_wales", "https://static.ons.gov.uk/datasets/71dfa408-ac44-49e0-9ae5-cb3eb6be294d/TS029-2021-3-filtered-2024-01-23T15:22:15Z.csv#get-data", "https://www.ons.gov.uk/datasets/TS029/editions/2021/versions/3/filter-outputs/71dfa408-ac44-49e0-9ae5-cb3eb6be294d#get-data",
    "Disability", "MSOA", "England & Wales", "disability_england_wales", "https://static.ons.gov.uk/datasets/0d567b7c-8877-4daf-855b-d35207550ca4/TS038-2021-3-filtered-2024-01-23T15:24:46Z.csv#get-data", "https://www.ons.gov.uk/datasets/TS038/editions/2021/versions/3/filter-outputs/0d567b7c-8877-4daf-855b-d35207550ca4#get-data",
    
    # Northern Ireland
    "Boundaries", "Super Data Zone", "Northern Ireland", "boundaries_sdz", "https://www.nisra.gov.uk/sites/nisra.gov.uk/files/publications/geography-sdz2021-esri-shapefile.zip", "https://www.nisra.gov.uk/publications/geography-super-data-zone-boundaries-gis-format"
    
    # Scotland
    
  )

usethis::use_data(query_urls, internal = TRUE, overwrite = TRUE)
