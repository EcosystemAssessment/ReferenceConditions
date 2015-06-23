# Author: Sparkle L. Malone
# Date: June 2015
# Objective: Evaluate refernce conditions using scPDSI to identify sample cells.
rm(list=ls())
# Upload Data Files into R from github:

library(raster)
library(rgdal)

yr.index <- seq(2000, 2013, 1)

pp <- stack('https://github.com/EcosystemAssessment/Data/raw/master/precipitation_00-13.tif')
names(pp) <- yr.index

normals<- stack('https://github.com/EcosystemAssessment/Data/raw/master/scPDSI_00-13.tif')
names(normals) <- yr.index

tmean <- stack('https://github.com/EcosystemAssessment/Data/raw/master/tmean_00-13.tif')
names(tmean) <- yr.index

tmin <- stack('https://github.com/EcosystemAssessment/Data/raw/master/tmin_00-13.tif')
names(tmin) <- yr.index

tmax <- stack('https://github.com/EcosystemAssessment/Data/raw/master/tmax_00-13.tif')
names(tmax) <- yr.index

rm(test3)



# Import shapefiles:
setwd( '~/git/Climate-Ecoregions/ShapeFiles')

# Extract mean baseline conditions by ecoregion.
setwd('~/git/ReferenceConditions/Shapefiles')

er.c <- readOGR('.', "S_USA.ClimateSections")
er.p <-readOGR(".", 'S_USA.EcoMapProvinces')

# Summary
par(mfrow=c(1,1))

er.df <- as.data.frame(er)
er.n <- er[, c(4:8)]

pp.avg<- calc(pp, fun=mean,na.rm=T)

er.n$ppt.avg <- extract(pp.avg, er.n)

#__________-------------_____________-----------_______________-------------_______________

#get number of cells
rc.1 <- matrix(c(-Inf, Inf, 0), ncol=3, byrow=TRUE) # Matrix
scpdsi.1 <- reclassify(scpdsi.yr[[2]], rc.1, right=T)
hist(scpdsi.1)$count

rm(rc.1, scpdsi.1)

# Summarize Normals information: Percental of continential US that is within the normal range.
Normals.summary <- data.frame(stringasfactors=F) # Creates a dataframe
Normals.summary[1:15,1] <- seq(2000, 2014, 1) # Adds year to the dataframe.
for (i in seq(1,15, 1)){
  Normals.summary[i,2]  <- ((hist(scpdsi.yr.normals,layer=i, ylim=c(10000, 80000))$counts)/476109)*100 
} # Calculates the percentage of cells in the normal range.

library(rasterVis)
levelplot(scpdsi.yr.normals) # plots of normal range



# Baseline Condition Layers:
pp.base <- mask(pp.usa , scpdsi.yr.normals)
tmean.base <- mask(tmean.usa , scpdsi.yr.normals)
tmin.base <- mask(tmin.usa , scpdsi.yr.normals)
tmax.base <- mask(tmax.usa , scpdsi.yr.normals)