# load packages
library(sf)

# list relevant WDs
wd_occ <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Occurrence"
wd_shp <-  "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Shapefile"

# load shapefiles
ecoregions <- st_read(dsn = wd_shp, layer = "ecoregions")

# load occurrence data
setwd(wd_occ) 
occ <- read.csv("habitat data isr.csv")

# make spatial object from occurrence data
occ_sp <- st_as_sf(occ, coords = c('cordinate.lon', 'cordinate.lat'),
                      crs = st_crs(ecoregions))

# visualise the data
plot(st_geometry(ecoregions), col = 'azure', bg = 'khaki1') #plot region
plot(occ_sp, add =T, pch = 21, bg = 'red', col = 'black', cex = 0.7) #plot points
