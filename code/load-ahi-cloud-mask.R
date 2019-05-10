
#### cloud mask data ####

flnm <- flist_ahi_cloud_mask[grep(my_date, flist_ahi_cloud_mask)]
#print(basename(flnm))
# or setup a specific case study time point
#flnm <- "/home/public_share_data/ivan.hanigan_sydney/Private_with_Smoke_plumes_JFSP/AHI_cloud_masks/AHI_cloud_masks_JFSP_ML_smoke_usa/data_provided_NT_2015/AHI_cloud_masks_20150911_0650_135.0--18.0_138.0--16.0.nc"

# CODING MISSING/ VALID(Aerosol vs clear sky)

ncin         <- nc_open(flnm)
names(ncin$var)
# [1] "OD"       "flags"    "type"     "rtoa_b1"  "rtoa_b2"  "rtoa_b3"  "rtoa_b4" "rtoa_b5"  "tmpr_b14"
# Yi's data classifier is type
# unsigned byte type[pixels,lines]   (Contiguous storage)  
# _FillValue: 0
# desc: cloud type
# types: 
#   type_code    type_name
# 10           cirrus_-20
# 11           cirrus_-50
# 12           cirrus_-50_small
# 13           cumulus_cont_clean
# 14           cumulus_cont_poll
# 15           cumulus_maritime
# 16           fog
# 17           stratus_cont
# 18           stratus_maritime
# 100          smoke(fresh)        
# 101          smoke(aged)        
# 102          dust               
# 103          absorptive         
# 110          bright smoke(fresh)
# 111          bright smoke(aged) 
# 113          bright absorptive  
# Email from Yi to Ivan 2018-08-08: the types 23, 27 and 33, 37 are new smoke types used to capture smoke in NSW/VIC/TAS
type <- ncvar_get(ncin, varid = "type")
od <- ncvar_get(ncin, varid = "OD")

#table(od, useNA = "always") # there are 1548 NAs
#min(od[!is.na(od)]) # there are no zeros
# Yi uses python and other tools, not R. Looks like R reads the fillValue as NA but should be zero
od[is.na(od)] <- 0
# now apply the scaling 
od_attr <- ncatt_get(ncin, varid = "OD")
od <- od * od_attr$scaling
#we keep type, renamed z with no adjustment. we adjust by od > threshold, as z2 below
z <- type
#data.frame(table(z, useNA = "always")) ## 7 NAs
# But these are shown as zero in python, which means unclassified/invald. 

# now we want to use the "flags" value to indicated invalid/missing; clouds
flags0 <- ncvar_get(ncin, varid = "flags")
# table(flags0, useNA = "always") # no NAs
# if there were any, recall that R sees NAs where  Yi's software sees fillValue 0s
flags0[is.na(flags0)] <- 0

# this is bitwise data and so we need to use the bitwAnd operator
# the first flag represents valid/invalid, we'll make a new matrix to put data in
flags <- flags0

# and now isolate the first bit
flags[,] <- bitwAnd(flags0, 1)
# table(flags, useNA= "always") 
# there are 17434 "0s" and 7 "1s" on the 20150911_0100 
# we can use this to indiciate which pixels are valid
# but first, because it is 0 = valid, so flip it around so 1 is valid, 0 is invalid
# flags2 <- abs(flags - 1)
# and now if it is invalid make it NA
# flags2[flags2 == 0] <- NA

flags2 <- ifelse(flags == 0, 1, NA)
# now only keep type if OD is greater than threshold (we leave the originals in case future users want to adjust that option)
#od_threshold <- 0.5
z2 <- type * (od > od_threshold)
# QC to sanity check what happens here 110 * (0.52 > od_threshold)
# table(type, useNA = "always")
# table(z2, useNA = "always")
# WE ASK QUESTIONS ABOUT THE NATURE OF OD BELOW 0.5.  DOES THIS IMPLY CLEAR SKY OR WOULD IT MEAN THAT THE TYPE CANNOT BE DETERMINED, YET WE CANNOT ASSUME IT NECESSARILY MEANS CLEAR...

# DEPRECATED! ERROR! THE 0 TYPE MEANS UNCLASSIFIED/INVALID. I had originally thought that as Yi's software  sees NA as 0, but R sees them as NA, so set this (this would capture anY type pixels that are NA, the od has been done above)
#z2[is.na(z2)] <- 0
#data.frame(table(z2, useNA = "always"))

# and finally apply the flags (1 or NA)
# table(flags2, useNA = "always")
z2 <- z2 * flags2
#data.frame(table(z2, useNA = "always"))

# second bit is cloud
flags_cl <- flags0[,]
flags_cl[,] <- bitwAnd(flags0, 2)
#table(flags_cl, useNA = "always")
# this shows there are 17158 "0s" and 283 "2s" on 20150911_0100
# so type in these pixels should be over-ruled by cloud flag

# bitwise data is interesting as it depends on what the 0/1 value of each bit is, for example 00000001 is set first bit, 00000010 is second bit set
# therefore 00000011 is both first and second, so would mean invalid, cloudy
# but why is the result of bitwAnd(flags0, 2) = 0 / 2?
# we need more info about how the AND operator compares two integer bitwise
# https://code.tutsplus.com/articles/understanding-bitwise-operators--active-11301
# so the result is the number that represents the corresponding bits
# table(flags0[which(flags_cl %in% 2)])
# flags0[which(flags_cl %in% 2)[1:6]]
# flags_cl[which(flags_cl %in% 2)[1:6]]
# https://www.convertbinary.com/numbers/
# 38 = 0100110
#  2 = 0000010
# results in 2
# 54 = 0110110
#  2 = 0000010
# also results in 2
# 70 = 1000110
#  2 = 0000010
# also results in 2
# 86 = 1010110
#  2 = 0000010
# also results in 2
# to look at pixels where any of the 4-7 bits are set we can use this shortcut
# 2^4 +  2^5 + 2^6 + 2^7 = 240
# table(bitwAnd(flags0, 240), useNA = "always")



# sometimes there is missing columns in the ncdf files
if(length(names(ncin$var)) == 9){
# Top of atmosphere reflectance band 1-3
rtoa_b1      <- ncvar_get(ncin, varid = "rtoa_b1")
rtoa_b1_attr <- ncatt_get(ncin, varid = "rtoa_b1")
rtoa_b1_scaled <- rtoa_b1 * rtoa_b1_attr$scaling
b1 <- rtoa_b1_scaled

rtoa_b2      <- ncvar_get(ncin, varid = "rtoa_b2")
rtoa_b2_attr <- ncatt_get(ncin, varid = "rtoa_b2")
rtoa_b2_scaled <- rtoa_b2 * rtoa_b2_attr$scaling
b2 <- rtoa_b2_scaled

rtoa_b3      <- ncvar_get(ncin, varid = "rtoa_b3")
rtoa_b3_attr <- ncatt_get(ncin, varid = "rtoa_b3")
rtoa_b3_scaled <- rtoa_b3 * rtoa_b3_attr$scaling
b3 <- rtoa_b3_scaled

rtoa_b4      <- ncvar_get(ncin, varid = "rtoa_b4")
rtoa_b4_attr <- ncatt_get(ncin, varid = "rtoa_b4")
rtoa_b4_scaled <- rtoa_b4 * rtoa_b4_attr$scaling
b4 <- rtoa_b4_scaled

rtoa_b5      <- ncvar_get(ncin, varid = "rtoa_b5")
rtoa_b5_attr <- ncatt_get(ncin, varid = "rtoa_b5")
rtoa_b5_scaled <- rtoa_b5 * rtoa_b5_attr$scaling
b5 <- rtoa_b5_scaled

tmpr_b14      <- ncvar_get(ncin, varid = "tmpr_b14")
tmpr_b14_attr <- ncatt_get(ncin, varid = "tmpr_b14")
tmpr_b14_scaled <- tmpr_b14 * tmpr_b14_attr$scaling
tmpr_b14 <- tmpr_b14_scaled
} else {
  b1 <- z
  b1[,] <- NA
  b2 <- b1
  b3 <- b1
  b4 <- b1
  b5 <- b1
  tmpr_b14 <- b1
}


# stitch 
z1 <- z[i1:i2, j1:j2]
fl1 <- flags[i1:i2, j1:j2]
fl2 <- flags_cl[i1:i2, j1:j2]
z2v2 <- z2[i1:i2, j1:j2]
od1 <- od[i1:i2, j1:j2]
b1 <- b1[i1:i2, j1:j2]
b2 <- b2[i1:i2, j1:j2]
b3 <- b3[i1:i2, j1:j2]
b4 <- b4[i1:i2, j1:j2]
b5 <- b5[i1:i2, j1:j2]
tmpr_b14 <- tmpr_b14[i1:i2, j1:j2]

ahi_df<- data.frame(x = melt(lons1)$value,
                    y = melt(lats1)$value,
                    CLOUD_MASK_TYPE = melt(z1)$value,
                    FLAGS_VALID = melt(fl1)$value,
                    FLAGS_CLOUD = melt(fl2)$value,
                    CLOUD_MASK_TYPE_VALID = melt(z2v2)$value,
                    OD = melt(od1)$value,
                    B1 = melt(b1)$value,
                    B2 = melt(b2)$value,
                    B3 = melt(b3)$value,
                    B4 = melt(b4)$value,
                    B5 = melt(b5)$value,
                    TMPR_B14 = melt(tmpr_b14)$value)
#ahi_df[ahi_df$FLAGS != 0,c("CLOUD_MASK_TYPE", "FLAGS", "CLOUD_MASK_TYPE_VALID", "OD")]
ahi_df$gid <- 1:nrow(ahi_df)
str(ahi_df)
# TODO assumption is that database merge is faster than spatial extract
#pts <- SpatialPointsDataFrame(coords = ahi_df[,1:2], data = ahi_df, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
nc_close(ncin)
