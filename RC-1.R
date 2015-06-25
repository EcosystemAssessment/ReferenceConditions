# Author: Sparkle L. Malone
# Date: June 2015
# Objective: Import datafiles of interest.

rm(list=ls())
# Upload Data Files into R from github:

library(raster)
library(rgdal)
library(rgeos)

yr.index <- seq(2000, 2013, 1) # Creates an index for the raster stacks

# Import raster files:
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

rm(yr.index)

# Import shapefiles:
setwd('~/git/Climate-Ecoregions/Shapefiles')

region.rpa <- readOGR('.', 'RPA_region2')
er.c <- readOGR('.', "S_USA.ClimateSections")
er.p <- readOGR('.', 'S_USA.EcoMapProvinces')
usa <- readOGR('.', 'USA_BOUNDARY')

# Reproject shapefiles
crs <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0' # Projection

region.rpa  <- spTransform(region.rpa , crs)
er.c <- spTransform(er.c, crs)
er.p <- spTransform(er.p, crs)
usa <- spTransform(usa, crs)

# Crop shapefiles by RPA region 2 border:
er.c <- crop( er.c, region.rpa)
er.p <- crop( er.p, region.rpa)
