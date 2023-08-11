# load packages
library(sf); library(raster); library(usdm); library(biomod2)
library(data.table)

# list relevant WDs
wd_regional_resampled <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Local variables resampled"
wd_occ <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Occurrence"
wd_results <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Results"

# load resampled variable layers
setwd(wd_regional_resampled)
vars <- stack(lapply(list.files(), raster))
names(vars) <- gsub('.tif', '', list.files())

# load occurrence data
setwd(wd_occ) 
occ <- read.csv("habitat data isr.csv")

# make spatial object from occurrence data
occ_sp <- st_as_sf(occ, coords = c('cordinate.lon', 'cordinate.lat'),
                   crs = st_crs(vars))

#extract values of all variables at each point
vals <- extract(vars, occ_sp)

#make a mirrored matrix of correlation
correl <- cor(vals, use = 'complete.obs')

#save
setwd(wd_results)
write.csv(correl, 'Correl_matrix.csv')

#check variance inflation factor (VIF) to select which are not too correlated
vif <- vifcor(vals, th = 0.7)

#### WE DID NOT LIKE THE VARIABLES IT CHOSE ####
#### LET'S TRY AGAIN KEEPING ONLY AVERAGE SALINITY #####

vals_2 <-  vals[,-c(7,9)]

#check variance inflation factor (VIF) to select which are not too correlated
vif_2 <- vifcor(vals_2, th = 0.7)

#save
setwd(wd_results)
write.csv(vif_2@results, 'Selected_vars_07.csv')

#make an object with only variables we have selectes
vars_sel <- vars[[which(names(vars) %in% vif_2@results$Variables)]]

plot(vars_sel)



####. MODDELS ####

# PREPAPRE  DATA

myBiomodData <- BIOMOD_FormatingData(
                    resp.var = as.numeric(occ_sp$seagrass_pres),
                    expl.var = vars_sel,
                    resp.xy = st_coordinates(occ_sp),  # אני מטומטמת 
                    resp.name = 'Weed')

myBiomodOptions <- BIOMOD_ModelingOptions()

myBiomodModelOut <- BIOMOD_Modeling(bm.format = myBiomodData,
                                    modeling.id = 'AllModels',
                                    models = c('GLM', 'RF', 'ANN'),
                                    bm.options = myBiomodOptions,
                                    nb.rep = 4,
                                    data.split.perc = 80,
                                    metric.eval = c('KAPPA','TSS','ROC'))


# Get evaluation scores & variables importance
evals <- get_evaluations(myBiomodModelOut)

setwd(wd_results)
write.csv(evals, 'Model_evaluations.csv')

myBiomodProj <- BIOMOD_Projection(bm.mod = myBiomodModelOut,
                                  proj.name ='current',
                                  new.env = vars_sel,
                                  selected.models ='all',
                                  binary.meth ='TSS',
                                  compress ='xz',
                                  clamping.mask = F,
                                  output.format ='.grd')

myCurrentProj <- get_predictions(myBiomodProj)

plot(myCurrentProj, col = heat.colors(20))


####### SCRAP #####




###### visualisation #####
plot(vars[[1]])
plot(occ_sp, add =T, pch = 21, bg = 'red', col = 'black', cex = 0.5) #plot points


plot(vars[[1]])
plot(occ_sp_2, add = T, pch = 19, col = 'black', cex = 0.2)

#### select only one point per pixel ####

#create ID raster
ID_raster <- vars[[1]]
ID_raster[] <- c(1:length(ID_raster))

#get ID cell of each point
ID_cells <- extract(ID_raster, occ_sp)
occ_sp$ID_cell <- ID_cells

#### keep only one point per cell, priority to presence

#make a data.table from occ_sp
occ_data_tab <- as.data.table(occ_sp)

#select by unique combination of occ status AND ID_cell
occ_sp_thinned <- unique(occ_data_tab, 
                         by = c('seagrass_pres', 'ID_cell'))
#identify cells with presence AND absence
pr_abs <- table(occ_sp_thinned$ID_cell)
pr_abs_2 <- as.numeric(names(which(pr_abs > 1)))

#delete rows with absences in the same cell as presences
occ_sp_thinned_2 <- occ_sp_thinned[!which(
  occ_sp_thinned$ID_cell %in% pr_abs_2 &
    occ_sp_thinned$seagrass_pres == 0),]

#select the points from the spatial object
occ_sp_2 <- occ_sp[occ_sp_thinned_2$X,]



#############


# Load species occurrences (6 species available)
myFile <- system.file('external/species/mammals_table.csv', package = 'biomod2')
DataSpecies <- read.csv(myFile, row.names = 1)
head(DataSpecies)

# Select the name of the studied species
myRespName <- 'GuloGulo'

# Get corresponding presence/absence data
myResp <- as.numeric(DataSpecies[, myRespName])

# Get corresponding XY coordinates
myRespXY <- DataSpecies[, c('X_WGS84', 'Y_WGS84')]

# Load environmental variables extracted from BIOCLIM (bio_3, bio_4, bio_7, bio_11 & bio_12)
myFiles <- paste0('external/bioclim/current/bio', c(3, 4, 7, 11, 12), '.grd')
myExpl <- raster::stack(system.file(myFiles, package = 'biomod2'))



# ---------------------------------------------------------------
# Format Data with true absences
myBiomodData <- BIOMOD_FormatingData(resp.var = myResp,
                                     expl.var = myExpl,
                                     resp.xy = myRespXY,
                                     resp.name = myRespName)
myBiomodData
plot(myBiomodData)