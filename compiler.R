require(janitor)
require(dplyr)
require(tidyr)
require(readxl)
require(stringr) #To be able to change entries to title case
require(jsonlite)

source("./cleanup_functions.R")


main <- function(save_report_copy = FALSE){
  # Load the data file
  data_raw <- read_xlsx("goholm2023.xlsx")
  
  # Change columns to snake case and drop unused columns
  data <- cleanup_columns(data_raw)
  
  # Convert to long format based on species columns
  data_clean <- unify_columns(data)
  
  # Correct species entries to standardized entries
  #TODO: Increase functionality so that it checks against accepted and known 
  #erroneous values, lists unfamiliar values, and asks you if you want to stop.
  data_names <- cleanup_species_names(data_clean)
  
  # Change morning times to previous date, and drop timestamp from datetime. 
  data_dates <- correct_dates(data_names)
  
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
  data_certain <- remove_uncertain_data(data_dates)
  
  # Spread the data so that it counts the species occurrences per night.
  data_wide <- spread_by_date(data_certain)

    
  #TODO: Sum total of files by row
  
  #TODO: Check for social calls and attach as appropriate
  
  #TODO: Connect to SMHI-API and get mean weather values for the night
  
  
}

data_file <- main()
data_file
