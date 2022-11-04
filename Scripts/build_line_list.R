#SV Scarpino
#Oct 2022
#CSV for Ebola SitReps in Uganda into line list

###########
#libraries#
###########

#########
#Globals#
#########
files <- list.files("../Data/CSVs")
time_stamp <- format(Sys.time(), "%m-%d-%Y")
save_new <- FALSE

###########
#Acc Funcs#
###########
add_new_cases <- function(baselinelist, sitrep, row_to_add, sitrep_number, N, probable = FALSE){
  if(is.na(N) == TRUE | N == 0){
    return(baselinelist)
  }
  for(n in 1:N){
    add.n <- rep(NA, ncol(baselinelist))
    baselinelist <- rbind(baselinelist, add.n)
    baselinelist$ID[nrow(baselinelist)] <- baselinelist$ID[nrow(baselinelist)-1] + 1
    baselinelist$Pathogen[nrow(baselinelist)] <- "Ebola virus"
    if(probable == TRUE){
      baselinelist$Case_status[nrow(baselinelist)] <- "Probable"
    }else{
      baselinelist$Case_status[nrow(baselinelist)] <- "Confirmed"
    }
    baselinelist$District[nrow(baselinelist)] <- sitrep$DISTRICT[row_to_add]
    baselinelist$County[nrow(baselinelist)] <- sitrep$COUNTY[row_to_add]
    baselinelist$Sub.County[nrow(baselinelist)] <- sitrep$SUBCOUNTY[row_to_add]
    baselinelist$Country[nrow(baselinelist)] <- "Uganda"
    baselinelist$Date_confirmation[nrow(baselinelist)] <- sitrep$Date[row_to_add]
    baselinelist$Source[nrow(baselinelist)] <- paste0("https://www.afro.who.int/countries/uganda/publication/ebola-virus-disease-uganda-sitrep-", sitrep_number)
    baselinelist$Date_entry[nrow(baselinelist)] <- as.character(Sys.time())
    baselinelist$Curator_initials[nrow(baselinelist)] <- sitrep$Collector[row_to_add]
  }
  return(baselinelist)
}

###################
#Loop through CSVs#
###################
baselinelist <- read.csv("../Data/Ebola SitReps Uganda Baseline.csv")
basesitrep <- read.csv(paste0("../Data/CSVs/", files[1]))
reduce_cases_prob <- c()
reduce_cases_con <- c()
for(i in 2:length(files)){
  sitrep.i <- read.csv(paste0("../Data/CSVs/", files[i]))
  sitrepnumber.i <- files[i]
  sitrepnumber.i <- gsub(pattern = "sitrep_", replacement = "", x = sitrepnumber.i)
  sitrepnumber.i <- gsub(pattern = ".csv", replacement = "", x = sitrepnumber.i)
  
  locs_base.i <- paste0(basesitrep$DISTRICT, basesitrep$COUNTY, basesitrep$SUBCOUNTY)
  locs_sit.i <- paste0(sitrep.i$DISTRICT, sitrep.i$COUNTY, sitrep.i$SUBCOUNTY)
  
  for(j in 1:length(locs_sit.i)){
    mt.j <- which(locs_sit.i[j] == locs_base.i)
    if(length(mt.j) > 1){
      stop("Multiple location matches")
    }
    if(length(mt.j) == 0){
      baselinelist <- add_new_cases(baselinelist = baselinelist, sitrep = sitrep.i, row_to_add = j, sitrep_number = sitrepnumber.i, N = sitrep.i$Confirmed.Cases[j], probable = FALSE)
      baselinelist <- add_new_cases(baselinelist = baselinelist, sitrep = sitrep.i, row_to_add = j, sitrep_number = sitrepnumber.i, N = sitrep.i$Probable.Cases[j], probable = TRUE)
      next()
    }
    diff.con.ij <- sitrep.i$Confirmed.Cases[j] - basesitrep$Confirmed.Cases[mt.j]
    diff.prob.ij <- sitrep.i$Probable.Cases[j] - basesitrep$Probable.Cases[mt.j]
    if(is.na(diff.prob.ij) == TRUE){
      diff.prob.ij <- 0
    }
    if(diff.con.ij == 0 & diff.prob.ij == 0){
      next()
    }
    if(diff.con.ij < 0){
      reduce_cases_con <- c(reduce_cases_con, paste0(locs_sit.i[j], "_", sitrepnumber.i))
    }else{
      if(diff.con.ij > 0){
        baselinelist <- add_new_cases(baselinelist = baselinelist, sitrep = sitrep.i, row_to_add = j, sitrep_number = sitrepnumber.i, N = diff.con.ij, probable = FALSE)
      }
    }
    
    if(diff.prob.ij < 0){
      reduce_cases_prob <- c(reduce_cases_prob, paste0(locs_sit.i[j], "_", sitrepnumber.i))
    }else{
      if(diff.prob.ij > 0){
        baselinelist <- add_new_cases(baselinelist = baselinelist, sitrep = sitrep.i, row_to_add = j, sitrep_number = sitrepnumber.i, N = diff.prob.ij, probable = TRUE)
      }
    }
    
  }
  basesitrep <- sitrep.i
}

if(save_new == TRUE){
  write.csv(baselinelist, file = paste0("../Data/Line lists/",time_stamp,"_uganda_ebola_2022_linelist.csv"), row.names = FALSE, quote = FALSE)
}else{
  write.csv(baselinelist, file = paste0("../Data/tmp/",time_stamp,"_uganda_ebola_2022_linelist.csv"), row.names = FALSE, quote = FALSE)
}