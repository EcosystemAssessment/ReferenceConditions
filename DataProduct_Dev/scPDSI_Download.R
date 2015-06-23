# Download scPDSI:
rm(list=ls())
# Load packages 
library(RCurl)
library(raster)
library(rgdal)
library(maptools)
library(rasterVis)


# Set the directory 
di <- "/Volumes/"
setwd(di)

#### run only a time!!!!! ########
##  scPDSI Raster Data: http://www.wrcc.dri.edu/wwdt/archive.php?folder=scpdsi

#Loop to download the raster data: 
for (y in 1896:2014) { 
  # Get the url
  url.aux <- paste('http://www.wrcc.dri.edu/monitor/WWDT/data/PRISM/scpdsi/scpdsi_',y,'_', sep='')
  for (m in 1:12){
    url <- paste(url.aux,m,'_PRISM.nc', sep='') 
    filenamedest <- strsplit(url, split='http://www.wrcc.dri.edu/monitor/WWDT/data/PRISM/scpdsi/')[[1]][2]
    download.file(url, filenamedest)
  }}