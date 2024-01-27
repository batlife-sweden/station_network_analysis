require(readxl)
require(stringr)
require(dplyr)
require(tidyr)
require(ggplot2)

IMG_WIDTH = 900
IMG_HEIGHT = 484
FONT_SIZE = 14

long_format <- function(data){
  data_observations %>% 
    pivot_longer(cols = !starts_with("Date"))
}

data <- read_xlsx("./example.xlsx")
data$date_time <- as.Date(data$date_time, 
                             format="%Y%m%d", #YYYYMMDD HH:MM
                             tz="GMT")


#TODO: change it so that I only need to extract the names from the original
# dataframe. All this splitting is not really necessary.
data_observations <- data %>% 
  select(!matches("^(Social|n)")) %>% 
  select(-tot_obs_day)
data_social <- data %>% 
  select(matches("^(Date|Social)"))

data_observations <- long_format(data_observations)

species_vector <- data_observations$name %>% unique()
plot_list = list()
time_series <- seq(as.Date("2023-03-01"), as.Date("2023-12-15"), "months")
socially_calling_species <- names(data_social)[2:length(names(data_social))] %>% 
  str_remove_all("Social_")


gg_theme <- theme_bw()+
  theme(text= element_text(size = FONT_SIZE))
for(species in 1:length(species_vector)){
  curr_species <- species_vector[species]
  
  obs_data <- data_observations[data_observations$name==curr_species,] %>% 
    droplevels()
  
  
  if( curr_species %in% socially_calling_species){ # if there are social calls
    social_column <- paste0('Social_',curr_species)
    
    call_data <- data_social[,c("date_time", social_column)]
    
    max_species_obs <- max(obs_data[,"value"],na.rm = TRUE)
    max_call_obs <- max(call_data[, social_column], na.rm = TRUE)
    scale_factor = max_species_obs / max_call_obs # scale 
    
    plot_list[[species]] <- 
      ggplot(data, aes(x=date_time))+
      geom_line(aes(y=.data[[curr_species]]))+
      geom_point(aes(y=.data[[social_column]]*scale_factor))+
      scale_x_date(breaks = time_series,
                   date_labels = "%B")+
      scale_y_continuous(name="Registrations", 
                         sec.axis=sec_axis(~./scale_factor, 
                                           name="Social calls")) +
      labs(x="Month")+
      ggtitle(curr_species)+
      gg_theme
    
  } else{ # If there are no social calls for the species
    plot_list[[species]] <- 
      ggplot(obs_data, aes(x=date_time, y=value))+
      geom_line()+
      scale_x_date(breaks = time_series,date_labels = "%B")+
      labs(x="Month", y = "Registrations")+
      ggtitle(curr_species)+
      gg_theme
    }
  
  
}



plot_list[[4]]


for( curr_plot in seq_along(plot_list)){
  species_name = species_vector[curr_plot]
  ggsave(filename = paste0("plots/",species_name, ".png"), 
         plot = plot_list[[curr_plot]],
         height = IMG_HEIGHT*3,
         width = IMG_WIDTH*3,
         units = "px",
         dpi=300)
}

