# Author: Sparkle L. Malone
# Date: June 2015
# Objective: Aggregate scPDSI and extract reference conditions (2000-2014). 

rm(list=ls())

library(raster)
library(rgdal)

# Import scPDSI Data form local directory:
setwd('/Volumes/Promise Pegasus/Data/PRISM_scPDSI')
scpdsi.file.list <- list.files(path='.', pattern="scpdsi") # List of all files in the directory

# Create Index:
library(splitstackshape) # Used to extract the date from the file names.
scpdsi.index.df <- as.data.frame(scpdsi.file.list) # Creates a dataframe from the list of files.
scpdsi.index.df <- concat.split(scpdsi.index.df, 1, sep='_', drop=F) # Breaks up the file name.
scpdsi.index.df[,4]<- sprintf("%02d", scpdsi.index.df[,4])
scpdsi.index <- as.yearmon(paste(as.numeric(scpdsi.index.df[,3]),
                                 as.numeric(scpdsi.index.df[,4]), sep="-"))
# Create raster stack:
scpdsi<- stack(scpdsi.file.list)

# Add index to raster stack
library(zoo) 
scpdsi <- setZ(scpdsi,scpdsi.index, 'yearmon')
names(scpdsi) <- scpdsi.index

# Aggregate by year
scpdsi.yr <- zApply(scpdsi, by=year, fun=mean) 

# Creates an index for annnula data:
yr.index <- data.frame(names(scpdsi.yr))
yr.index <- concat.split(yr.index, 1, sep='X', drop=T)
yr.index <- list(yr.index[ , -1])

# Reclassify raster:
rc <- matrix(c(-Inf, -0.4, NA, -0.4, 0.4, 1,  0.4, Inf, NA), ncol=3, byrow=TRUE) # Matrix
scpdsi.yr.normals <- reclassify(scpdsi.yr, rc, right=T)
scpdsi.yr.normals <- setZ(scpdsi.yr.normals,yr.index,'year') # adds year
names(scpdsi.yr.normals) <- getZ(scpdsi.yr.normals) # Changes names to match year

#get number of cells
rc.1 <- matrix(c(-Inf, Inf, 0), ncol=3, byrow=TRUE) # Matrix
scpdsi.1 <- reclassify(scpdsi.yr[[2]], rc.1, right=T)
hist(scpdsi.1)$count

# Summarize Normals information: Percental of continential US that is within the normal range.
Normals.summary <- data.frame(stringasfactors=F) # Creates a dataframe
Normals.summary[1:15,1] <- seq(2000, 2014, 1) # Adds year to the dataframe.
for (i in seq(1,15, 1)){
  Normals.summary[i,2]  <- ((hist(scpdsi.yr.normals,layer=i, ylim=c(10000, 80000))$counts)/476109)*100 
} # Calculates the percentage of cells in the normal range.

library(rasterVis)
levelplot(scpdsi.yr.normals) # plots of normal range

# ________________________________________________________________________________#
# Mask parameters with the scPDSI normals to set thresholds for each eco-region:

library(prism)

# Import Prism Data:
options(prism.path = '/Volumes/Promise Pegasus/Data/PRISM/Precipitation/Annual')
pp.usa <- stack(ls_prism_data(absPath = TRUE, name=T)) 

options(prism.path = '/Volumes/Promise Pegasus/Data/PRISM/Temperature_mean/Annual')
tmean.usa <- stack(ls_prism_data(absPath = TRUE, name=T)) 

options(prism.path = '/Volumes/Promise Pegasus/Data/PRISM/Temperature_min/Annual')
tmin.usa <- stack(ls_prism_data(absPath = TRUE, name=T)) 

options(prism.path = '/Volumes/Promise Pegasus/Data/PRISM/Temperature_max/Annual')
tmax.usa <- stack(ls_prism_data(absPath = TRUE, name=T)) 

# add an index to climate data:
yr.index2 <- seq(2000, 2013, 1)
pp.usa <-setZ(pp.usa, yr.index2); names(pp.usa) <-getZ(pp.usa)
tmean.usa <-setZ(tmean.usa, yr.index2); names(tmean.usa) <-getZ(tmean.usa)
tmin.usa <-setZ(tmin.usa, yr.index2); names(tmin.usa) <-getZ(tmin.usa)
tmax.usa <-setZ(tmax.usa, yr.index2); names(tmax.usa) <-getZ(tmax.usa)

scpdsi.yr.normals <- scpdsi.yr.normals[[1:14]] # Temporary subset scpdsi- PRISM climate data is not yet available for 2014.
scpdsi.yr.normals <-setZ(scpdsi.yr.normals, yr.index2); names(scpdsi.yr.normals) <-getZ(scpdsi.yr.normals)

projection(pp.usa)
crs(scpdsi.yr)

# Reproject rasters:
pp.usa <- projectRaster(pp.usa,scpdsi.yr, method = 'bilinear' )
tmean.usa <- projectRaster(tmean.usa,scpdsi.yr, method = 'bilinear' )
tmin.usa <- projectRaster(tmin.usa,scpdsi.yr, method = 'bilinear' )
tmax.usa <- projectRaster(tmax.usa,scpdsi.yr, method = 'bilinear' )

# Baseline Condition Layers:
pp.base <- mask(pp.usa , scpdsi.yr.normals)
tmean.base <- mask(tmean.usa , scpdsi.yr.normals)
tmin.base <- mask(tmin.usa , scpdsi.yr.normals)
tmax.base <- mask(tmax.usa , scpdsi.yr.normals)

# Extract mean baseline conditions by ecoregion.
setwd('/Users/starrlab/git/ReferenceConditions/GIS')
## Import shapefiles:
library(rgdal)

er.c <- readOGR('/Users/starrlab/git/ReferenceConditions/GIS', "S_USA.ClimateSections")
er <- readOGR('/Users/starrlab/git/ReferenceConditions/GIS', "S_USA.EcoMapProvinces")

par(mfrow=c(1,1))

er.df <- as.data.frame(er)
er.n <- er[, c(4:8)]

pp.base.avg<- calc(pp.base, fun=mean,na.rm=T)

er.n$ppt.avg <- extract(pp.base.avg, er.n)
