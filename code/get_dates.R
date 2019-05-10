get_dates <- function(years = 2015:2017, strt = "2015-07-01", end = NULL, hourly = T) {
  #end_date <- "2015-12-31"
  
  
  # get y, m, d
  start_date <- as.Date(strt, format = "%Y-%m-%d")
  end_date <- as.Date(end, format = "%Y-%m-%d")
  date_list  <- list()
  for (i in 1:length(years)){
    
#    end_date       <- ifelse(is.null(end_date), start_date %m+% months(4) - days(1), end_date)
    date_list[[i]] <- seq.Date(start_date, end_date, by = "day")
    start_date     <- start_date + years(1)
    
  }
  
  all_days  <- gsub("-", "", as.character(as.Date(unlist(date_list), origin=as.Date("1970-01-01"))))
  if(hourly){
  # get hours
    hrs       <- c("0000", "0100", "0200", "0300", "0400", "0500", "0600", "2300")
  } else {
    hrs <- c("0000", "0010", "0020", "0030", "0040", "0050", "0100", "0110", "0120", "0130", "0140", "0150", "0200", "0210", "0220", "0230", "0240", "0250", "0300", "0310", "0320", "0330", "0340", "0350", "0400", "0410", "0420", "0430", "0440", "0450", "0500", "0510", "0520", "0530", "0540", "0550", "0600", "0610", "0620", "0630", "0640", "0650", "2300", "2310", "2320", "2330", "2340", "2350")
  }
  # combine
  out  <- expand.grid(hrs, all_days)
  return(paste(out[, 2], "_", out[, 1], sep = ""))
  
}
#my_dates <- get_dates(hourly = F)
#my_dates[1:49]
