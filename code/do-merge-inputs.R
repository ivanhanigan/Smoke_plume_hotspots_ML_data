#### now merge ####
#### Land cover ####
if(do_landcover){
proj4string(r_stdyreg) <- proj4string(pts_r2)
#e_LC <- extract(r_stdyreg, pts_r2)
e_LC <- sp::over(pts_r2, r_stdyreg)

head(e_LC)
e_LCv2 <- cbind(pts_r2@data, e_LC)
names(e_LCv2)[ncol(e_LCv2)] <- "AHI_ID"
head(e_LCv2)
setDT(e_LCv2)
e_LCv3 <- e_LCv2[,.(PV = sum(PV)/length(PV), NPV = sum(NPV)/length(NPV), BS = sum(BS)/length(BS)), AHI_ID]
head(e_LCv3)
}
#### hotspots ####
#hotspot_right_now <- htspt3[htspt3@data$ACQ_DATEV3 == my_date,]
# whoops no matches
# TODO check ok to link to any that day
hotspot_my_date <- htspt3[substr(htspt3@data$ACQ_DATEV3,1,8) == substr(my_date,1,8),]
#str(hotspot_my_date@data)
#table(hotspot_my_date@data$ACQ_DATEV3)
if(nrow(hotspot_my_date@data) != 0){
e_HS <- extract(r_stdyreg, hotspot_my_date)
#head(e_HS)
e_HSv2 <- cbind(hotspot_my_date@data[,c("ACQ_TIME", "INSTRUMENT", "CONFIDENCE", "FRP")], e_HS)
names(e_HSv2)[ncol(e_HSv2)] <- "AHI_ID"
#head(e_HSv2)
setDT(e_HSv2)
e_HSv3 <- e_HSv2[,.(FRP = mean(FRP)), AHI_ID]
#head(e_HSv3)
} else {
  e_HSv3 <- r_stdyreg@data
  #names(e_HSv3)
  names(e_HSv3)[ncol(e_HSv3)] <- "AHI_ID"
  e_HSv3 <- e_HSv3[,c("AHI_ID", "area")]
  }

#### merge ####
#head(ahi_df)
names(ahi_df) <- gsub("gid", "AHI_ID", names(ahi_df))
if(do_landcover){
ahi_lc <- left_join(ahi_df, e_LCv3, by = "AHI_ID")
ahi_lc_and_htspt <- left_join(ahi_lc, e_HSv3, by = "AHI_ID")
} else {
ahi_lc_and_htspt <- left_join(ahi_df, e_HSv3, by = "AHI_ID")
}
# summary(ahi_lc_and_htspt)
