require(janitor)
require(dplyr)
require(tidyr)
require(readxl)
require(stringr) #To be able to change entries to title case
require(jsonlite)

data <- read_xlsx("goholm2023.xlsx")


cleanup_column_names <- function(data){
  # Change the column names of a dataframe to snake case and then change the
  # more problematic column names.
  data <- data %>%
    clean_names() %>% 
    rename(
      autoclass = autoklassat_som,
      hjalp = skriv_bokstaven_h_for_hjalp,
      )

   data
}

cleanup_species_names(data, correction_file="corrections.json"){
  #TODO: Load and check against corrections.json and change species 
  data$art <- str_to_title(data$art)
  
}


# Combines the art_1/2/3 columns into one without including empty rows from 2
# and 3
unify_columns <- function(data){
  # TODO: Make this prettier and more scaleable by putting df's in a list
  data_new <- data %>% 
    select(-c("art_2", "art_3"))
  data_spec_2 <- data %>% 
    select(-c("art_1", "art_3"))
  data_spec_3 <- data %>% 
    select(-c("art_1", "art_2"))
  
  # Removes empty rows and then append the result to data_new
  data_spec_2 <- data_spec_2[!is.na(data_spec_2$art_2),]
  data_spec_3 <- data_spec_3[!is.na(data_spec_3$art_3),]
  
  names(data_spec_2) <- names(data_new)
  names(data_spec_3) <- names(data_new)
  
  data_new <- bind_rows(data_new, data_spec_2)
  data_new <- bind_rows(data_new, data_spec_3)
  
  data_new <- data_new %>% 
    rename(art = art_1)
  
  data_new
}


data <- cleanup_column_names(data)
data_clean <- unify_columns(data)


