# load packages
library(raster); library(sf); library(sdm)

# list relezvant WDs
wd_vars <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Local variables"
wd_occ <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Occurrence"
wd_results <- "/Users/carloseduardoaribeiro/Documents/Collaborations/Ori/Model_projections"

#load variables
setwd(wd_vars)
variables <- stack(lapply(list.files(), raster))
names(variables) <- gsub('.tif', '', list.files())

#load occurrences
setwd(wd_occ)
occ <- read.csv("habitat data isr.csv")

#harmonise the occurrence table with the requirements of the package
occ_sel <- occ[,c(14,4,5)]
names(occ_sel) <- c('occurrence', 'lon', 'lat')

#create a spatial points data frame
occ_sp <- occ_sel
coordinates(occ_sp) <- ~ lon + lat

#inform the geographic system
proj4string(occ_sp) <- crs(variables)

#prepare data object
data <- sdmData(fumula = occurrence ~ ., train = occ_sp, predictors = variables)

#run models
sdm_models <- sdm(occurrence ~ ., data = data, methods = c('glm', 'gam', 'rf'), 
                  replication = 'cv', cv.folds = 5, n = 5)

#visualise in gui
gui(sdm_models)

#make and plot the predictions
setwd(wd_results)
pred <- predict(sdm_models, newdata = variables, filename = 'Predictions.img')

