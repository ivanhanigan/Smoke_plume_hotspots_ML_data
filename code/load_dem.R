library(velox)
# mjrds from previous (define in main script)
# today_date <- "20181023"
if(run_roads){
infile_majrds <- sprintf("ahi_%s_h_%s_w_%s_ids_and_majorroads_%s",stdyreg, h, w, today_date)
pts <- readOGR("data_derived", infile_majrds)
} else {
  pts <- r_stdyreg
}
indir_dem <- "/home/ivan.hanigan_sydney/ivan.hanigan_sydney_public/ownCloud/Staging_area/DEM_GEODATA/GEODATA_9second_version3/data_provided/Data_9secDEM_D8/"
infile_dem <- "dem-9s.asc"
dem <- raster(file.path(indir_dem, infile_dem))
proj4string(dem) <- pts@proj4string

vx <- velox(dem)
str(vx)
strt <- Sys.time()
DEM <- vx$extract(pts, fun = function(x) mean(x, na.rm = TRUE))
end <- Sys.time()
end - strt
head(DEM)

#infile_majrds
#dir("data_derived")  
pts2 <- pts
pts2@data <- cbind(pts2@data, DEM)
head(pts2@data)
proj4string(pts2)

infile_majrds2 <- sprintf("ahi_%s_h_%s_w_%s_ids_dem_and_majorroads_%s", stdyreg, h, w, today_date2)
writeOGR(pts2, "data_derived", infile_majrds2, driver = "ESRI Shapefile", overwrite_layer = T)
