#SV Scarpino
#Oct 2022
#Main file for Uganda Ebola line list.

###########
#libraries#
###########
library(ggplot2)
library(dplyr)
library(lme4)

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
  baselinelist$Date_confirmation <- as.Date(baselinelist$Date_confirmation)
  plot_dat_country <- baselinelist[-rm_NA_district,] %>% arrange(Date_confirmation) %>% mutate(cumsum=cumsum(count))
  plot_dat_district <- baselinelist[-rm_NA_district,] %>% group_by(District) %>% arrange(Date_confirmation) %>% mutate(cumsum=cumsum(count))
  
  ggplot(data = plot_dat_district, aes(x = Date_confirmation, y = log10(cumsum), group = District, color = District)) + geom_line(size = 1) + facet_wrap(~District) + xlab(" ") + ylab("Cumulative Ebola cases (log-scale)") + theme(legend.position = "none", legend.key = element_rect(fill = "#f0f0f0"), legend.background = element_rect(fill = "#ffffffaa", colour = "black"), panel.background = element_rect(fill = "white", colour = "black"), axis.text.y = element_text(colour = "black", size = 14), axis.text.x = element_text(colour = "black", size = 10), axis.title = element_text(colour = "black", size = 16), panel.grid.minor = element_line(colour = "#00000080",linetype = 3), panel.grid.major = element_line(colour = "#00000000", linetype = 3)) + geom_smooth(method = "lm", linetype = "dashed", width = 0.5, color = "#4d4d4d")
  
  ggplot(data = plot_dat_country, aes(x = Date_confirmation, y = log10(cumsum))) + geom_line(size = 1) + xlab(" ") + ylab("Cumulative Ebola cases (log-scale)") + theme(legend.position = "none", legend.key = element_rect(fill = "#f0f0f0"), legend.background = element_rect(fill = "#ffffffaa", colour = "black"), panel.background = element_rect(fill = "white", colour = "black"), axis.text.y = element_text(colour = "black", size = 14), axis.text.x = element_text(colour = "black", size = 10), axis.title = element_text(colour = "black", size = 16), panel.grid.minor = element_line(colour = "#00000080",linetype = 3), panel.grid.major = element_line(colour = "#00000000", linetype = 3)) + geom_smooth(method = "lm", linetype = "dashed", size = 0.5, color = "#4d4d4d")
  
  ggplot(data = baselinelist, aes(x = as.Date(Date_confirmation), fill = District)) + geom_bar() + facet_wrap(~District) + xlab("Daily new Ebola cases") + ylab("Daily new Ebola cases") + theme(legend.position = "none", legend.key = element_rect(fill = "#f0f0f0"), legend.background = element_rect(fill = "#ffffffaa", colour = "black"), panel.background = element_rect(fill = "white", colour = "black"), axis.text.y = element_text(colour = "black", size = 14), axis.text.x = element_text(colour = "black", size = 10), axis.title = element_text(colour = "black", size = 16), panel.grid.minor = element_line(colour = "#00000080",linetype = 3), panel.grid.major = element_line(colour = "#00000000", linetype = 3)) 
  
  time_reg <- as.numeric(plot_dat$Date_confirmation - min(plot_dat$Date_confirmation, na.rm = TRUE), unit = "days")
  prov_reg <- plot_dat$District
  cases_reg <- plot_dat$cumsum
  mod <- lmer(log(cases_reg+1) ~ time_reg + (time_reg|prov_reg))
  doubling <- data.frame(row.names(ranef(mod)$prov_reg), log(2)/(ranef(mod)$prov_reg$time_reg+fixef(mod)["time_reg"]))
  colnames(doubling) <- c("District", "Doubling Time (days)")
  doubling <- doubling[order(doubling$`Doubling Time (days)`),]
  
  by_date <- by(baselinelist$ID, baselinelist$Date_confirmation, length)
}
