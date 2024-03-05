# SITE MAP
# This script constructs the site map showing the NEON sites that were used to derive AGB
# estimates. It includes 40 sites from the NEON data set, all sites with at least 1 measured 
# tree.
# 
# Contact Jeff Atkins @ jeffrey.atkins@usda.gov or jwatkins6@vcu.edu

# dependencies
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

# bring in necessary map data
usa <- map_data("usa")
canada <- map_data("worldHires", "Canada")
mexico <- map_data("worldHires", "Mexico")
w2hr <- map_data("worldHires")

# Eastern US Map only   
eastern.map <-  ggplot() + geom_polygon(data = usa, 
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

# Entire area
p.map <-  ggplot() + geom_polygon(data = w2hr, 
                                  aes(x=long, y = lat, group = group), 
                                  fill = "white", 
                                  color="black")+
  coord_fixed(xlim = c(-150, -65),  ylim = c(10, 75), ratio = 1.2)+
  #scale_fill_manual(values=cbPalette)+
  theme_bw()+
  theme(legend.position="none")+
  geom_point(data = df, aes(x = X, y = Y, fill = domainID),  color = "black", pch = 21, size = 3)+
  geom_label_repel(data = df, aes(label = paste(" ", as.character(siteID), sep = ""), x = X, y = Y), 
                   angle = 0, hjust = 0, box.padding = 0.5, max.overlaps = 15, max.time = 5)+
  xlab("Longitude")+
  ylab("Latitude")



x11()
p.map

# write file to disk
ggsave("./summary/site_map.png", p.map, width = 8, height = 6, units = "in", dpi = 600, bg = "transparent")
