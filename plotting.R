require(readxl)
require(stringr)
require(dplyr)
require(tidyr)
require(ggplot2)

long_format <- function(data){
  data_observations %>% 
    pivot_longer(cols = !starts_with("Date"))
}

data <- read_xlsx("./example.xlsx")
str(data)
data$date_time <- as.POSIXct(data$date_time, 
                             format="%Y%m%d", #YYYYMMDD HH:MM
                             tz="GMT")


#TODO: add these to a list to allow for looping
data_observations <- data %>% 
  select(!matches("^(Social|n)")) 
data_social <- data %>% 
  select(matches("^(Date|Social)"))

data_obs <- long_format(data_observations)

species_vector <- data_obs$name %>% unique()
plot_list = list()
time_series <- seq(as.Date("2023-03-01"), as.Date("2023-12-15"), "months")

for(species in 1:length(species_vector)){
  curr_species <- species_vector[species]
  test_data <- data_obs[data_obs$name=="Ppyg",] %>% droplevels()
  
  plot_list[[species]] #<- 
  ggplot(test_data, aes(x=date_time, y=value))+
    geom_line()+
    scale_x_date(breaks = time_series, date_labels = "%B")+
    theme_classic()+
    labs(x="Month", y = "No. Observations")+
    ggtitle("Ppyg")
}
plot_list[[1]]

