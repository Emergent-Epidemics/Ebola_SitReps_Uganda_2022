#SV Scarpino
#Oct 2022
#PDF to CSV for Ebola SitReps in Uganda

###########
#libraries#
###########
library(pdftools)
library(lubridate)
library(glue)

###########
#Acc Funcs#
###########
extract_data <- function(data_split, data_start, data_stop, recoveries = FALSE, probable_cases = FALSE, probable_deaths = FALSE){
  first_data_row <- data_start+1
  last_data_row <- data_stop-1
  data.out <- matrix(NA, ncol = 7, nrow = 1)
  colnames(data.out) <- c("District", "Sub-County", "Confirmed Cases", "Confirmed Deaths", "Recoveries", "Probable Deaths", "Probable Cases")
  data.out <- as.data.frame(data.out)
  
  for(j in first_data_row:last_data_row){
    rm_empty.j <- which(data_split[[j]] == "")
    if(length(rm_empty.j) == 0){
      stop("I expected to find spaces")
    }
    if(length(rm_empty.j) == length(data_split[[j]])){
      stop("I found only spaces")
    }
    data.j <- data_split[[j]][-rm_empty.j]
    if(length(data.j) < 3){
      next()
    }
    
    TC_check.j <- grep(pattern = "TC", x = data.j, ignore.case = FALSE)
    if(length(TC_check.j) > 1){
      stop("I expected to find either zero or 1 instances of TC.")
    }
    if(length(TC_check.j) == 1){
      data.j[TC_check.j-1] <- paste(data.j[TC_check.j-1], "TC", sep = " ")
      data.j <- data.j[-TC_check.j]
    }
    
    if(recoveries == FALSE){
      last.data.point.j <- data.j[length(data.j)]
      data.j <- c(data.j[1:length(data.j)-1], NA, last.data.point.j)
    }
    
    if(probable_deaths == FALSE){
      last.data.point.j <- data.j[length(data.j)]
      data.j <- c(data.j[1:length(data.j)-1], NA, last.data.point.j)
    }
    
    if(probable_cases == FALSE){
      data.j <- c(data.j, NA)
    }
    if(! length(data.j) %in% c(6, 7)){
      stop("I too many or too few data points")
    }
    if(length(data.j) == 6){
      data.j <- c(NA, data.j)
    }
    data.out <- rbind(data.out, data.j)
  }
  data.out.final <- data.out[-1,]
  return(data.out.final)
}

#########
#Globals#
#########
start <- as.POSIXct(strptime("2022-09-21", format = "%Y-%m-%d"))
end <- as.POSIXct(strptime(substr(Sys.time(), 1, 10), format = "%Y-%m-%d")) 
dates <- seq(start, end, by = 60*60*24)
files <- list.files("../Data/PDFs/")
save_new <- TRUE

###################
#Loop through PDFs#
###################
data_full <- list()
failed <- c()

for(i in 10:length(files)){
  file.i <- paste0("../Data/PDFs/", files[i])
  pdf.i <- pdf_text(file.i)
  data_split.i <- strsplit(pdf.i, "\n")
  
  if(i < 22){
    find_data.i <- grep(pattern = "Summary of Confirmed Cases and probable deaths by Sub-County", x = data_split.i, ignore.case = TRUE)
  }else{
    find_data.i <- grep(pattern = "Summary of Cases updates by Sub-county", x = data_split.i, ignore.case = TRUE)
  }

  if(length(find_data.i) != 1){
    failed <- c(failed, i)
    next()
  }
  data_split.i.2 <- strsplit(data_split.i[[find_data.i]], " ")
  find_data_2.i <- grep(pattern = "County", x = data_split.i.2, ignore.case = TRUE)
  if(length(find_data_2.i) != 2){
    failed <- c(failed, i)
    next()
  }
  
  
  find_data_start.i <- find_data_2.i[2]
  if(length(grep(pattern = "Cases", x = data_split.i.2[[find_data_start.i+1]], ignore.case = TRUE)) > 0){
    find_data_start.i <- find_data_start.i + 1
  }
    
  if(i < 22){
    find_data_stop.i <- grep(pattern = "Total", x = data_split.i.2, ignore.case = TRUE)
  }else{
    find_data_stop.i <- grep(pattern = "harmonisation", x = data_split.i.2, ignore.case = TRUE)
  }
  
  if(length(find_data_stop.i) == 0){
    failed <- c(failed, i)
    next()
  }
  find_data_stop.i <- find_data_stop.i[1]
  
  if(i == 10){
    do_recovery <- TRUE
  }else{
    do_recovery <- FALSE
  }
  
  if(i < 23){
    do_probable_cases <- FALSE
    do_probable_deaths <- TRUE
  }else{
    do_probable_cases <- TRUE
    do_probable_deaths <- FALSE
  }
  
  if(i == 25){
    find_data_start.i <- find_data_start.i + 1
  }
  
  data_out.i <- extract_data(data_split = data_split.i.2, data_start = find_data_start.i, data_stop = find_data_stop.i, recoveries = do_recovery, probable_cases = do_probable_cases, probable_deaths = do_probable_deaths)
  
  data_out.i$SitRep <- rep(i+10, nrow(data_out.i))
  data_out.i$Date <- rep(as.character(dates[i+10]), nrow(data_out.i))
  data_out.i$Date_Entered <- as.character(Sys.time())
  data_out.i$Collector <- "Automated Script - https://github.com/Emergent-Epidemics/Ebola_SitReps_Uganda_2022"
  
  dupe_test.i <- table(data_out.i$`Sub-County`)
  rm_division <- which(names(dupe_test.i) == "Division")
  if(length(rm_division) > 0){
    dupe_test.i <- dupe_test.i[-rm_division]
  }
  if(length(which(dupe_test.i > 1)) > 0){
    if(max(dupe_test.i) > 2){
      stop("More duplications than I expected")
    }
    dupes.i <- which(dupe_test.i > 1)
    for(d in 1:length(dupes.i)){
      mt_dupe.d <- which(data_out.i$`Sub-County` == names(dupes.i)[d])
      
      data_out.i[mt_dupe.d[1],c("Confirmed Cases", "Confirmed Deaths", "Recoveries", "Probable Deaths", "Probable Cases")] <- colSums(rbind(as.numeric(data_out.i[mt_dupe.d[1],c("Confirmed Cases", "Confirmed Deaths", "Recoveries", "Probable Deaths", "Probable Cases")]),  as.numeric(data_out.i[mt_dupe.d[2],c("Confirmed Cases", "Confirmed Deaths", "Recoveries", "Probable Deaths", "Probable Cases")])), na.rm = TRUE)  
      data_out.i <- data_out.i[-mt_dupe.d[1],]
    }
  }
  
  data_full[[i]] <- data_out.i
  if(save_new == TRUE){
    write.csv(data_out.i, file = paste0("../Data/tmp/sitrep_", i+10, ".csv"), row.names = FALSE, quote = FALSE)
  }
}

