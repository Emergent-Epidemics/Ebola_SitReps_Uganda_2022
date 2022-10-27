#SV Scarpino
#Oct 2022
#Download PDF Ebola SitReps from Uganda

###########
#libraries#
###########
library(pdftools)
library(lubridate)
library(glue)
library(xml2)

#########
#Globals#
#########
start <- as.POSIXct(strptime("2022-09-21", format = "%Y-%m-%d"))
end <- as.POSIXct(strptime(substr(Sys.time(), 1, 10), format = "%Y-%m-%d")) 
reports <- 1:as.numeric(end - start) #reports 1 - 9 and 11 are not online

###############
#Download PDFs#
###############

pb <- txtProgressBar(1, length(reports), style=3)
missed <- c()
for(i in reports){
  file.i <- paste0("https://www.afro.who.int/countries/uganda/publication/ebola-virus-disease-uganda-sitrep-", i)
  
  html.i <- try(paste(readLines(file.i), collapse="\n"), silent = TRUE)
  
  if(length(grep("try-error", html.i, ignore.case = TRUE)) > 0){
    missed <- c(missed, i)
    setTxtProgressBar(pb, i)
    next()
  }
  
  split.i <- strsplit(x = html.i, split = "[ ]")
  find.i <- grep(pattern = ".pdf", x = split.i[[1]])
  pdf_site.i <- split.i[[1]][find.i[3]]
  pdf_site.i_subquote <- gsub(pattern = "\"", replacement = "", pdf_site.i)
  pdf_site.i_subhref <- gsub(pattern = "href=", replacement = "", pdf_site.i_subquote)
  
  dest.i <- paste0("../Data/PDFs/", i, ".pdf")
  try.i <- try(download.file(url = pdf_site.i_subhref, destfile = dest.i), silent = TRUE)
  if(length(grep("error", try.i, ignore.case = TRUE)) > 0){
    missed <- c(missed, i)
  }
  setTxtProgressBar(pb, i)
}