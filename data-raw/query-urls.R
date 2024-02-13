query_urls <-
  tibble::tribble(
    # ----Column Names----
    ~data_type, ~country, ~id, ~query, ~source,

    # ----Scotland----
    # Age
    
    
    # Education
    
    # Health
    
    # Socioeconomic status
    
    # Housing & Household
    
    # Social networking
    
    # Migration & Ethnicity
    
    # ----Northern Ireland----
    # Age
    
    # Education
    
    # Health
    
    # Socioeconomic status
    
    # Housing & Household
    
    # Social networking
    
    # Migration & Ethnicity
    
  )

usethis::use_data(query_urls, internal = TRUE, overwrite = TRUE)
