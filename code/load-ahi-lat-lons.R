indir_stdyreg <- "/home/public_share_data/ivan.hanigan_sydney/Private_with_Smoke_plumes_JFSP/AHI_cloud_masks/AHI_cloud_masks_JFSP_ML_smoke_usa/data_derived"
dir(indir_stdyreg)
#infiles_stdyreg <- sprintf("pts_vor_grid0003_%s_20180809.tif", toupper(stdyreg))
infiles_stdyreg <- sprintf("pts_vorV2_%s", toupper(stdyreg))
#r_stdyreg   <- raster(file.path(indir_stdyreg, infiles_stdyreg))
r_stdyreg <- readOGR(indir_stdyreg, infiles_stdyreg)

#### DEPRECATED JUNK ####

## this failed due to data size
# library(rgdal)
# library(ncdf4)
# library(raster)
# projdir <- "~/ownCloud/Staging_area/JFSP/JFSP_ML_smoke_plume_hotspots"
# setwd(projdir)
# setwd("~/projects/AHI_cloud_masks/AHI_cloud_masks_JFSP_ML_smoke_usa")
# 
# # this was from download.file("http://hpc.csiro.au/users/254864/ML_smoke/AHI_cloud_masks_invariables_L3281-4296_P1191-3520.nc", destfile = "data_provided/AHI_cloud_masks_invariables_L3281-4296_P1191-3520.nc")
# 
# infile <- "data_provided/AHI_cloud_masks_invariables_L3281-4296_P1191-3520.nc"
# nc <- nc_open(infile)
# print(nc)
# str(nc)
# lat <- ncvar_get(nc, varid="latitude")
# y <- as.vector(lat)
# str(y)
# lon <- ncvar_get(nc, varid="longitude")
# x <- as.vector(lon)
# length(x) == length(unique(x))
# 
# setwd(projdir)
# 
# nt_bb <- readOGR("working", "nt-bounding-box")
# nt_bb@bbox
# 
# x2 <- x[x >= nt_bb@bbox[1,1] & x <= nt_bb@bbox[1,2]]
# y2 <- y[y >= nt_bb@bbox[2,1] & y <= nt_bb@bbox[2,2]]
# x3 <- unique(x2)
# y3 <- unique(y2)
# 
# for(i in 1:10){
#   
# grd <- merge(,)
# }
