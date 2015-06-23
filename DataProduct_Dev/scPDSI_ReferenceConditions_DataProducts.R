# Author: Sparkle L. Malone
# Date: June 2015
# Objective: Aggregate scPDSI and extract reference conditions (2000-2014). 

rm(list=ls())

library(rgdal)
library(zoo)

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

rm(scpdsi.index.df)

# Create raster stack:
scpdsi<- stack(scpdsi.file.list)

rm(scpdsi.file.list)

# Add index to raster stack
scpdsi <- setZ(scpdsi,scpdsi.index, 'yearmon')
names(scpdsi) <- scpdsi.index
rm(scpdsi.index)

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

rm(rc, year.index)

# ________________________________________________________________________________#
# Mask parameters with the scPDSI normals to set thresholds for each eco-region:
library(prism)

# Import Prism Data:
options(prism.path ='/Volumes/Promise Pegasus/Data/PRISM/Precipitation/Annual') # Directory of PRISM files
pp.list <-(ls_prism_data(absPath = TRUE)) # list of Prism files
pp.usa <- stack(pp.list[1:14, 2]); rm(pp.list)

options(prism.path = '/Volumes/Promise Pegasus/Data/PRISM/Temperature_mean/Annual')
tmean.list <- ls_prism_data(absPath = TRUE) 
tmean.usa <- stack(tmean.list[1:14, 2]); rm(tmean.list)

options(prism.path = '/Volumes/Promise Pegasus/Data/PRISM/Temperature_min/Annual')
tmin.list <- ls_prism_data(absPath = TRUE) 
tmin.usa <- stack(tmin.list[1:14, 2]); rm(tmin.list)

options(prism.path = '/Volumes/Promise Pegasus/Data/PRISM/Temperature_max/Annual')
tmax.list <- ls_prism_data(absPath = TRUE) 
tmax.usa <- stack(tmax.list[1:14, 2]); rm(tmax.list)

# add an index to climate data:
yr.index2 <- seq(2000, 2013, 1)
pp.usa <-setZ(pp.usa, yr.index2); names(pp.usa) <-getZ(pp.usa)
tmean.usa <-setZ(tmean.usa, yr.index2); names(tmean.usa) <-getZ(tmean.usa)
tmin.usa <-setZ(tmin.usa, yr.index2); names(tmin.usa) <-getZ(tmin.usa)
tmax.usa <-setZ(tmax.usa, yr.index2); names(tmax.usa) <-getZ(tmax.usa)

scpdsi.yr.normals <- scpdsi.yr.normals[[1:14]] # Temporary subset scpdsi- PRISM climate data is not yet available for 2014.
scpdsi.yr.normals <-setZ(scpdsi.yr.normals, yr.index2); names(scpdsi.yr.normals) <-getZ(scpdsi.yr.normals)

# Reproject rasters:
pp.usa <- projectRaster(pp.usa, scpdsi.yr, method = 'bilinear')
tmean.usa <- projectRaster(tmean.usa, scpdsi.yr, method = 'bilinear')
tmin.usa <- projectRaster(tmin.usa, scpdsi.yr, method = 'bilinear')
tmax.usa <- projectRaster(tmax.usa, scpdsi.yr, method = 'bilinear')

# Crop all layers by RPA region 2:
setwd('~/git/Climate-Ecoregions/ShapeFiles')
region.rpa <- readOGR('.', "RPA_region2")
crs <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0' # Projection
region.rpa <- spTransform(region.rpa, crs)

scpdsi.yr.normals <- crop(scpdsi.yr.normals, region.rpa)
pp <- crop(pp.usa, region.rpa)
tmean <- crop(tmean.usa, region.rpa)
tmin <- crop(tmin.usa, region.rpa)
tmax <- crop(tmax.usa , region.rpa)

scpdsi.yr.normals <- crop(scpdsi.yr.normals, region.rpa)
pp <- mask(pp, region.rpa)
tmean <- mask(tmean, region.rpa)
tmin <- mask(tmin, region.rpa)
tmax <- mask(tmax , region.rpa)

rm( pp.usa, tmean.usa, tmin.usa, tmax.usa)

# Write Data Layers:
setwd('~/git/Data')
writeRaster(scpdsi.yr.normals, 'scPDSI_00-13', suffix=names(pp), format= "GTiff", overwrite=T)

writeRaster(pp, 'precipitation_00-13', suffix=names(pp), format="GTiff", overwrite=T)

writeRaster(tmean,'tmean_00-13', suffix=names(pp), format= "GTiff", overwrite=T)

writeRaster(tmin, 'tmin_00-13', suffix=names(pp), format= "GTiff", overwrite=T)

writeRaster(tmax,'tmax_00-13', suffix=names(pp), format= "GTiff", overwrite=T)


