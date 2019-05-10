
#### add the hotspot data for this date ####

hotspots <- readOGR(indir_htspt, infile_htspt)

#### subset to case study ####

htspt2 <- sp::over(hotspots, stdyreg_bb)
str(htspt2)
#plot(hotspots)
htspt3 <- hotspots
htspt3@data <- cbind(hotspots@data, htspt2)
htspt3 <- htspt3[!is.na(htspt3@data$e),]
#plot(htspt3, col = "red", add = T)

str(htspt3@data)
htspt3@data$ACQ_DATEV2 <- as.Date(as.character(htspt3@data$ACQ_DATE))

dates_i <- names(table(htspt3@data$ACQ_DATEV2))
dates_i

names(table(htspt3@data$ACQ_TIME))
## is this UTC?
## AHI cloud mask data is 10 minute intervals, so truncate the time
htspt3@data$ACQ_TIMEV2 <- sprintf("%s0", substr(as.character(htspt3@data$ACQ_TIME), 1, 3))
# TODO fix this quick hack to round up or down
htspt3@data$ACQ_DATEV3 <- paste(gsub("-","",htspt3@data$ACQ_DATEV2),htspt3@data$ACQ_TIMEV2,  sep = "_")
head(htspt3@data[htspt3@data$ACQ_DATE == "2015/09/12",c("ACQ_DATEV2", "ACQ_DATE", "ACQ_TIME", "ACQ_TIMEV2", "ACQ_DATEV3")])

## QC stuff.  TODO deprecated, remove from script?
# png("foo.png", res = 100, width = 1000, height = 1000)
# par(mfrow=c(4,4))
# for(date_i in dates_i[7:(10+4+4+4)]){
#   plot(htspt3[htspt3@data$ACQ_DATEV2 == date_i,], xlim =c(135,138), ylim = c(-18.8, - 16))
#   title(date_i)
# }
# dev.off()
## looking at this the 11th-12th is an interesting period
# for(i in 12){
#   date_i <- dates_i[i]
#   writeOGR(htspt3[htspt3@data$ACQ_DATEV2 == date_i,], "working", sprintf("hotspots_NT_%s", date_i), driver = "ESRI Shapefile")
# }

