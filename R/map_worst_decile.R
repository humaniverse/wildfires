#' @title Map Worst Decile MSOAs in the UK
#' 
#' @description
#' Maps a binary variable at the MSOA level or equivalent for the UK or a given 
#' nation. In this function, the theme is designed for the mapping of a 'worst 
#' quintile' binary variable for the wildfire risk and social vulnerability 
#' index.
#'
#' @param df Dataset including a 'is_worst_deciles' column 
#' @param nation (default is "All"). Nation to be mapped: one of "All", "England", "Wales", "Scotland", or "Northern Ireland"
#'
#' @return An image (png) with the map (not yet)
#' 
#' @import dplyr
#' @import ggplot2
#' 
#' @export
#'
#' 
map_worst_decile_msoa <- function(df, nation = "All"){
  # Create MSOA boundaries for all UK
  msoa <- geographr::boundaries_msoa21
  iz <- geographr::boundaries_iz11 |>
    rename(
      msoa21_name = iz11_name,
      msoa21_code = iz11_code
    )
  sdz <- geographr::boundaries_sdz21 |>
    rename(
      msoa21_name = sdz21_name,
      msoa21_code = sdz21_code
    )
  msoa_uk <- rbind(msoa, iz, sdz) |>
    st_make_valid() |> 
    sf::st_transform(crs = "EPSG:27700")
  
  # Select the MSOA boundaries
  if(nation == "All"){
    msoa_boundaries <- msoa_uk
  } else if(nation == "England"){
    msoa_boundaries <- msoa_uk |> 
      filter(grepl("^E", msoa21_code))
  } else if (nation == "Wales"){
    msoa_boundaries <- msoa_uk |> 
      filter(grepl("^W", msoa21_code))
  } else if (nation == "Scotland"){
    msoa_boundaries <- msoa_uk |> 
      filter(grepl("^S", msoa21_code))
  } else if (nation == "Northern Ireland"){
    msoa_boundaries <- msoa_uk |> 
      filter(grepl("^N", msoa21_code))
  }
  
  df_plot <- msoa_boundaries |> 
    left_join(df)
  
  # BRC Theme
  theme_brc_map <- function(...) {
    ggplot2::theme_minimal() +
      ggplot2::theme(
        text = ggplot2::element_text(color = "#1d1a1c"),
        axis.line = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.title.x = ggplot2::element_blank(),
        axis.title.y = ggplot2::element_blank(),
        
        panel.grid.major = ggplot2::element_line(color = "#ebebe5", linewidth = 0.2),
        panel.grid.minor = ggplot2::element_blank(),
        
        plot.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
        panel.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
        legend.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
        panel.border = ggplot2::element_blank(),
        
        # Add labs elements
        legend.title = ggplot2::element_text(size = 11),
        legend.text = ggplot2::element_text(size = 9, hjust = 0),
        
        plot.title = ggplot2::element_text(size = 15, hjust = 0.5),
        plot.subtitle = ggplot2::element_text(
          size = 10, hjust = 0.5,
          margin = ggplot2::margin(
            b = 0.2,
            t = 0.2,
            l = 2,
            unit = "cm"
          ),
          debug = F
        ),
        
        # captions
        plot.caption = ggplot2::element_text(
          size = 7,
          hjust = .5,
          margin = ggplot2::margin(
            t = 0.2,
            b = 0,
            unit = "cm"
          ),
          color = "#1d1a1c"
        ),
        ...
      )
  }
  
  plot <- df_plot |>
    ggplot() +
    geom_sf(data = df_plot, fill = "white", color = "black", size = 0.5) +  # Plot the overall shape with black outlines
    geom_sf(data = df_plot, aes(fill = is_worst_deciles), color = NA) + 
    theme_brc_map() +
    theme(legend.position = "none") +
    scale_fill_manual(values = c("yes" = "#ee2a24"), na.value = "white")
  
  print(plot)
  
  return("Plotting map")
}

#' @title Map Worst Decile Local Authorities in the UK
#' 
#' @description
#' Given a binary 'worst-decile' type variable at the MSOA level or equivalent, 
#' aggregates it to the Lower Tier Local Authority level and maps it. In this 
#' function, the theme is designed for the mapping of a 'worst 
#' quintile' binary variable for the wildfire risk and social vulnerability 
#' index.
#'
#' @param df Dataset including a 'is_worst_deciles' column 
#' @param nation (default is "All"). Nation to be mapped: one of "All", "England", "Wales", "Scotland", or "Northern Ireland"
#'
#' @return An image (png) with the map (not yet)
#' 
#' @import dplyr
#' @import ggplot2
#' 
#' @export
#'
#' 
map_worst_decile_ltla <- function(df, nation = "All"){
  # Create LTLA boundaries for all UK
  ltla21_uk <- geographr::boundaries_ltla21 |> 
    sf::st_transform(crs = "EPSG:27700")
  
  # Select the LTLA boundaries
  if(nation == "All"){
    ltla_boundaries <- ltla21_uk
  } else if(nation == "England"){
    ltla_boundaries <- ltla21_uk |> 
      filter(grepl("^E", ltla21_code))
  } else if (nation == "Wales"){
    ltla_boundaries <- ltla21_uk |> 
      filter(grepl("^W", ltla21_code))
  } else if (nation == "Scotland"){
    ltla_boundaries <- ltla21_uk |> 
      filter(grepl("^S", ltla21_code))
  } else if (nation == "Northern Ireland"){
    ltla_boundaries <- ltla21_uk |> 
      filter(grepl("^N", ltla21_code))
  }
  
  df_aggregated <- df |> 
    group_by(ltla21_code) |> 
    summarise(total_count = n(),
              yes_count = sum(is_worst_deciles == "yes", na.rm = TRUE),
              percentage_yes = (yes_count / total_count) * 100) |> 
    ungroup() |> 
    mutate(percentage_yes_rank = 374 - rank(percentage_yes),
           is_worst = ifelse(rank(percentage_yes_rank) < 41 ,"yes", NA))
  
  
  df_plot <- ltla_boundaries |> 
    left_join(df_aggregated)
  
  # BRC Theme
  theme_brc_map <- function(...) {
    ggplot2::theme_minimal() +
      ggplot2::theme(
        text = ggplot2::element_text(color = "#1d1a1c"),
        axis.line = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.title.x = ggplot2::element_blank(),
        axis.title.y = ggplot2::element_blank(),
        
        panel.grid.major = ggplot2::element_line(color = "#ebebe5", linewidth = 0.2),
        panel.grid.minor = ggplot2::element_blank(),
        
        plot.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
        panel.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
        legend.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
        panel.border = ggplot2::element_blank(),
        
        # Add labs elements
        legend.title = ggplot2::element_text(size = 11),
        legend.text = ggplot2::element_text(size = 9, hjust = 0),
        
        plot.title = ggplot2::element_text(size = 15, hjust = 0.5),
        plot.subtitle = ggplot2::element_text(
          size = 10, hjust = 0.5,
          margin = ggplot2::margin(
            b = 0.2,
            t = 0.2,
            l = 2,
            unit = "cm"
          ),
          debug = F
        ),
        
        # captions
        plot.caption = ggplot2::element_text(
          size = 7,
          hjust = .5,
          margin = ggplot2::margin(
            t = 0.2,
            b = 0,
            unit = "cm"
          ),
          color = "#1d1a1c"
        ),
        ...
      )
  }
  
  plot <- df_plot |>
    ggplot() +
    geom_sf(data = df_plot, fill = "white", color = "black", size = 0.5) +  # Plot the overall shape with black outlines
    geom_sf(data = df_plot, aes(fill = is_worst), color = NA) + 
    theme_brc_map() +
    theme(legend.position = "none") +
    scale_fill_manual(values = c("yes" = "#ee2a24"), na.value = "white")
  
  print(plot)
  
  return("Plotting map")
}
