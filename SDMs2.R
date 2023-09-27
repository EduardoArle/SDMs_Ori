# load packages
library(raster); library(sf); library(geosphere)

# list relevant WDs
wd_regional <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Local variables"
wd_shps <- '/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Shapefile'

# load depth layer
setwd(wd_regional)
depth <- raster('coast_raster_depth.tif')

##### CREATE NEW LAYERS TO USE AS VARIABLES #####

## LATITUDE

#duplicate the raster layer we use as base
lat_1 <- depth

#get y coordinates from each cell in the raster layer
lat_values <- yFromCell(lat_1, c(1:length(lat_1)))

#replace values in the raster for latitude values
lat_1[] <- lat_values

#reset original NAs 
lat_1[which(is.na(depth[]))] <- NA

#write raster
writeRaster(lat_1, filename = 'Latitude.tif', format = 'GTiff')


## DISTANCE TO THE COAST

#duplicate the raster layer we use as base
dist_1 <- depth

#load shp Israeli coast
shp_coast <- st_read('Shore_rtg_200208', dsn = wd_shps)

#change object coordinate system to match the raster
shp_coast_WGS84 <- st_transform(shp_coast, crs = proj4string(dist_1))

#visualise
plot(dist_1, add = F, axes = F, legend = F, box = F)
plot(st_geometry(shp_coast_WGS84), add= T, lwd = 1)

#get x and y coordinates from each cell in the raster layer
coord_values <- xyFromCell(dist_1, c(1:length(dist_1)))

#calculate dist from each cell to the coast (forloop)
dist_values <- numeric()

for(i in 1:nrow(coord_values))
{
  dist_values[i] <- dist2Line(p = coord_values[i,], 
                              line = st_coordinates(shp_coast_WGS84)[,1:2])
  print(i)
}

#replace values in the raster for latitude values
dist_1[] <- dist_values

#reset original NAs 
dist_1[which(is.na(depth[]))] <- NA

#write raster
writeRaster(dist_1, filename = 'Dist_to_shore.tif', format = 'GTiff')
