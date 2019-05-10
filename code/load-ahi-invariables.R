locs <- nc_open(file.path(indir_ahi, infile_ahi))
lats    <- ncvar_get(locs, varid = "latitude")
lons    <- ncvar_get(locs, varid = "longitude")
locs_df <- data.frame("lons" = melt(lons)$value, "lats" = melt(lats)$value)

# if you want to set up a smaller subregion
lon_range <- as.numeric(stdyreg_bb@bbox[1, ])#+1
lat_range <- as.numeric(stdyreg_bb@bbox[2, ])#-.5

# subset
m1 <- matrix(ifelse(lons >= lon_range[1] & lons <= lon_range[2], 1, 0), nrow(lons), ncol(lons))
m2 <- matrix(ifelse(lats >= lat_range[1] & lats <= lat_range[2], 1, 0), nrow(lats), ncol(lats))

# save indices
if(max(m1[, 1]) == 1){
  ii <- range(which(m1[, 1]==1)); 
} else {
  ii <- lon_range
}
i1 <- ii[1]; 
i2 <- ii[2]

if(max(m2[1,]) == 1){
  jj <- range(which(m2[1, ] == 1));
} else {
  jj <- lat_range
}
j1 <- jj[1]; 
j2 <- jj[2]

# make submatrices
lons1 <- lons[i1:i2, j1:j2]
lats1 <- lats[i1:i2, j1:j2]

h <- dim(lats1)[1]
w <- dim(lons1)[2]
nc_close(locs)
