require(janitor)
require(dplyr)
require(tidyr)
require(readxl)
require(stringr) #To be able to change entries to title case
require(jsonlite)
require(writexl)

source("./cleanup_functions.R")


main <- function(save_report_copy = FALSE){
  # Load the data file
  data_raw <- read_xlsx("goholm2023.xlsx")
  
  # Change columns to snake case and drop unused columns
  data <- cleanup_columns(data_raw)
  
  # Change morning times to previous date, and drop timestamp from datetime. 
  data <- correct_dates(data)
  
  n_recording_day <- data %>% 
    count(date_time)
  names(n_recording_day) <- c("date_time", "tot_obs_day")
  
  # Convert to long format based on species columns
  data <- unify_columns(data=data,
                        species_columns= c("art_1", "art_2" ,"art_3"))
  
  # Correct species entries to standardized entries
  #TODO: Increase functionality so that it checks against accepted and known 
  #erroneous values, lists unfamiliar values, and asks you if you want to stop.
  data <- cleanup_species_names(data)
  
 
  # Export a copy of current dataset for use in Artportalen if requested
  #TODO: Check that this is actually a useable format and make appropriate
  # changes.
  if( save_report_copy){
    require(writexl)
    data_dates %>% 
      as.data.frame() %>% 
      write_xlsx(path = "./report_file.xlsx")
  }
    
  # Clean out question marks from species entries
  # This is a temporary function that will not be needed for the complete data
  # as there will be no ? in that dataset.
  data <- remove_uncertain_data(data)
  
  social_calls <- data %>% 
    select(c("sociala", "date_time"))
  # Spread the data so that it counts the species occurrences  and 
  # social calls per night.
  data <- spread_by_date(data)

   # Attach number of calls per night
  data <- attach_obs_count(data, n_recording_day)
  
  #TODO: Connect to SMHI-API and get mean weather values for the night
  
  data
}

data_file <- main()
write_xlsx(data_file, "./example.xlsx")

