# Change the column names of a dataframe to snake case and then remove
# useless columns
cleanup_columns <- function(data){
  data <- data %>% 
    select(-c("Autoklassat som", "Vem", 
              "skriv bokstaven h för hjälp", "Validering?"))
  
  data <- data %>%
    clean_names() 
  
  data
}


# Check species name against corrections.json and change species 
cleanup_species_names <-function(data, 
                                 correction_file="corrections.json"){
  # Change entries to title case.
  data$art <- str_to_title(data$art)
  
  # Read the file with known erroneous entries and their corresponding 
  # corrections. Store known erroneous entries in incorrect_names.
  corrections <- read_json(correction_file)
  incorrect_names <- names(corrections)
  total_bats <-nrow(data)
  
  # Loop over all species entries. Correct as needed
  for( i in 1:total_bats){
    species_entry <- data$art[i]
    if( species_entry %in% incorrect_names){
      data$art[i] <- corrections[[species_entry]]
    }
  }
  #TODO: Check against an accepted values lists. List those values, 
  # and asks user they want to stop as there are unknown values.
  
  data
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

# Takes a datetime object and coverts it to YYYYMMDD. If the time of day is less
# than hour, subtract those man many hours to shift the date to previous day.
set_correct_date <- function(datetime, hour= 11){
  current_hour <- format(datetime, format = "%H") %>% 
    as.integer()
  
  if(current_hour < hour){
    datetime <- datetime - (hour * 3600)
  }
  date <- format(datetime, format("%Y%m%d"))
  date
}

# Coverts date_time column to datetime and then applies set_correct_date to
# that data-series.
#TODO: soft code the datetime column name
correct_dates <- function(data){
  data$date_time <- 
    as.POSIXct(data$date_time, 
               format="%Y%m%d %H:%M", #YYYYMMDD HH:MM
               tz="GMT")
  
  data_names$date_time <- lapply(data$date_time, set_correct_date) 
  
}