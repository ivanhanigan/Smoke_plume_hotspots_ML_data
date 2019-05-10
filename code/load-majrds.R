indir_mjrds <- "/home/public_share_data/ivan.hanigan_sydney/Private_with_Smoke_plumes_JFSP/MAJRDS/"
infile_mjrds <- "MAJRDS"
mjrds <- readOGR(indir_mjrds, infile_mjrds)

shp_stdyreg <- readOGR("/home/public_share_data/ivan.hanigan_sydney/Private_with_Smoke_plumes_JFSP/AHI_cloud_masks/AHI_cloud_masks_JFSP_ML_smoke_usa/data_derived",sprintf("pts_vorV2_%s", toupper(stdyreg)))

# TODO this next line is a strong assumption!
mjrds@proj4string <- shp_stdyreg@proj4string

mjrds2 <- sp::over(mjrds, stdyreg_bb)
str(mjrds2)
mjrds3 <- mjrds
mjrds3@data <- cbind(mjrds@data, mjrds2)
mjrds3 <- mjrds3[!is.na(mjrds3@data$e),]
#plot(mjrds3)
dim(mjrds3@data)
#plot(shp_stdyreg, add = T)

lpi <- sp::over( shp_stdyreg, mjrds3)
summary(lpi)
mjrds4 <- shp_stdyreg
mjrds4@data <- cbind(mjrds4@data, lpi$e)
names(mjrds4@data)[ncol(mjrds4@data)] <- "MAJRDS"
head(mjrds4@data[mjrds4@data$MAJRDS %in% 1,])
names(mjrds4@data)[grep("gid", names(mjrds4@data))] <- "AHI_ID"
mjrds4@data$z <- NULL
# plot(mjrds4, col = mjrds4@data$MAJRDS)
# 
# #### DEPRECATED OLD CRAP ####
# #e_majrds <- extract(r_stdyreg, mjrds3, cellnumbers = T)
# #e_majrds <- rasterize(mjrds3, r_stdyreg, fun = "count")
# library(velox)
# r_stdyreg2 <- velox(r_stdyreg)
# e_majrds <- r_stdyreg2$extract(sp = mjrds3)
# 
# length(e_majrds)
# plot(mjrds3)#, add = T)
# plot(e_majrds[[1]])
# 
# e_majrdsv2 <- cbind(hotspot_my_date@data[,c("ACQ_TIME", "INSTRUMENT", "CONFIDENCE", "FRP")], e_majrds)
# names(e_majrdsv2)[ncol(e_majrdsv2)] <- "AHI_ID"
# head(e_majrdsv2)
# setDT(e_majrdsv2)
# e_majrdsv3 <- e_majrdsv2[,.(FRP = mean(FRP)), AHI_ID]
# head(e_majrdsv3)