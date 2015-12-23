# Sparkle L. Malone
# Create Baseline mask with scpdsi(-0.4 to 0.4) and create Normals layers:

rm(list=ls())

library(raster)
library(rgdal)
library (zoo)
library(reshape)
library("splitstackshape")

setwd('/Volumes/Promise Pegasus/Data/PRISM_scPDSI')

p02.list<- list.files(pattern="scpdsi_2002")
p03.list<- list.files(pattern="scpdsi_2003")
p04.list<- list.files(pattern="scpdsi_2004")
p05.list<- list.files(pattern="scpdsi_2005")
p06.list<- list.files(pattern="scpdsi_2006")
p07.list<- list.files(pattern="scpdsi_2007")
p08.list<- list.files(pattern="scpdsi_2008")
p09.list<- list.files(pattern="scpdsi_2009")
p10.list<- list.files(pattern="scpdsi_2010")
p11.list<- list.files(pattern="scpdsi_2011")
p12.list<- list.files(pattern="scpdsi_2012")
p13.list<- list.files(pattern="scpdsi_2013")
p14.list<- list.files(pattern="scpdsi_2014")

p.02<-stack(p02.list)
p.03<-stack(p03.list)
p.04<-stack(p04.list)
p.05<-stack(p05.list)
p.06<-stack(p06.list)
p.07<-stack(p07.list)
p.08<-stack(p08.list)
p.09<-stack(p09.list)
p.10<-stack(p10.list)
p.11<-stack(p11.list)
p.12<-stack(p12.list)
p.13<-stack(p13.list)
p.14<-stack(p14.list)

rm(p02.list, p03.list, p04.list, p05.list, p06.list, 
   p07.list, p08.list, p09.list, p10.list, p11.list, 
   p12.list, p13.list, p14.list)

ps.02 <- calc(p.02, mean)
ps.03 <- calc(p.03, mean)
ps.04 <- calc(p.04, mean)
ps.05 <- calc(p.05, mean)
ps.06 <- calc(p.06, mean)
ps.07 <- calc(p.07, mean)
ps.08 <- calc(p.08, mean)
ps.09 <- calc(p.09, mean)
ps.10 <- calc(p.10, mean)
ps.11 <- calc(p.11, mean)
ps.12 <- calc(p.12, mean)
ps.13 <- calc(p.13, mean)
ps.14 <- calc(p.14, mean)

rm(p.02, p.03, p.04, p.05, p.06, p.07, p.08, p.09, p.10, p.11, p.12, p.13, p.14)

# stack layers
scpdsi <- stack(ps.02, ps.03, ps.04, ps.05, ps.06, ps.07, ps.08, ps.09, ps.10, ps.11,ps.12,ps.13, ps.14)

names <- c('scpdsi_2002', 'scpdsi_2003', 'scpdsi_2004', 'scpdsi_2005', 'scpdsi_2006', 'scpdsi_2007', 'scpdsi_2008', 
           'scpdsi_2009', 'scpdsi_2010', 'scpdsi_2011', 'scpdsi_2012', 'scpdsi_2013', 'scpdsi_2014')
names(scpdsi) <- names

rm(ps.02, ps.03, ps.04, ps.05, ps.06, ps.07, ps.08, ps.09, ps.10, ps.11, ps.12, ps.13, ps.14)

idx <- format(as.Date(c("2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014"), "%Y"), "%Y")
scpdsi <-setZ(scpdsi, idx)
scpdsi.normals <- scpdsi
scpdsi.normals[scpdsi.normals > 0.4 | scpdsi.normals < -0.4] <- NA # mask all values outside of 0.04 to -0.04

rm(names, scpdsi)

# Masking files of Interest: 

setwd("/Volumes/Promise Pegasus/Data/MODIS_GPP/Annual")
gpp <-stack(list.files(pattern="GPP")[3:15])

setwd("/Volumes/Promise Pegasus/Data/MODIS_NPP/Annual")
npp<-stack(list.files(pattern="NPP")[3:15])

setwd("/Volumes/Promise Pegasus/Data/MOD16A3_ET")
et<-stack(list.files(pattern="ET")[3:15])

library(prism)
options(prism.path ='/Volumes/Promise Pegasus/Data/PRISM/Precipitation/Annual') # Directory of PRISM files
pp.list <-(ls_prism_data(absPath = TRUE)) # list of Prism files
pp <- stack(pp.list[3:15, 2]); rm(pp.list)

############################################################################################
# Import shapefiles:
setwd('~/git/Climate-Ecoregions/Shapefiles')

region.rpa <- readOGR('.', 'RPA_region2')
usa <- readOGR('.', 'USA_BOUNDARY')

crs <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0' # Projection
region.rpa  <- spTransform(region.rpa , crs)
usa  <- spTransform(usa , crs)

# Crop layers by USA:

scpdsi <- mask(crop(scpdsi.normals, region.rpa), region.rpa)
gpp <- mask(crop(gpp, region.rpa), region.rpa)
npp <- mask(crop(npp, region.rpa), region.rpa)
pp <-mask(crop(pp, region.rpa), region.rpa) 
et <- mask(crop(et, region.rpa), region.rpa)

# Resample layers: 
gpp <- resample(gpp, scpdsi, method="bilinear")
npp <- resample(npp, scpdsi, method="bilinear")
pp <- resample(pp, scpdsi, method="bilinear")
et <- resample(et, scpdsi, method="bilinear")

# Mask by scPDSI
gpp.normals <- stack()
npp.normals <- stack()
pp.normals <- stack()
et.normals <- stack()

for (i in 1:13) { 
  gpp[[i]] <- mask( gpp[[i]], scpdsi[[i]])
  gpp.normals <-addLayer(gpp.normals, gpp[[i]])
  print(gpp[[i]])
} # GPP
for (i in 1:13) { 
  npp[[i]] <- mask( npp[[i]], scpdsi[[i]])
  npp.normals <-addLayer(npp.normals, npp[[i]])
  print(npp[[i]])
} # NPP
for (i in 1:13) { 
  pp[[i]] <- mask( pp[[i]], scpdsi[[i]])
  pp.normals <-addLayer(pp.normals, pp[[i]])
  print(pp[[i]])
} # pp
for (i in 1:13) { 
  et[[i]] <- mask( et[[i]], scpdsi[[i]])
  et.normals <-addLayer(et.normals, et[[i]])
  print(et[[i]])
} # ET

# rename layers and add index:
names(gpp.normals) <- c('GPP_2002', 'GPP_2003', 'GPP_2004', 'GPP_2005', 'GPP_2006', 'GPP_2007', 'GPP_2008', 
             'GPP_2009', 'GPP_2010', 'GPP_2011', 'GPP_2012', 'GPP_2013', 'GPP_2014')
names(npp.normals) <- c('NPP_2002', 'NPP_2003', 'NPP_2004', 'NPP_2005', 'NPP_2006', 'NPP_2007', 'NPP_2008', 
                'NPP_2009', 'NPP_2010', 'NPP_2011', 'NPP_2012', 'NPP_2013', 'NPP_2014')
names(pp.normals) <- c('PP_2002', 'PP_2003', 'PP_2004', 'PP_2005', 'PP_2006', 'PP_2007', 'PP_2008', 
                'PP_2009', 'PP_2010', 'PP_2011', 'PP_2012', 'PP_2013', 'PP_2014')
names(et.normals) <- c('PP_2002', 'PP_2003', 'PP_2004', 'PP_2005', 'PP_2006', 'PP_2007', 'PP_2008', 
                'PP_2009', 'PP_2010', 'PP_2011', 'PP_2012', 'PP_2013', 'PP_2014')

gpp.normals <- setZ(gpp.normals, idx)
npp.normals <- setZ(npp.normals, idx)
pp.normals <- setZ(pp.normals, idx)
et.normals <- setZ(et.normals, idx)

# Writeout Normals and the masks:
setwd('~/git/Data/Normals')
writeRaster(scpdsi.normals, filename=names(scpdsi.normals), bylayer=T, format="GTiff", overwrite=T)
writeRaster(gpp.normals, filename=names(gpp.normals), bylayer=T, format="GTiff", overwrite=T)
writeRaster(npp.normals, filename=names(npp.normals), bylayer=T, format="GTiff", overwrite=T)
writeRaster(pp.normals, filename=names(pp.normals), bylayer=T, format="GTiff", overwrite=T)
writeRaster(et.normals, filename=names(et.normals), bylayer=T, format="GTiff", overwrite=T)
