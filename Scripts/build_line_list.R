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
    baselinelist$Pathogen <- "Ebola virus"
    baselinelist$Pathogen_status <- "Confirmed"
    baselinelist$Location <- sitrep$District[row_to_add]
    baselinelist$Sub_Region <- sitrep$Sub.County[row_to_add]
    baselinelist$Country <- "Uganda"
    baselinelist$Date_confirmation <- sitrep$Date[row_to_add]
    baselinelist$Source <- paste0("https://www.afro.who.int/countries/uganda/publication/ebola-virus-disease-uganda-sitrep-", sitrep_number)
    baselinelist$Date_entry <- as.character(Sys.time())
    baselinelist$Curator_initials <- sitrep$Collector[row_to_add]
  }
  return(baselinelist)
}
  
#########
#Globals#
#########
files <- list.files("../Data/CSVs/", full.names = TRUE)
save_new <- TRUE

###################
#Loop through CSVs#
###################
baselinelist <- read.csv("../Data/Ebola SitReps Uganda Baseline.csv")
basesitrep <- read.csv(files[1])

for(i in 2:length(files)){
  sitrep.i <- read.csv(files[i])
  locs_base.i <- paste0(basesitrep$District, basesitrep$Sub.County)
  locs_sit.i <- paste0(sitrep.i$District, sitrep.i$Sub.County)
  
  align <- rep(NA, nrow(sitrep.i))
  for(j in 1:length(align)){
    mt.j <- which(locs_sit.i[j] == locs_base.i)
    if(length(mt.j) > 1){
      stop("Multiple location matches")
    }
    if(length(mt.j) == 0){
      add_new_cases(sitrep.i[j,])
    }
    align[j] <- mt.j

  }
}