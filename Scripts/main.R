#SV Scarpino
#Oct 2022
#Main file for Uganda Ebola line list.

###########
#libraries#
###########
library(ggplot2)
library(dplyr)

#########
#Globals#
#########
do_plot <- FALSE

##########
#Run Code#
##########
source("download_data.R")
source("build_csvs.R")
source("build_line_list.R")

############
#Plot cases#
############
if(do_plot == TRUE){
  rm_NA_district <- which(is.na(baselinelist$District) == TRUE)
  baselinelist$count <- 1
  plot_dat <- baselinelist[-rm_NA_district,] %>% group_by(Date_confirmation, District, count) %>% summarise(n = sum(count))
  
  
  ggplot(data = baselinelist, aes(x = as.Date(Date_confirmation), fill = District)) + geom_bar() + facet_wrap(~District) + xlab("Daily new Ebola cases") + ylab("Daily new Ebola cases") + theme(legend.position = "none", legend.key = element_rect(fill = "#f0f0f0"), legend.background = element_rect(fill = "#ffffffaa", colour = "black"), panel.background = element_rect(fill = "white", colour = "black"), axis.text.y = element_text(colour = "black", size = 14), axis.text.x = element_text(colour = "black", size = 10), axis.title = element_text(colour = "black", size = 16), panel.grid.minor = element_line(colour = "#00000080",linetype = 3), panel.grid.major = element_line(colour = "#00000000", linetype = 3)) 
