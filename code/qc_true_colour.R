#qc <- read.csv("working/ahi_lc_and_htspt.csv", as.is = T)
dir("data_derived")
qc <- read.csv("data_derived/ahi_NT_10_minute_Sept01to232015_20181216.csv", as.is = T)

str(qc)
"
1 $ CLOUD_MASK_TYPE smoke is 
# 100          smoke(fresh)        
# 101          smoke(aged)        
# 110          bright smoke(fresh)
# 111          bright smoke(aged) 
# Yi says the new types 23, 27 and 33, 37 are smoke found in NSW and TAS
2 $ OD           cloud optical depth
3 B1 = Top of atmosphere reflectance band 1
4 B2 = Top of atmosphere reflectance band 2
5 B3 = Top of atmosphere reflectance band 3
6 B4 = Top of atmosphere reflectance band 4
7 B5 = Top of atmosphere reflectance band 5
8 TMPR_14 = Top of atmosphere reflectance band 14
9  $ AHI_ID       ID for AHI pixels  : int  1 2 3 4 5 6 7 8 9 10 ...
10  $ PV           PV: Green Cover Fraction. 
11  $ NPV          NPV: Non-green cover fraction.
12 $ BS           BS: Bare ground fraction.  
13 $ FRP          Not sure. Fire Radiative Power?
14 $ TIMEPOINT     YYYYMMDD_HHMM
"
with(qc[qc$AHI_ID==77368,],
     plot(CLOUD_MASK_TYPE, type = "l")
)
#dev.off()
#### RGB ####
strtch <- function(x1, newmin, newmax){
  max2 <- newmax
  min2 <- newmin
  max1 <- max(x1)
  min1 <- min(x1)
  x2 <- (((x1 - min1)*(max2-min2))/(max1-min1))+min2
}
#### visualise ####
library(maps)
library(animation)
my_plot <- function(
  day_i = grep("20160117_0000", my_dates)
  ,
  nudgex = 0.1
  , 
  nudgey = 0.1
){

qc2 <- left_join(qc[qc$TIMEPOINT == my_dates[day_i],], r_stdyreg@data, by = c("AHI_ID" = "gid"))
#str(qc2)
#summary(qc2)

#summary(qc2[,c("B1","B2","B3")])
#qc2[!complete.cases(qc2[,c("x","y","B1","B2","B3")]),] 
#plot(qc2$x, qc2$y)

qc3 <- qc2[complete.cases(qc2[,c("x","y","B1","B2","B3")]),] 
if(nrow(qc3)!=0){
# summary(qc3)
# nclr <- 8
# library(RColorBrewer)
# library(classInt)
# plotclr <- brewer.pal(nclr,"BuPu")
# class <- classIntervals(qc3$B1, nclr, style="quantile")
# colcode <- findColours(class, plotclr)
# 
# with(qc3,plot(x,y,col = colcode))
# following https://shekeine.github.io/visualization/2014/09/27/sfcc_rgb_in_R
#Mosaic raw landsat tifs
#qc3[order(qc3$x, qc3$y),]
#head(qc3)
# b1 <- qc3[,c("x", "y", "B1")]  
# head(b1)
# h <- 520
# w <- 266
# b1m <- matrix(b1$B1, nrow = h, ncol = w)
# # Rasterize this.
# b1r <- raster(b1m)
# #plot(b1r)
# b2 <- qc3[,c("x", "y", "B2")]  
# b2m <- matrix(b2$B2, nrow = h, ncol = w)
# # Rasterize this.
# b2r <- raster(b2m)
# #plot(b2r)
# b3 <- qc3[,c("x", "y", "B3")]  
# b3m <- matrix(b3$B3, nrow = h, ncol = w)
# # Rasterize this.
# b3r <- raster(b3m)
# #plot(b3r)
# 
# raw_lt <- stack(c(b1r, b2r, b3r))
# nlayers(raw_lt)
# #plotRGB(raw_lt, r = 3, g = 2, b = 1)
# # bah
# #Scale to 0-255 range for display device
# mb_ras <- stretch(x=raw_lt, minv=0, maxv=255)
# 
# #Coerce raster into dataframe with coordinate columns for each pixel centre: for ggplot2
# mb_df <- raster::as.data.frame(mb_ras, xy=T)
# str(mb_df)
# mb_df <- data.frame(x=mb_df$x, y=mb_df$y, r=mb_df$layer.3, g=mb_df$layer.2, b=mb_df$layer.1)

# library(ggplot2)
# ggplot(data=mb_df, aes(x=x, y=y, fill=rgb(r,g,b, maxColorValue = 255))) + 
#   coord_equal() + theme_bw() + geom_tile() + scale_fill_identity() 


qc3$r <- strtch(qc3$B3, 0, 255)
qc3$g <- strtch(qc3$B2, 0, 255)
qc3$b <- strtch(qc3$B1, 0, 255)
} else {
  qc3 <- qc2
  qc3$r <- 0
  qc3$g <- 0
  qc3$b <- 255
  qc3 <- qc3[complete.cases(qc3[,c("x","y","r","g","b")]),] 
}
#head(qc3)
#map("world", )

with(qc3,plot(x,y,col = rgb(r,g,b, maxColorValue = 255)), xlim = c(r_stdyreg@bbox[1,1]-nudgex, r_stdyreg@bbox[1,2]+nudgex),  ylim = c(r_stdyreg@bbox[2,1]-nudgey, r_stdyreg@bbox[2,2]+nudgey), 
     mar = c(4,4,4,0))
     #xlim = c(139.8908, 153.4151), ylim = c(-43.18433, -35.83812))
map("world", add = T, col = 'lightgrey')
axis(1); axis(2)
title(my_dates[day_i])
qc3
}

qc3 <- my_plot(269)
qc_out <- r_stdyreg
qc3$rgb <- rgb(qc3$r,qc3$g,qc3$b, maxColorValue = 255)
qc_out@data <- left_join(qc_out@data, qc3, by =  c("gid" = "AHI_ID"))
writeOGR(qc_out, "working", "qc_true_colour_20150906", driver = "ESRI Shapefile", overwrite_layer = T)
## In QGIS compare to noted SO2 peak in borroloola/devil spring station
# 5th at 07:30 (UTC+9.30) is SO2 5 min peak

day_min <- 337
day_max <- day_min + 75#length(my_dates)#[todo_dates])#71
#day_i <- 57
#my_dates[day_i]
my_dates[day_min:day_max]
saveGIF(
  {
    ani.options(interval = 0.1)
    for(i in day_min:day_max){
      my_plot(i)
    }
  },
  outdir = getwd()
)
# file.rename("animation.gif", sprintf("data_derived/ahi_%s_10min_animation.gif", stdyreg))
# ## or with buttons
saveHTML(
  {
    ani.options(interval = 0.2)
    for(i in day_min:day_max){
      my_plot(i)
    }
  },
  outdir = getwd()
)
# # now without valid flagged
# my_plot <- function(
#   day_i = grep("20150901_0240", my_dates)
#   ,
#   show_missing = TRUE
#   ,
#   nudgex = 0.1
#   ,
#   nudgey = 0.1
# ){
#   qc2 <- left_join(qc[qc$TIMEPOINT == my_dates[day_i],], r_stdyreg@data, by = c("AHI_ID" = "gid"))
#   #str(qc2)
#   #summary(qc2)
#   map("world", xlim = c(r_stdyreg@bbox[1,1]-nudgex, r_stdyreg@bbox[1,2]+nudgex),  ylim = c(r_stdyreg@bbox[2,1]-nudgey, r_stdyreg@bbox[2,2]+nudgey),
#       mar = c(4,4,4,0))
#   axis(1); axis(2)
#   #, 23, 27, 33, 37
# 
#   with(qc2[qc2$CLOUD_MASK_TYPE %in% c( 101, 111 ),],
#        points(x, y, cex = .7, pch = 16, col = 'lightgrey')
#   )
# 
#   with(qc2[qc2$CLOUD_MASK_TYPE %in% c( 100, 110 ),],
#        points(x, y, cex = .7, pch = 16, col = 'darkgrey')
#   )
#   with(qc2[qc2$FRP > 0,],
#        points(x, y, cex = .7, pch = 16, col = 'red')
#   )
#   if(show_missing){
#     with(qc2[is.na(qc2$CLOUD_MASK_TYPE),],
#          points(x, y, cex = .7, pch = 16, col = 'blue')
#     )
#   }
#   title(my_dates[day_i])
#   legend("topright", legend = c("Hotspots", "Fresh smoke", "Aged smoke", "Missing"), col = c("red", "darkgrey", "lightgrey", "blue"), pch = 16)
# }
# 
# saveHTML(
#   {
#     ani.options(interval = 0.2)
#     for(i in 1:day_max){
#       my_plot(i)
#     }
#   },
#   outdir = getwd()
# )
