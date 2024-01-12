require(janitor)
require(dplyr)
require(tidyr)
require(readxl)
require(stringr) #To be able to change entries to title case
require(jsonlite)

source("./cleanup_functions.R")


# Load the data file
data_raw <- read_xlsx("goholm2023.xlsx")


# Change columns to snake case and drop unused columns
data <- cleanup_columns(data_raw)

# Convert to long format based on species columns
data_clean <- unify_columns(data)

# Correct species entries to standardized entries
#TODO: Increase functionality so that it checks against accepted values, lists
# those values, and asks you if you want to stop.
data_names <- cleanup_species_names(data_clean)

# Change morning times to previous date, and drop timestamp from datetime. 
data_dates <- correct_dates(data_names)

#TODO: Export a copy of current dataset for use in Artportalen

#TODO: Clean out question mark entries and spread dataset to count columns

#TODO: Connect to SMHI-API and get mean weather values for the night

