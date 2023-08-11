# load packages
library(raster); library(sf)

# list relevant WDs
wd_regional <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Local variables"

# load depth layer
setwd(wd_regional)
depth <- raster('coast_raster_depth.tif')

##### CREATE NEW LAYERS TO USE AS VARIABLES #####

## LATITUDE

#duplicate the raster layer we use as base
lat_1 <- depth

#get coordinates from each cell in the raster layer
lat_values <- yFromCell(lat_1, c(1:length(lat_1)))

#replace values in the raster for latitude values
lat_1[] <- lat_values

#reset original NAs 
lat_1[which(is.na(depth[]))] <- NA

#write raster
writeRaster(lat_1, filename = 'Latitude.tif', format = 'GTiff')


