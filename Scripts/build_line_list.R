#SV Scarpino
#Oct 2022
#CSV for Ebola SitReps in Uganda into line list

###########
#libraries#
###########

###########
#Acc Funcs#
###########
add_new_cases <- function(baselinelist, sitrep, row_to_add, sitrep_number, N){
  for(n in 1:N){
    add.n <- rep(NA, ncol(baselinelist))
    baselinelist <- rbind(baselinelist, add.n)
    baselinelist$ID[nrow(baselinelist)] <- baselinelist$ID[nrow(baselinelist)-1] + 1
    baselinelist$Pathogen[nrow(baselinelist)] <- "Ebola virus"
    baselinelist$Pathogen_status[nrow(baselinelist)] <- "Confirmed"
    baselinelist$Location[nrow(baselinelist)] <- sitrep$District[row_to_add]
    baselinelist$Sub_Region[nrow(baselinelist)] <- sitrep$Sub.County[row_to_add]
    baselinelist$Country[nrow(baselinelist)] <- "Uganda"
    baselinelist$Date_confirmation[nrow(baselinelist)] <- sitrep$Date[row_to_add]
    baselinelist$Source[nrow(baselinelist)] <- paste0("https://www.afro.who.int/countries/uganda/publication/ebola-virus-disease-uganda-sitrep-", sitrep_number)
    baselinelist$Date_entry[nrow(baselinelist)] <- as.character(Sys.time())
    baselinelist$Curator_initials[nrow(baselinelist)] <- sitrep$Collector[row_to_add]
  }
  return(baselinelist)
}
  
#########
#Globals#
#########
files <- list.files("../Data/CSVs")
save_new <- TRUE

###################
#Loop through CSVs#
###################
baselinelist <- read.csv("../Data/Ebola SitReps Uganda Baseline.csv")
basesitrep <- read.csv(paste0("../Data/CSVs/", files[1]))
reduce_cases <- c()
for(i in 2:length(files)){
  sitrep.i <- read.csv(paste0("../Data/CSVs/", files[i]))
  sitrepnumber.i <- files[i]
  sitrepnumber.i <- gsub(pattern = "sitrep_", replacement = "", x = sitrepnumber.i)
  sitrepnumber.i <- gsub(pattern = ".csv", replacement = "", x = sitrepnumber.i)
  
  locs_base.i <- paste0(basesitrep$District, basesitrep$Sub.County)
  locs_sit.i <- paste0(sitrep.i$District, sitrep.i$Sub.County)
  
  for(j in 1:length(locs_sit.i)){
    mt.j <- which(locs_sit.i[j] == locs_base.i)
    if(length(mt.j) > 1){
      stop("Multiple location matches")
    }
    if(length(mt.j) == 0){
      baselinelist <- add_new_cases(baselinelist = baselinelist, sitrep = sitrep.i, row_to_add = j, sitrep_number = sitrepnumber.i, N = sitrep.i$Confirmed.Cases[j])
      next()
    }
    diff.ij <- sitrep.i$Confirmed.Cases[j] - basesitrep$Confirmed.Cases[mt.j]
    if(diff.ij == 0){
      next()
    }
    if(diff.ij < 0){
      reduce_cases <- c(reduce_cases, paste0(locs_sit.i[j], "_", sitrepnumber.i))
      next()
    }
    baselinelist <- add_new_cases(baselinelist = baselinelist, sitrep = sitrep.i, row_to_add = j, sitrep_number = sitrepnumber.i, N = diff.ij)
  }
  basesitrep <- sitrep.i
}

if(save_new == TRUE){
  time_stamp <- format(Sys.time(), "%m-%d-%Y")
  write.csv(baselinelist, file = paste0("../Data/tmp/",time_stamp,"_uganda_ebola_2022_linelist.csv"), row.names = FALSE, quote = FALSE)
}