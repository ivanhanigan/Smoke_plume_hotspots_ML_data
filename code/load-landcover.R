# in this script we want to extract landcover values for the pixels in our study region
#### functions ####


#### load a landcover raster ####
# TODO this will need to be done for a batch of multiple layers per time point
# TODO the selection of valid dates from the landcover collection needs to be smarter
# TODO remove the download process from this project and make a landcover proj
# x <- as.Date('2015-09-12')
# date_j <- yday(x)+2
# #[1] 255 but that is not in this 8-day list, 257 is good, it is the 14th
# date_i <- x+2



"
PV: Green Cover Fraction. 
NPV: Non-green cover fraction.
BS: Bare ground fraction. 
"
# if(download_vege == T){
#   x <- as.Date('2015-09-06')
#   date_j <- yday(x)
#   date_js <- seq(date_j,date_j + 8*3, by = 8)
#   date_i <- x
#   date_is <- seq(date_i,date_i + 8*3, by = 8) 
# for(date_Iplus in 1:length(date_js)){
#   
#   print(date_is[date_Iplus])
#   
# for(vege_type in c("PV", "NPV", "BS")){
#   #vege_type <- "PV"
#   infile <- sprintf("FC.v310.MCD43A4.A%s%s.aust.006.%s.tif",year_i, date_js[date_Iplus], vege_type)  
#   infile
#   outfile <- sprintf("FC.v310.MCD43A4.A_%s_aust.006.%s.tif", date_is[date_Iplus], vege_type)
#   outfile  
# download.file(sprintf("http://www-data.wron.csiro.au/remotesensing/MODIS/products/Guerschman_etal_RSE2009/v310/australia/8day/cover/%s/%s",year_i, infile), file.path("working",outfile))
# }
# }
# }

# TODO need to figure out hwo to select closest yday
x <- paste(substr(my_date,1,4), substr(my_date,5,6), substr(my_date,7,8), sep = "-")
x <- as.Date(x)
x <- landcover_dates2[which.min(abs(x - as.Date(landcover_dates2)))]
for(vege_type in c("PV", "NPV", "BS")){
  #vege_type <- "PV"
  infile_landcover <- sprintf("FC.v310.MCD43A4.A_%s_aust.006.%s.tif",
                    x, vege_type)  
  print(infile_landcover)
  r <- raster(file.path(indir_landcover,infile_landcover))
  #plot(r)

#### subset the raster to our study region ####
r2 <- crop(r, stdyreg_bb)
# str(r2)
# plot(r2)
# DEPRECATED infile_subset <- sprintf("%s", gsub(".tif", "_nt_bb.tif", infile))
# writeRaster(r2, 
#             infile_subset, 
#             overwrite = T
#             )

# load the cropped raster
# r2 <- raster(infile_subset)

# convert to points
# TODO is it easy to use raster-to-raster extraction?
if(vege_type == "PV"){
  r2coords <- coordinates(r2)
  #head(r2coords)
  r2v2 <- as.data.frame(r2)
  names(r2v2) <- vege_type
  #head(r2v2)
  r2_out <- cbind(r2coords, r2v2)
} else {
  r2v2 <- as.data.frame(r2)
  names(r2v2) <- vege_type
  r2_out <- cbind(r2_out, r2v2)  
}
}
# head(r2_out)
# so now we have the lat, lon and value of the landcover pixels
r2_out$gid <- 1:nrow(r2_out)
pts_r2 <- SpatialPointsDataFrame(coords = r2_out[,1:2], data = r2_out, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
