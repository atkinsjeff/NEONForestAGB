# BUILD AGB PRODUCT
# This script builds the final data product using the created biomass files
# which are produced at the site level
# 
# Contact Jeff Atkins @ jeffrey.atkins@usda.gov or jwatkins6@vcu.edu

# dependencies
require(tidyverse)

# import collated product
df <- read.csv("NEONBiomass20231005.csv")

# sorted
x <- df[ ,c("domainID", 
            "siteID",
            "plotID",
            "individualID",
            "date",
            "year",
            "taxonID",
            "FIA.Code",
            "scientificName",
            "habit",
            "growthForm",
            "plantStatus",
            "canopyPosition",
            "measurementHeight",
            "stemDiameter",
            "height",
            "stemDistance",
            "stemAzimuth",
            "jenkins_model",
            "chojnacky",
            "Adj.Factor",
            "AGBJenkins",
            "AGBChojnacky")]

# write em to file
write.csv(x, "NEONBiomassDraft.csv")



# SITE MAP
#Rice maps
require(maps)
require(mapdata)
require(maptools)
require(scales)
require(ggplot2)
require(ggmap)
require(ggrepel)

# bring in site coordinates
df <- read.csv("./data/sitecoordinates.csv")

# create field for domains
df$domainID <- as.factor(substr(df$Name, 1, 3))


usa <- map_data("usa")
canada <- map_data("worldHires", "Canada")
mexico <- map_data("worldHires", "Mexico")

w2hr <- map_data("worldHires")

# p.map <- ggplot() + geom_polygon(data = states, aes(x = long, y = lat, group = group), color = "white", fill = "light grey") + 
#   coord_fixed(1.3)+
#   
p.map <-  ggplot() + geom_polygon(data = usa, 
                          aes(x=long, y = lat, group = group), 
                          fill = "white", 
                          color="black") +
  geom_polygon(data = canada, aes(x=long, y = lat, group = group), 
               fill = "white", color="black") + 
  geom_polygon(data = mexico, aes(x=long, y = lat, group = group), 
               fill = "white", color="black")+
  coord_fixed(xlim = c(-100, -65),  ylim = c(25, 50), ratio = 1.2)+
  #scale_fill_manual(values=cbPalette)+
  theme_bw()+
  theme(legend.position="none")+
  geom_point(data = df, aes(x = X, y = Y), color = "black", pch = 21, size = 3)+
  geom_text_repel(data = df, aes(label = paste(" ", as.character(siteID), sep = ""), x = X, y = Y), angle = 0, hjust = 0)+
  xlab("Longitude")+
  ylab("Latitude")

p.map <-  ggplot() + geom_polygon(data = w2hr, 
                                  aes(x=long, y = lat, group = group), 
                                  fill = "white", 
                                  color="black")+
  coord_fixed(xlim = c(-150, -65),  ylim = c(25, 75), ratio = 1.2)+
  #scale_fill_manual(values=cbPalette)+
  theme_bw()+
  theme(legend.position="none")+
  geom_point(data = df, aes(x = X, y = Y, fill = domainID),  color = "black", pch = 21, size = 3)+
  geom_label_repel(data = df, aes(label = paste(" ", as.character(siteID), sep = ""), x = X, y = Y), angle = 0, hjust = 0, box.padding = 0.5)+
  xlab("Longitude")+
  ylab("Latitude")



x11()
p.map

ggsave("./summary/site_map.png", p.map, width = 8, height = 6, units = "in", dpi = 600, bg = "transparent")
