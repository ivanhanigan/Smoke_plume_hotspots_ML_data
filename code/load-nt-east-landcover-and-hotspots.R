# in this script we want to extract landcover values for the pixels in our study region
#### functions ####
library(raster)
library(lubridate)
library(rgdal)
library(dplyr)

#### load study region bounding box ####

nt_bb <- readOGR("working", "nt-bounding-box")
nt_bb@bbox

#### load a landcover raster ####
# TODO this will need to be done for a batch of multiple layers per time point
# TODO the selection of valid dates from the landcover collection needs to be smarter
x <- as.Date('2015-09-12')
yday(x)
#[1] 255 but that is not in this 8-day list, 257 is good, it is the 14th
date_i <- x+2


infile <- sprintf("working/FC%s.tif", date_i)
"
PV: Green Cover Fraction. 
NPV: Non-green cover fraction.
BS: Bare ground fraction. 
"
#download.file("http://www-data.wron.csiro.au/remotesensing/MODIS/products/Guerschman_etal_RSE2009/v310/australia/8day/cover/2015/FC.v310.MCD43A4.A2015257.aust.006.NPV.tif", infile)

r <- raster(infile)
plot(r)

#### subset the raster to our study region ####
# TODO this only needs to happen once, skip to re-do analysis
# r2 <- crop(r, nt_bb)
# str(r2)
# plot(r2)
infile_subset <- sprintf("%s", gsub(".tif", "_nt_bb.tif", infile))
# writeRaster(r2, 
#             infile_subset, 
#             overwrite = T
#             )

# load the cropped raster
r2 <- raster(infile_subset)
r2coords <- coordinates(r2)
head(r2coords)
r2v2 <- as.data.frame(r2)
head(r2v2)
r2_out <- cbind(r2coords, r2v2)
head(r2_out)
# so now we have the lat, lon and value of the landcover pixels
"         x         y FC2015.09.14_nt_bb
1 135.0045 -16.00042                 67
2 135.0092 -16.00042                 64
3 135.0139 -16.00042                 52
4 135.0186 -16.00042                 50
5 135.0233 -16.00042                 44
6 135.0280 -16.00042                 42
"

#### add the hotspot data for this date ####
indir_htspt <- "/home/public_share_data/ivan.hanigan_sydney/ownCloud/Shared/ResearchProjects_CAR/NASA_FIRMS_FIRE_AND_SMOKE/NASA_FIRMS_201509_Aust/data_provided"
infile_htspt <- "fire_archive_V1_4308"
hotspots <- readOGR(indir_htspt, infile_htspt)

#### subset to case study ####

htspt2 <- sp::over(hotspots, nt_bb)
str(htspt2)
plot(hotspots)
htspt3 <- hotspots
htspt3@data <- cbind(hotspots@data, htspt2)
htspt3 <- htspt3[!is.na(htspt3@data$e),]
plot(htspt3, col = "red", add = T)

str(htspt3@data)
htspt3@data$ACQ_DATEV2 <- as.Date(as.character(htspt3@data$ACQ_DATE))
head(htspt3@data[,c("ACQ_DATEV2", "ACQ_DATE", "ACQ_TIME")])
dates_i <- names(table(htspt3@data$ACQ_DATEV2))
dates_i
png("foo.png", res = 100, width = 1000, height = 1000)
par(mfrow=c(4,4))
for(date_i in dates_i[7:(10+4+4+4)]){
  plot(htspt3[htspt3@data$ACQ_DATEV2 == date_i,], xlim =c(135,138), ylim = c(-18.8, - 16))
  title(date_i)
}
dev.off()
## looking at this the 11th-12th is an interesting period
for(i in 13){
  date_i <- dates_i[i]
writeOGR(htspt3[htspt3@data$ACQ_DATEV2 == date_i,], "working", sprintf("hotspots_NT_%s", date_i), driver = "ESRI Shapefile")
}


#### now link ####
# first I tried extracting the raster values on hotspot locations
#e <- extract(r2, hotspots)
#head(e)
#e2 <- cbind(hotspots, e)
# but this gives us the hotspot's landcover value at that point...
# I think we actually want the landcover pixel's hotspot value (i.e. if the landcover cell has a hotspot point in it then it is a hotspot = 1, else not = 0)
# TODO it occurs to me this is actually a conservative approach. The hotspot data was actually a square pixel to begin with the edge of that may be in a neighbouring landcover pixel, but because we look at it as if it were a point, this information is lost.

# assign landcover pixels a feature id

r2_out$fid <- 1:nrow(r2_out)
head(r2_out)
r2_outv2 <- r2_out[,c("x", "y", "fid")]
# Rasterize just the fids
coordinates(r2_outv2) <- ~x + y
gridded(r2_outv2) <- TRUE
r2_outv3 <- raster(r2_outv2)

# so now if we use the extract function we will return the fid
e_v2 <- extract(r2_outv3, hotspots)
head(e_v2)
e2_v2 <- cbind(hotspots@data, e_v2)
names(e2_v2)[ncol(e2_v2)] <- "fid"
head(e2_v2)

# now we can do a join back on to the landcover pixels

lc_and_htspt <- left_join(r2_out, e2_v2, by = "fid")

write.csv(lc_and_htspt, "working/lc_and_htspt.csv", row.names = F)
# check in QGIS
