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
  data$art <- str_replace_all(data$art, " ", "")
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


# Combines the art_1/2/3... columns into one without including empty rows, or 
# social call info from subsequent columns 
unify_columns <- function(data, 
                          species_columns= c("art_1", "art_2" ,"art_3") ){
  
  # Extract the primary species column
  data_new <- data %>% 
    select(!all_of(species_columns[-1]))
  
  # Extract all the other species columns 
  col_count <- length(species_columns)

  for( i in 1:(col_count-1)){
    to_drop <- species_columns[-(i+1)] #species columns not to use
    df_to_use <- data %>% 
      select(-all_of(to_drop))
    
    # Drop NA values from subsequent species columns to prevent pointless
    # row duplication.
    df_to_append <- df_to_use[!is.na(df_to_use[,2]),]
    
    # Empty social column to avoid duplication in later counts
    df_to_append$sociala <- NA
    
    #Synchronize names and append
    names(df_to_append) <- names(data_new)
    data_new <- bind_rows(data_new, df_to_append)
  }

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
  
  data$date_time <- lapply(data$date_time, set_correct_date) %>% 
    unlist()
  
  data
  
}

#Drops the ? from the end of uncertain entries
remove_uncertain_data <- function(data){
  for( i in 1:nrow(data)){
    curr_species <- data$art[i]
    
    # Do not stop because of NA values (if they are to be left in)
    # Do not change ???-values
    if( is.na(curr_species) | curr_species == '???'){
      next
    }
    
    #If there is a ?, remove it. Assumes the ? is the last character
    if( !is.na(str_extract(curr_species, "\\?"))){
      data$art[i] <- substr(curr_species, 1, nchar(curr_species)-1)
    }
  }
  data
}

#Spread the data so that it counts the species occurrences per night.
spread_by_date <- function(data, 
                           startdate="2023/3/1", 
                           enddate="2023/12/15"){
  # Generate a date series for joining data on
  time_series <- seq(as.Date(startdate), as.Date(enddate), "days") %>% 
    str_replace_all("-","") %>% 
    as.data.frame()
  names(time_series) <- "date_time"

  
  # Spread the data to wide format and count species by day 
  species_count <- data %>%
    count(date_time, art) %>%
    pivot_wider(names_from = art,
                values_from = n, values_fill = 0)
  # Spread the data to wide format and count social calls by day
  social_calls <- data[!is.na(data$sociala),] %>% 
    droplevels()
  
  social_calls$sociala <- paste0("Social_",str_to_title(social_calls$sociala))
  
  social_count <- social_calls %>%
    count(date_time, sociala) %>%
    pivot_wider(names_from = sociala,
                values_from = n, values_fill = 0)
  
  # Join species info on time series
  data <- left_join(time_series, species_count)  
  data <- left_join(data, social_count)
  
  
  #TODO: find rows where social calls are NA, but  not obs.
  # use test[logical vector,c("two","three")] <- list(rep(0, ncol(social)-1))[[1]]
  # to set all the colums there (except date) as 0
  data
}

sum_observations <- function(data){
  tot_n_cols <- ncol(data)
  
  data <- data %>% 
    replace(is.na(.), 0) %>%
    mutate("tot_files" = rowSums((data[,2:tot_n_cols]), na.rm = TRUE))
  
  data  
}


# Attach number of calls per night
attach_obs_count <- function(data, n_recordings){
  left_join(data,n_recordings)
}