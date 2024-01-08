require(janitor)
require(dplyr)
require(readxl)

data <- read_xlsx("goholm2023.xlsx")

cleanup_names <- function(data){
   data <- data %>%
    clean_names() %>% 
    rename(
      autoclass = autoklassat_som,
      hjalp = skriv_bokstaven_h_for_hjalp,
      )

   data
}

arrange_data <- function(data){
  data_new <- data[,-c("art_2", "art_3")]
  data_spec_2 <- data[,-c("art_1", "art_3")]
  data_spec_3 <- data[,-c("art_1", "art_2")]
}


data <- cleanup_names(data)
unique(data$art_1)
