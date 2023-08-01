# load packages
library(raster)

# list relevant WDs
wd_vars <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Variables"
wd_regional <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Local variables"
wd_regional_resampled <- ""

# load world variable layers
setwd(wd_vars)
vars <- stack(lapply(list.files(), raster))

# load world variable layers
setwd(wd_regional)
depth <- raster('coast_raster_depth.tif')

# harmonise the variables
depth_resampled <-resample(depth, vars) #resample depth
stack_all <-stack(vars, depth_resampled) #stack everything
stack_all_cropped <- crop(stack_all, depth) #crop everything by the extent of the depth layer
names(stack_all_cropped)[12] <- 'Depth'

# save layers
setwd(wd_regional)
for(i in 1:nlayers(stack_all_cropped))
{
  writeRaster(stack_all_cropped[[i]], 
              filename = paste0(names(stack_all_cropped)[i], ".tif"), 
              format="GTiff", overwrite=TRUE)
}


stack_all <- t
stack_all_cropped <- t2

?writeRaster


