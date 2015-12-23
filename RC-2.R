# Author: Sparkle L. Malone
# Date: June 2015

# Objective: Summarize climate data by ecoregion province

# Run RC-1 first to import data:

# mask climate stacks by normals:
pp.norm <- mask( pp, normals)
tmean.norm <- mask(tmean , normals)
tmin.norm <- mask(tmin , normals)
tmax.norm <- mask(tmax , normals)

# Create means for norms
pp.base <- calc( pp.norm, na.rm=T, fun=mean)
tmean.base <- calc(tmean.norm, na.rm=T, fun=mean)
tmin.base <- calc(tmin.norm, na.rm=T, fun=mean)
tmax.base <- calc(tmax.norm, na.rm=T, fun=mean)

# Extract data:
er.c$ppt.norm <- extract(pp.base, er.c, fun=mean, na.rm=T)
er.c$tmean.norm <- extract(tmean.base, er.c, fun=mean, na.rm=T)
er.c$tmin.norm <- extract(tmin.base, er.c, fun=mean, na.rm=T)
er.c$tmax.norm <- extract(tmax.base, er.c, fun=mean, na.rm=T)

# compare Baseline conditions to PRISM Normals:
er.c.df <- as.data.frame(er.c) # Convert shapefile attribute table to a dataframe.

er.c.df$PRECIP_ANN_mm <- er.c.df$PRECIP_ANN*10 # Converts cm to mm
pp.bn <- lm(er.c.df$ppt.norm ~ er.c.df$PRECIP_ANN_mm) # linear model for precip

plot(er.c.df$PRECIP_ANN_mm, er.c.df$ppt.norm) # Figure: Precip
abline(pp.bn); text(100,1000, paste('R2=',round(summary(pp.bn)$r.squared,2)))
text(100,900, paste('y =',round(summary(pp.bn)$coefficients[2],2),'+', round(summary(pp.bn)$coefficients[1],2)))


# Baseline mean plots:
library(RColorBrewer)

par(mfrow=c(1,2))
pal.pp <- colorRampPalette(c("grey", "blue", "green"))
plot(pp.base, col= pal.pp(20))
plot(er.c, add=T)

pal.pp2 <- colorRampPalette(c("grey", "blue"))

spplot(er.c, "ppt.norm", col="white", col.regions=pal.pp2(20),
       colorkey = T, bty="n", lwd=0.4,
       sp.layout=list("sp.polygons", region.rpa, first=F))


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

