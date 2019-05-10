library(maps)
library(animation)
library(data.table)
# rm(qc)
if(!exists("qc")){
#qc <- read.csv("working/ahi_lc_and_htspt.csv", as.is = T)
qc <- fread("data_derived/ahi_NT_10_minute_2015_1Sep_23Sep_20190208.csv")
str(qc)
}
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
unique(qc$TIMEPOINT)
# with(qc[qc$AHI_ID==77368,],
#      plot(CLOUD_MASK_TYPE, type = "l")
# )
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
my_plot <- function(
  day_i = grep("20150911_0100", as.character(my_dates))
  ,
  nudgex = 5
  , 
  nudgey = 5
  ,
  show_smoke = F
){

if(nrow(qc[qc$TIMEPOINT == my_dates[day_i],])>0){
qc2 <- left_join(qc[qc$TIMEPOINT == my_dates[day_i],], r_stdyreg@data, by = c("AHI_ID" = "gid"))
#str(qc2)
#summary(qc2)


qc3 <- qc2[complete.cases(qc2[,c("x","y","B1","B2","B3")]),] 
if(nrow(qc3)!=0){
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

with(qc3,plot(x,y,col = rgb(r,g,b, maxColorValue = 255), 
     xlim = c(r_stdyreg@bbox[1,1]-nudgex, r_stdyreg@bbox[1,2]+nudgex),  
     ylim = c(r_stdyreg@bbox[2,1]-nudgey, r_stdyreg@bbox[2,2]+nudgey), 
     mar = c(4,4,4,0))
     )
# , xlim = c(134.5, 138.5), ylim = c(-19, -15)
#     xlim = c(134.5, 138.5), ylim = c(-43.18433, -35.83812))
map("world", add = T, col = 'lightgrey')
axis(1); axis(2)
x <- strsplit(my_dates[day_i], "_")[[1]][1]
y <- substr(x, 1,4)
m <- substr(x, 5,6)
d <- substr(x, 7,8)
t <- x <- strsplit(my_dates[day_i], "_")[[1]][2]
h <- substr(t, 1, 2)
mn <- substr(t, 3, 4)
as.POSIXct(sprintf("%s-%s-%s %s:%s", y, m, d, h, mn))
utcdate <- as.POSIXct(sprintf("%s-%s-%s %s:%s", y, m, d, h, mn))
localdate <- as.character(utcdate + (60*60*9.5))
title(sprintf("Time in UTC = %s", my_dates[day_i]),sub = sprintf("Local time ACST/UTC+9:30 = %s", localdate))

if(show_smoke){
with(qc3[qc3$FRP > 0,],
    points(x, y, cex = .7, pch = 16, col = 'red')
)

# with(qc3[qc3$CLOUD_MASK_TYPE_VALID %in% c( 100, 110 ),],
#     points(x, y, cex = .7, pch = 16, col = 'darkgrey')
# )
#od_threshold <- 0.5
#head(ahi_df)
#qc3$CLOUD_MASK_TYPEV2 <- qc3$CLOUD_MASK_TYPE * (qc3$OD > od_threshold)
#qc3$CLOUD_MASK_TYPEV2 <- qc3$CLOUD_MASK_TYPE# * (qc3$OD > od_threshold)
with(qc3[qc3$CLOUD_MASK_TYPE_VALID %in% c( 101, 111, 23, 27, 33, 37 ),],
     points(x, y, cex = .7, pch = 16, col = 'black')
)

with(qc3[qc3$CLOUD_MASK_TYPE_VALID %in% c( 100, 110 ),],
     points(x, y, cex = .7, pch = 16, col = 'darkgrey')
)
with(qc3[is.na(qc3$CLOUD_MASK_TYPE_VALID),],
     points(x, y, cex = .7, pch = 16, col = 'blue')
)
with(qc3[qc3$FLAGS_CLOUD != 0 & 
        !(qc3$CLOUD_MASK_TYPE_VALID %in% c( 101, 111, 23, 27, 33, 37 , 100, 110)),],
     points(x, y, cex = .7, pch = 16, col = 'black')
)
# with(qc3[qc3$FLAGS_CLOUD != 0,],
#      points(x, y, cex = .7, pch = 16, col = 'green')
# )

legend("topleft", legend = c("htspt", "smk1", "smk2", "NA", "cloud"), pch = rep(16,4), col = c("red", "black", "darkgrey", "blue", "green"), cex = 0.6)

}
}
}
which(my_dates %in% "20150911_0650")
my_plot(day_i = 522,  
        nudgex = .25
        , 
        nudgey = .25, show_smoke = T)
# par(mfrow = c(2,5))
# for(i in 1:10){
# my_plot(i)
# }
#day_min <- 1
day_min <- which(my_dates %in% "20150911_0000")
#day_max <- day_min + (length(unique(qc$TIMEPOINT)) -1) #+ 350 #length(my_dates)#[todo_dates])#71
#day_max <- which(my_dates %in% max(qc[,"TIMEPOINT"]))
day_max <- which(my_dates %in% "20150913_2350")
#day_i <- 57
#my_dates[day_i]
my_dates[day_min:day_max]
getwd()
setwd("working_animations")
saveGIF(
  {
    for(i in day_min:day_max){
      par(mfrow = c(1,2))
      my_plot(i, nudgey = .4, nudgex = .1, show_smoke = F)
      my_plot(i, nudgey = .4, nudgex = .1, show_smoke = T)
    }
  },
  outdir = getwd(), interval = 0.1, ani.width =  750
)
# file.rename("animation.gif", sprintf("data_derived/ahi_%s_10min_animation.gif", stdyreg))
setwd("/home/public_share_data/ivan.hanigan_sydney/Private_with_Smoke_plumes_JFSP/Smoke_plume_hotspots_ML_JFSP")
# 
# # # ## or with buttons
getwd()
setwd("working_animations")
saveHTML(
  {
    ani.options(interval = 0.2)
    for(i in day_min:day_max){
      my_plot(i, nudgey = .4, nudgex = .1, show_smoke = T)
    }
  }
)
setwd("/home/public_share_data/ivan.hanigan_sydney/Private_with_Smoke_plumes_JFSP/Smoke_plume_hotspots_ML_JFSP")
# # datout <- qc[qc[,"TIMEPOINT"] %in% my_dates[day_min:day_max],]
# unique(datout$TIMEPOINT)
# TODO move this to spot in main? write.csv(datout, "data_derived/ahi_NT_10_minute_Nov15to182015_20190122.csv", row.names = F)

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
