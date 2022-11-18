#SV Scarpino
#Oct 2022
#Main file for Uganda Ebola line list.

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
  ###########
  #libraries#
  ###########
  library(ggplot2)
  library(dplyr)
  library(lme4)
  library(zoo)
  
  files <- list.files("../Data/CSVs")
  last_file <- read.csv(paste0("../Data/CSVs/",files[length(files)]))
  last_date <- strptime(last_file$Date[1], format = "%Y-%m-%d")
  
  rm_NA_district <- which(is.na(baselinelist$District) == TRUE)
  baselinelist$count <- 1
  baselinelist$Date_confirmation <- as.Date(baselinelist$Date_confirmation)
  plot_dat_country <- baselinelist[-rm_NA_district,] %>% arrange(Date_confirmation) %>% mutate(cumsum=cumsum(count))
  plot_dat_district <- baselinelist[-rm_NA_district,] %>% group_by(District) %>% arrange(Date_confirmation) %>% mutate(cumsum=cumsum(count))
  
  ggplot(data = plot_dat_district, aes(x = Date_confirmation, y = log10(cumsum), group = District, color = District)) + geom_line(size = 1) + facet_wrap(~District) + xlab(" ") + ylab("Cumulative Ebola cases (log-scale)") + theme(legend.position = "none", legend.key = element_rect(fill = "#f0f0f0"), legend.background = element_rect(fill = "#ffffffaa", colour = "black"), panel.background = element_rect(fill = "white", colour = "black"), axis.text.y = element_text(colour = "black", size = 14), axis.text.x = element_text(colour = "black", size = 10), axis.title = element_text(colour = "black", size = 16), panel.grid.minor = element_line(colour = "#00000080",linetype = 3), panel.grid.major = element_line(colour = "#00000000", linetype = 3)) + geom_smooth(method = "lm", linetype = "dashed", width = 0.5, color = "#4d4d4d")
  
  ggplot(data = plot_dat_country, aes(x = Date_confirmation, y = log10(cumsum))) + geom_line(size = 1) + xlab(" ") + ylab("Cumulative Ebola cases (log-scale)") + theme(legend.position = "none", legend.key = element_rect(fill = "#f0f0f0"), legend.background = element_rect(fill = "#ffffffaa", colour = "black"), panel.background = element_rect(fill = "white", colour = "black"), axis.text.y = element_text(colour = "black", size = 14), axis.text.x = element_text(colour = "black", size = 10), axis.title = element_text(colour = "black", size = 16), panel.grid.minor = element_line(colour = "#00000080",linetype = 3), panel.grid.major = element_line(colour = "#00000000", linetype = 3)) + geom_smooth(method = "lm", linetype = "dashed", size = 0.5, color = "#4d4d4d")
  
  ggplot(data = baselinelist, aes(x = as.Date(Date_confirmation), fill = District)) + geom_bar() + facet_wrap(~District) + xlab("2022") + ylab("Daily new Ebola cases") + theme(legend.position = "none", legend.key = element_rect(fill = "#f0f0f0"), legend.background = element_rect(fill = "#ffffffaa", colour = "black"), panel.background = element_rect(fill = "white", colour = "black"), axis.text.y = element_text(colour = "black", size = 14), axis.text.x = element_text(colour = "black", size = 10), axis.title = element_text(colour = "black", size = 16), panel.grid.minor = element_line(colour = "#00000080",linetype = 3), panel.grid.major = element_line(colour = "#00000000", linetype = 3)) 
  
  time_reg <- as.numeric(plot_dat_district$Date_confirmation - min(plot_dat_district$Date_confirmation, na.rm = TRUE), unit = "days")
  prov_reg <- plot_dat_district$District
  cases_reg <- plot_dat_district$cumsum
  mod <- lmer(log(cases_reg+1) ~ time_reg + (time_reg|prov_reg))
  doubling <- data.frame(row.names(ranef(mod)$prov_reg), log(2)/(ranef(mod)$prov_reg$time_reg+fixef(mod)["time_reg"]))
  colnames(doubling) <- c("District", "Doubling Time (days)")
  doubling <- doubling[order(doubling$`Doubling Time (days)`),]
  
  by_date <- by(baselinelist$ID, baselinelist$Date_confirmation, length)
  by_date_dates <- names(by_date)
  by_date_dates <- as.POSIXct(strptime(c(as.character(by_date_dates)), format = "%Y-%m-%d"))
  cases_by_date <- as.numeric(by_date)
  miss_date <- which(by_date_dates == last_date)
  if(length(miss_date) == 0){
    add_dates <- round_date(seq(max(by_date_dates), last_date, by = 60*60*24), unit = "days")
    nmiss <- as.numeric(last_date - max(by_date_dates), unit = "days")
    by_date_dates <- c(by_date_dates, add_dates[-1])
    cases_by_date <- c(cases_by_date, rep(0, nmiss))
  }
  time_reg_country <- as.numeric(by_date_dates - min(by_date_dates, na.rm = TRUE), unit = "days")
  cases_reg_country <- rollmean(cases_by_date, k = 3)
  mod2 <- lm(log(cases_reg_country+0.01) ~ time_reg_country[-c(1:2)])
  doubling_country <- log(2)/mod2$coefficients[2]
  
  plot(by_date_dates[-c(1:2)], cases_reg_country, type = "l", bty = "n", lwd = 3, xlab = "2022", ylab = "Daily new Ebola cases (3 day avg)", ylim = c(0, ceiling(max(cases_reg_country))))
  
  rates <- rep(NA, length(cases_reg_country))
  for(i in 1:(length(cases_reg_country)-2)){
    mod.i <- lm(log(cases_reg_country[i:(i+2)]+0.01) ~ time_reg_country[-c(1:2)][i:(i+2)])
    rates[i] <- mod.i$coefficients[2]
  }
  plot(by_date_dates[-c(1:2)], rates, type = "l", bty = "n", lwd = 3, xlab = "2022", ylab = "Growth rate (new daily cases 3-day avg.)")
}
