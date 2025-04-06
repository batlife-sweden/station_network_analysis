# Also install "stringi". ALL WITH DEPENDENCIES SET TO TRUE!
require(janitor)
require(dplyr)
require(tidyr)
require(readxl)
require(stringr)
require(jsonlite)
require(writexl)

year = "2024" #Year from analysis

source("./cleanup_functions.R")

input_name <- "ottenby.xlsx"
output_file_name <- "example_output.xlsx"

save_report_copy = FALSE #Ignore this. Part of development


# Load the data file
data_raw <- read_xlsx(input_name)

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
data <- spread_by_date(data,
                       startdate = paste0(year, "/3/1"), 
                       enddate=paste0(year,"/12/15"))

 # Attach number of calls per night
data <- attach_obs_count(data, n_recording_day)

#TODO: Connect to SMHI-API and get mean weather values for the night

write_xlsx(data, output_file_name)



