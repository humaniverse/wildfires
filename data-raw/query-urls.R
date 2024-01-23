query_urls <-
  tibble::tribble(
    # Column Names
    ~data_type, ~country, ~id, ~query, ~source,
    
    # England & Wales
    "Age (MSOA)", "England & Wales", "age_england_wales", "https://static.ons.gov.uk/datasets/c24fa6b7-52b5-4f98-bce6-112a02d6311d/TS007-2021-3-filtered-2024-01-23T15:11:07Z.csv#get-data", "https://www.ons.gov.uk/datasets/TS007/editions/2021/versions/3"
  )

usethis::use_data(query_urls, internal = TRUE, overwrite = TRUE)
