require(janitor)
require(dplyr)
require(readxl)
require(stringr)

data <- read_xlsx("goholm2023.xlsx")

cleanup_column_names <- function(data){
   data <- data %>%
    clean_names() %>% 
    rename(
      autoclass = autoklassat_som,
      hjalp = skriv_bokstaven_h_for_hjalp,
      )

   data
}

cleanup_species_names(data){
  #TODO: Use str_to_title from stringr to convert everything to title case,
  # removing the need to deal with upper/lower case issues.
}

clear_empty_rows <- function(data){
  #TODO: Remove empty art_x entries
  
}

arrange_data <- function(data){
  data_new <- data[,-c("art_2", "art_3")]
  data_spec_2 <- data[,-c("art_1", "art_3")]
  data_spec_3 <- data[,-c("art_1", "art_2")]
  
  # TODO: add a function that removes empty rows and then append the result
  # to data_new
}


data <- cleanup_column_names(data)
unique(data$art_3)
