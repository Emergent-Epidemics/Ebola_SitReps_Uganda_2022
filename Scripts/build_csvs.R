#SV Scarpino
#Oct 2022
#PDF to CSV for Ebola SitReps in Uganda

###########
#libraries#
###########
library(pdftools)
library(lubridate)
library(glue)
library(maptools)
library(rgdal)
library(lubridate)

#########
#Globals#
#########
start <- as.POSIXct(strptime("2022-09-20", format = "%Y-%m-%d"))
end <- as.POSIXct(strptime(substr(Sys.time(), 1, 10), format = "%Y-%m-%d")) 
dates <- round_date(seq(start, end, by = 60*60*24), unit = "days")
files <- list.files("../Data/PDFs/")
save_new <- TRUE
auto_run <- TRUE
subcounties <- readOGR("../Data/subcounties_2019/subcounties_2019.shp")

#some dates are skipped
skip1 <- which(dates == as.POSIXct(strptime("2022-10-15", format = "%Y-%m-%d")))
dates <- dates[-skip1]

skip2 <- which(dates == as.POSIXct(strptime("2022-10-28", format = "%Y-%m-%d")))
dates <- dates[-skip2]

skip3 <- which(dates == as.POSIXct(strptime("2022-11-04", format = "%Y-%m-%d")))
dates <- dates[-skip3]

skip4 <- which(dates == as.POSIXct(strptime("2022-11-08", format = "%Y-%m-%d")))
dates <- dates[-skip4]

skip5 <- which(dates == as.POSIXct(strptime("2022-11-09", format = "%Y-%m-%d")))
dates <- dates[-skip5]

skip6 <- which(dates == as.POSIXct(strptime("2022-11-11", format = "%Y-%m-%d")))
dates <- dates[-skip6]

skip7 <- which(dates == as.POSIXct(strptime("2022-12-02", format = "%Y-%m-%d")))
dates <- dates[-skip7]

skip8 <- which(dates == as.POSIXct(strptime("2022-12-03", format = "%Y-%m-%d")))
dates <- dates[-skip8]

skip9 <- which(dates == as.POSIXct(strptime("2022-12-06", format = "%Y-%m-%d")))
dates <- dates[-skip9]

skip10 <- which(dates %in% c(as.POSIXct(strptime("2022-12-08", format = "%Y-%m-%d")), as.POSIXct(strptime("2022-12-09", format = "%Y-%m-%d")), as.POSIXct(strptime("2022-12-10", format = "%Y-%m-%d"))))
dates <- dates[-skip10]

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

match_subcounties <- function(subcounty_sitrep, subcounty_shp){
  subcounty_vect <- toupper(subcounty_sitrep$`Sub-County`)
  subcounty_vect[which(subcounty_vect == "BUTOLOGO")] <- "BUTOLOOGO"
  subcounty_vect[which(subcounty_vect == "BUTOLOGOA")] <- "BUTOLOOGO" #misspelling in sitrep40
  subcounty_vect[which(subcounty_vect == "BAYEZA")] <- "BAGEZZA"
  subcounty_vect[which(subcounty_vect == "BAGEZA")] <- "BAGEZZA"
  subcounty_vect[which(subcounty_vect == "NANSSANA")] <- "NANSANA"
  subcounty_vect[which(subcounty_vect == "BULENGA TC")] <- "BUWENGE TOWN COUNCIL"
  subcounty_vect[which(subcounty_vect == "KIMANYA-KYABAKUZA")] <- "KIMAANYA-KYABAKUZA"
  subcounty_official <- subcounty_shp$Subcounty
  subcounty_official <- gsub(pattern = " DIVISION", replacement = "", x = subcounty_shp$Subcounty)
  county_official <- subcounty_shp$County
  
  district <- rep(NA, length(subcounty_vect))
  county <- rep(NA, length(subcounty_vect))
  subcounty <- rep(NA, length(subcounty_vect))
  for(m in 1:length(subcounty_vect)){
    subcount.m <- subcounty_vect[m]
    if(subcount.m %in% c("KIRUUMA", "KIRWANYI")){
      district[m] <- "MUBENDE"
      county[m] <- NA
      subcounty[m] <- subcount.m
      next()
    }
    subcount.m <- gsub(pattern = " TC", replacement = "", x = subcount.m)
    mt.m <- which(subcounty_official == subcount.m)
    if(length(mt.m) == 0){
      mt.m <- which(county_official == subcount.m)
      mt.m <- mt.m[1]
      district[m] <- subcounty_shp$District[mt.m]
      county[m] <- subcounty_shp$County[mt.m]
      next()
    }
    if(length(mt.m) != 1){
      if(mt.m[1] == 1311 & subcount.m == "KASSANDA"){
        mt.m <- mt.m[1]
      }else{
        if(subcount.m %in% c("EASTERN", "WESTERN", "SOUTHERN", "KASAMBYA")){
          mt.m <- mt.m[which(subcounty_shp$District[mt.m] == "MUBENDE")]
        }else{
          stop("Multiple sub-county mathces")
        }
      }
    }
    district[m] <- subcounty_shp$District[mt.m]
    county[m] <- subcounty_shp$County[mt.m]
    subcounty[m] <- subcounty_shp$Subcounty[mt.m]
  }
  test.m <- which(is.na(subcounty) == TRUE & ! subcounty_vect %in% c("GOMBA", "BUSIRO"))
  if(length(test.m) > 0){
    stop("Missed matching at least one sub-county")
  }
  dat.out <- data.frame(district, county, subcounty)
  colnames(dat.out) <- c("DISTRICT", "COUNTY", "SUBCOUNTY")
  return(dat.out)
}

###################
#Loop through PDFs#
###################
data_full <- list()
failed <- c()

for(i in 10:length(files)){
  file.i <- paste0("../Data/PDFs/", files[i])
  pdf.i <- pdf_text(file.i)
  data_split.i <- strsplit(pdf.i, "\n")
  
  if(i < 22|i==30){
    find_data.i <- grep(pattern = "Summary of Confirmed Cases and probable deaths by Sub-County", x = data_split.i, ignore.case = TRUE)
  }else{
    if(i > 31){
      if(i == 36){
        find_data.i <- grep(pattern = " Summary table showing the distribution of cases by subcounty", x = data_split.i, ignore.case = TRUE)
      }else{
        find_data.i <- grep(pattern = "Summary of Confirmed Cases, Recoveries and Deaths", x = data_split.i, ignore.case = TRUE)
      }
    }else{
      find_data.i <- grep(pattern = "Summary of Cases updates by Sub-county", x = data_split.i, ignore.case = TRUE)
    }
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
    if(i == 36){
      find_data_stop.i <- grep(pattern = "Rubaga", x = data_split.i.2, ignore.case = TRUE)
      find_data_stop.i <- find_data_stop.i + 1
    }else{
      find_data_stop.i <- grep(pattern = "harmonisation", x = data_split.i.2, ignore.case = TRUE)
    }
  }
  
  if(length(find_data_stop.i) == 0){
    failed <- c(failed, i)
    next()
  }
  find_data_stop.i <- find_data_stop.i[1]
  
  if(i == 10 | i >= 30){
    do_recovery <- TRUE
  }else{
    do_recovery <- FALSE
  }
  
  if(i < 23 | i == 33){
    do_probable_cases <- FALSE
    do_probable_deaths <- TRUE
  }else{
    do_probable_cases <- TRUE
    do_probable_deaths <- FALSE
  }
  
  if(i > 19 & i < 30){
    find_data_start.i <- find_data_start.i + 1
  }

  
  data_out.i <- extract_data(data_split = data_split.i.2, data_start = find_data_start.i, data_stop = find_data_stop.i, recoveries = do_recovery, probable_cases = do_probable_cases, probable_deaths = do_probable_deaths)
  
  if(i == 36){
    #the PDF switches the column order
    hold.recover.i <- data_out.i$`Probable Cases`
    hold.probcase.i <- data_out.i$Recoveries
    data_out.i$Recoveries <- hold.recover.i
    data_out.i$`Probable Cases` <- hold.probcase.i
  }
  
  #correct division misplacement
  find_subcount_div.i <- grep(pattern = "division", x = data_out.i$`Sub-County`, ignore.case = TRUE)
  data_out.i$`Sub-County`[find_subcount_div.i] <- data_out.i$District[find_subcount_div.i]
  
  data_out.i$SitRep <- rep(i+10, nrow(data_out.i))
  
  date.i <- as.character(dates[i+10])
  
  data_out.i$Date <- rep(date.i, nrow(data_out.i))
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
  match_subcounties.i <- match_subcounties(subcounty_sitrep = data_out.i, subcounty_shp = subcounties)
  data_out.i <- data.frame(data_out.i, match_subcounties.i)
  
  data_full[[i]] <- data_out.i
  if(save_new == TRUE){
    if(auto_run == TRUE & files[i] %in% success){
      write.csv(data_out.i, file = paste0("../Data/CSVs/sitrep_", i+10, ".csv"), row.names = FALSE, quote = FALSE)
    }else{
      write.csv(data_out.i, file = paste0("../Data/tmp/sitrep_", i+10, ".csv"), row.names = FALSE, quote = FALSE)
    }
  }
}

dat.35 <- data_full[[33]]
dat.36 <- data_full[[36]]
mt <- match(paste0(dat.35$DISTRICT,dat.35$COUNTY, dat.35$SUBCOUNTY), paste0(dat.36$DISTRICT,dat.36$COUNTY, dat.36$SUBCOUNTY))
dat.36 <- dat.36[mt,]
