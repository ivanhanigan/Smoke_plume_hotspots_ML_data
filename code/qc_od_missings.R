## QC missing data in OD
library(ncdf4)
od_threshold <- 0.5
flnm <- "/home/public_share_data/ivan.hanigan_sydney/Private_with_Smoke_plumes_JFSP/AHI_cloud_masks/AHI_cloud_masks_JFSP_ML_smoke_usa/data_provided_NT_2015/AHI_cloud_masks_20150901_0000_135.0--18.0_138.0--16.0.nc"
flnm <- "http://dapds00.nci.org.au/thredds/dodsC/rr5/satellite/products/himawari8/FLDK/2018/02/20/20180220000000-P1S-ABOM_CMP-PRJ_GEOS141_2000-HIMAWARI8-AHI.nc"
ncin         <- nc_open(flnm)
ncin
type <- ncvar_get(ncin, varid = "type")
type_attr <- ncatt_get(ncin, varid = "type")
cat(type_attr[["types"]])
type[1:5,1:5]
table(type, useNA = "always")
## there are 247 NAs in type, and no zeros (at least according to R)

od <- ncvar_get(ncin, varid = "OD")
od[1:11,1:5]
min(od[!is.na(od)])
## The NA?s are not in the original files. It is the so?ware/tool you used to read the files that probably interpreted 0?s as NA. So if you are sure the so?ware is interpre?ng 0?s as NA, then it should be safe to just treat those as no aerosol.
## to test this I opened it in Panoply and looked at the plot / array which shows as 0s cells that in R show as NA.  Then I exprted to CSV and although it is rotated 90 degress
odqc <- read.csv("~/Desktop/OD.csv")
all(!is.na(odqc))
## so we could set if OD NA then zero else OD 
od[is.na(od)] <- 0
## but we should check?

od_attr <- ncatt_get(ncin, varid = "OD")
str(od_attr)
od_attr$scaling
0.002
od <- od * od_attr$scaling
od[1:5,1:5]
z <- type * (od > od_threshold)
z[1:5,1:5]
table(z, useNA = "always")
"
z
   0  100  101  113 <NA> 
8140    8   10    9 9274 

1) If the invalid bit in flags is set (i.e., flags is an odd number), there is no data at all or the sun is too low (roughly, less than 15 degrees above horizon)
but I see the metadata says 0 = invalid, 1 = cloudy, 2= land, 4-7 = confidence
but the values in flags are diff
"
flags <- ncvar_get(ncin, varid = "flags")
flags[1:11,1:5]
flags_attr <- ncatt_get(ncin, varid = "flags")
str(flags_attr)
cat(flags_attr[["description"]])
data.frame(table(flags, useNA = "always"))
# one NA
which(is.na(flags))
vv <- flags[124:126,1:5]
vv
od2 <- od[124:126,1:5]
od2
## we can look at each bit, bit_0 signifies invalid and this is bit position 1
vv[,] <- bitwAnd(vv, 1)
vv <- abs(vv - 1)
vv[vv == 0] <- NA
vv
od2 * vv

# compared to original
od2

"
2) If type is zero (means unclassified/invalid), then for some reason classifica?on has failed. I believe this situa?on is rare.
"
data.frame(table(type, useNA = "always"))
## there are no zeros, but there are NAs in R, I think these may be 0s in Yi's view

"
3) A zero is a valid value for OD meaning there is no cloud/aerosol. A type s?ll exist in such cases (not zero)
"
data.frame(table(od, useNA = "always"))
## prior to resetting NA there were 9274