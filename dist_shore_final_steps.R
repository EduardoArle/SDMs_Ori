# this script creates a layer for SDMs using distance files calculated in parallel on the cluster

# load packages
library(raster); library(sf)

wd_regional <- '/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Local variables'
wd_distances <- '/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Values_distance'
  
# load depth layer
setwd(wd_regional)
depth <- raster('coast_raster_depth.tif')

#duplicate the raster layer we use as base
dist_empty <- depth

#load files with distances calculated in the cluster
setwd(wd_distances)
dists <- lapply(list.files(), readRDS)

#files came with NAs in the non calculates parts, fix it!
dist1 <- dists[[1]]
dist2 <- dists[[2]][c(10000001:20000000)]
dist3 <- dists[[3]][c(20000001:30000000)]
dist4 <- dists[[4]][c(30000001:40000000)]
dist5 <- dists[[5]][c(40000001:50000000)]
dist6 <- dists[[6]][c(50000001:60000000)]
dist7 <- dists[[7]][c(60000001:70000000)]
dist8 <- dists[[8]][c(70000001:80000000)]
dist9 <- dists[[9]][c(80000001:length(dists[[9]]))]

#make a list
dists_fixed <- list(dist1, dist2, dist3, dist4, dist5, dist6, dist7, dist8, dist9)

#concatenate all distances
dists_conc <- unlist(dists_fixed)

#replace values in the raster for latitude values
dist_empty[] <- dists_conc

#reset original NAs
dist_empty[which(is.na(depth[]))] <- NA

#write raster
setwd(wd_regional)
writeRaster(dist_empty, filename = 'Dist_to_shore.tif', format = 'GTiff')
