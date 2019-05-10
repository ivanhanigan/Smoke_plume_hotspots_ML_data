
'name:load-nt-bounding-box'
library(rgdal)
library(sp)
e <- as(raster::extent(135, 138, -18.8, -16), "SpatialPolygons")
proj4string(e) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
plot(e)
str(e)
e2 <- SpatialPolygonsDataFrame(e, data = data.frame(e = "1"))
writeOGR(e2, "working", "nt-bounding-box", "ESRI Shapefile")
