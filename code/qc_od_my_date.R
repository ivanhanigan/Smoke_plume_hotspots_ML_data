day_i = grep("20160506_0400", my_dates)
qc2_shp <- r_stdyreg
qc2_shp@data <- left_join(qc2_shp@data, qc[qc$TIMEPOINT == my_dates[day_i],], by = c("gid" = "AHI_ID"))
writeOGR(qc2_shp, "working_temporary", "qc2_shp", driver = "ESRI Shapefile")
