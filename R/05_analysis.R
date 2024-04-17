
# SITE MAP
#Rice maps
require(maps)
require(mapdata)
require(maptools)
require(scales)
require(ggplot2)
require(ggmap)
require(ggrepel)

##### CUSTOM PLOT THEME
try_theme <- function() {
  theme(
    # add border 1)
    panel.border = element_rect(colour = "black", fill = NA, size = 0.5),
    # color background 2)
    #panel.background = element_rect(fill = "white"),
    # modify grid 3)
    panel.grid.major.x = element_line(colour = "#333333", linetype = 3, size = 0.5),
    panel.grid.minor.x = element_line(colour = "darkgrey", linetype = 3, size = 0.5),
    panel.grid.major.y = element_line(colour = "#333333", linetype = 3, size = 0.5),
    panel.grid.minor.y = element_line(colour = "darkgrey", linetype = 3, size = 0.5),
    # modify text, axis and colour 4) and 5)
    axis.text = element_text(colour = "black", family = "Times New Roman"),
    axis.title = element_text(colour = "black", family = "Times New Roman"),
    axis.ticks = element_line(colour = "black"),
    axis.ticks.length=unit(-0.1, "cm"),
    # legend at the bottom 6)
    legend.position = "bottom",
    strip.text.x = element_text(size=10, color="black",  family = "Times New Roman"),
    strip.text.y = element_text(size=10, color="black",  family = "Times New Roman"),
    strip.background = element_blank()
  )
}

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
  coord_fixed(xlim = c(-160, -50),  ylim = c(10, 65), ratio = 1.2)+
  #scale_fill_manual(values=cbPalette)+
  theme_bw()+
  theme(legend.position="none")+
  geom_point(data = df, aes(x = X, y = Y, fill = domainID),  color = "black", pch = 21, size = 3)+
  geom_label_repel(data = df, aes(label = paste(" ", as.character(siteID), sep = ""), x = X, y = Y), angle = 0, hjust = 0, box.padding = 0.5, max.overlaps = Inf)+
  xlab("Longitude")+
  ylab("Latitude")



x11(width = 10, height = 8)
p.map

ggsave("./summary/site_map.png", p.map, width = 8, height = 6, units = "in", dpi = 600, bg = "transparent")




df <- read.csv("./summary/NEONForestAGB_20240405.csv")


# For Table 1 - Look at diameter and measurement class post hoc
table(df$measurementHeight)

df %>%
  mutate(msmtClass = case_when(measurementHeight < 10 ~ "ZeroToTen",
                               measurementHeight == 10 ~ "Ten",
                               measurementHeight > 10 & measurementHeight <= 50 ~ "TenToFifty",
                               measurementHeight > 50 & measurementHeight < 130 ~ "FiftyToOneThirty",
                               measurementHeight == 130 ~ "OneThrity",
                               measurementHeight > 130 ~ "MoreThanOneThirty",
                               df$basalStemDiameter > 0 ~ "HasBSD" )) %>%
  data.frame() -> df

df %>%
  mutate(diaClass = case_when(stemDiameter >= 12.7 ~ "TREE",
                               stemDiameter >= 2.54 & stemDiameter < 12.7 ~ "SMALLTREE",
                                stemDiameter < 2.54 ~ "smaller tree",
                               basalStemDiameter > 0 ~ "SAPLING")) %>%
  data.frame() -> df

df %>%
  mutate(diaClass = case_when(stemDiameter >= 10 ~ "TREE",
                              stemDiameter >= 1 & stemDiameter < 10 ~ "SMALLTREE",
                              stemDiameter < 1 ~ "SAPLING1",
                              basalStemDiameter > 0 ~ "SAPLING2")) %>%
  data.frame() -> df

#  can use case_when to specify conditions. Condition 3 and 4 can be combined using coalesce.



require(ggplot2)

table(df$diaClass,df$msmtClass, useNA = "always")

library(tidyr)
d <- table(df$msmtClass, useNA = "always")
e <- table(df$diaClass, useNA = "always")

d <- data.frame(d)
x11()
ggplot(d, aes(x = msmtClass)) +
  geom_bar(stat = "identity") +
  facet_wrap(~Task) +
  geom_text(aes(label = paste0(Percentage, "%"), y = Percentage),
            vjust = 1.4, size = 5, color = "white")


# Uniform color
x11(width = 4, height = 4)
barplot(rev(d), 
        col="#1b9e77",
        horiz=F, las=1
)

#### POSSIBLE GRAPHICS
# Barplot
ggplot(d, aes(x = Var1, y = Freq)) + 
  geom_col()+
  scale_x_discrete(limits = rev(levels(Var1)))

e <- data.frame(d)
# Plotting TreeMap Graph 

require(treemapify)
x11()
ggplot2::ggplot(e, aes(area = Freq, fill = Var1))+ 
  treemapify::geom_treemap(layout="squarified")+ 
  #geom_treemap_text(place = "centre",size = 12)+ 
  labs(title="Customized Tree Plot using ggplot and treemapify in R")+
  scale_fill_brewer(palette = "Dark2")



###
df %>% 
  filter(!is.na(basalStemDiameter) & !is.na(stemDiameter)) %>%
  data.frame() -> z

length(unique(z$individualID))






#### TABLE2 
#### 
#### 
table(df$growthForm)
# remove those data with no AGB estimates for either 
df <- neon.bio[!is.na(neon.bio$AGBJenkins) | !is.na(neon.bio$AGBChojnacky), ]


x %>%
  filter(!is.na(AGBJenkins)) %>%
  data.frame() -> df.jenk
  table(df.jenk$growthForm)

x %>%
    filter(!is.na(AGBChojnacky)) %>%
    data.frame() -> df.choj
table(df.choj$growthForm)
 
x %>%
  filter(!is.na(AGBAnnighofer)) %>%
  data.frame() -> df.ann
table(df.ann$growthForm) 
  
x %>%
  select(individualID, growthForm) %>%
  distinct(individualID, growthForm) %>%
  data.frame() -> df.ind

dim(df.ind)
table(df.ind$growthForm)



length(unique(df$plotID))
length(unique(df$individualID))
### SUMMARY STATS
table(neon.bio$growthForm)
# look at ones with measurements
x %>%
  select(taxonID, individualID, plotID, siteID, growthForm, stemDiameter) %>%
  na.omit() %>%
  data.frame() -> df.all.stem.msmts
table(df.all.stem.msmts$growthForm)
dim(df.all.stem.msmts)
# how many saplings
x %>%
  select(taxonID, individualID, plotID, siteID, growthForm, basalStemDiameter) %>%
  na.omit() %>%
  data.frame() -> df.all.basal
table(df.all.basal$growthForm)

# look at ones that have both basal stem and stem diameters so are getting double counted
x %>%
  select(taxonID, individualID, plotID, siteID, growthForm, basalStemDiameter, stemDiameter) %>%
  na.omit() %>%
  data.frame() -> df.all.basal.stem
table(df.all.basal.stem$growthForm)

### this means total saplings are 63814 - 42


neon.bio %>%
  select(taxonID, individualID, plotID, siteID, growthForm, stemDiameter) %>%
  na.omit() %>%
  data.frame() -> df.all.stem.msmts
table(df.all.stem.msmts$growthForm)

# look at jenkins
neon.bio %>%
  select(taxonID, individualID, plotID, siteID, growthForm, AGBJenkins) %>%
  na.omit() %>%
  data.frame() -> df.all.jenk


table(df.all.jenk$growthForm)

neon.bio %>%
  select(taxonID, individualID, plotID, siteID, growthForm, AGBJenkins, AGBChojnacky) %>%
  na.omit() %>%
  data.frame() -> df.all.jenk.choj

table(df.all.jenk.choj$growthForm)

neon.bio %>%
  select(taxonID, individualID, plotID, siteID, growthForm, AGBChojnacky) %>%
  na.omit() %>%
  data.frame() -> df.all.choj

table(df.all.choj$growthForm)

distinct() %>%
  data.frame() -> unique.df

neon.bio %>%
  filter(!is.na(stemDiameter)) %>%
  data.frame() -> df.dbh

table(neon.bio$growthForm)
table(df.dbh$growthForm)

# look at unique individuals
neon.bio %>%
  distinct(individualID, growthForm) %>%
  data.frame() -> df.unique

table(df.unique$growthForm)
dim(df.unique)

# unique indiv w/ at least one msmt
df.dbh %>%
  distinct(individualID, growthForm) %>%
  data.frame() -> df.dbh.unique

dim(df.dbh.unique)
table(df.dbh.unique$growthForm)
# tabulate no of individuals with agbjenkins
neon.bio %>%
  filter(!is.na(AGBJenkins)) %>%
  data.frame() -> df.jenkins

table(df.jenkins$growthForm)

neon.bio %>%
  filter(!is.na(AGBChojnacky)) %>%
  data.frame() -> df.choj

table(df.choj$growthForm)






###### LM ANALYSIS
#### look at comps
df.both <- x[!is.na(x$AGBJenkins) & !is.na(x$AGBChojnacky), ]

summary(lm(AGBJenkins ~ AGBChojnacky, data = df.both))
sqrt(mean((df.both$AGBJenkins - df.both$AGBChojnacky)^2, na.rm = TRUE ))
library(Metrics)
rmse(df.both$AGBJenkins, df.both$AGBChojnacky)

#### BIOMASS COMP
x11()
ggplot(df.both, aes(x = AGBJenkins, y = AGBChojnacky))+
  geom_hex(bins = 25) +
  scale_fill_continuous(type = "viridis") +  
  try_theme()+
  xlab("AGB Jenkins [kg per Individual]")+
  ylab("AGB Chojnacky [kg per Individual")+
  xlim(c(0, 1000))+
  ylim(c(0, 1000))

x11(height = 4, width = 4)
ggplot(neon.bio, aes(x = AGBJenkins, y = AGBChojnacky))+
  geom_point()+
  try_theme()+
  xlab("AGB Jenkins [kg per Individual]")+
  ylab("AGB Chojnacky [kg per Individual]")+
  geom_abline(slope = 1, color = "red", width = 1.5)+
  xlim(c(0, 2000))+
  ylim(c(0, 2000))


# find bias by species
df.both$agbdiff <- df.both$AGBJenkins - df.both$AGBChojnacky
df.both %>%
  group_by(Genus) %>%
  count() %>%
  data.frame() -> genus.count

# remove those with too few
genus.count %>% 
  filter(n > 3) %>%
  data.frame() -> genus.count
df.both %>%
  filter(Genus != "Celtis" & Genus != "Juglans") %>%
  data.frame() -> df.genus

require(forestmangr)
# Fit SH model by group:
lm.output <- lm_table(df.genus, AGBChojnacky ~ AGBJenkins, "Genus")

lm.table <- merge(genus.count, lm.output)

write.csv(lm.table, "./summary/lm_results_allometry.csv")

write.csv(df, "./summary/NEONBiomass20240305.csv", row.names = FALSE)
write.csv(neon.bio, "./summary/NEONBiomassAllIndividualsv1.csv", row.names = FALSE)





