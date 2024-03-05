# QA/QC
# This script builds the initial unformatted agb product after going through and 
# clearing out any issues
# 
# contact Jeff W. Atkins for anything:  jeffrey.atkins@usda.gov or jwatkins6@vcu.edu
 
# dependencies
library(tidyverse)
library(data.table)
library(ggplot2)

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

# lists all the biomass files
list.files(path = "./data/biomass/", pattern = "_biomass", full.names= TRUE) %>% 
  map_df(~fread(.))  -> neon.bio

# convert to data frame
neon.bio <- data.frame(neon.bio)

# remove those data with no AGB estimates for either 
df <- neon.bio[!is.na(neon.bio$AGBJenkins) | !is.na(neon.bio$AGBChojnacky), ]
# what's up with CPER and JORN
neon.bio %>%
  filter(siteID == "CPER") %>%
  data.frame() -> neon.cper

neon.bio %>%
  filter(siteID == "JORN") %>%
  data.frame() -> neon.jorn

# remove CPER
neon.bio %>%
  filter(siteID != "CPER") %>%
  # filter(siteID != "JORN") %>%
  data.frame() -> neon.bio

# look at no of plots and individuals
length(unique(neon.bio$plotID))
length(unique(neon.bio$individualID))

# tabulate no of individuals with agbjenkins
df %>%
  group_by(year, siteID)

# JENKINS bar
df %>% add_count(., siteID) %>% group_by(siteID) %>% mutate(n = ifelse(row_number(n)!=1, NA, n)) %>%
  ggplot(., mapping = aes(x = year, y = (AGBJenkins * 0.001)))+
  geom_bar(stat = "identity")+
  xlab("")+
  ylab("Total Biomass in Mg [Jenkins et al. (2003)]")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  facet_wrap(vars(siteID))+
  geom_text(aes(label = n, x = 2015, y = 750), size = 3, vjust = -0.5, parse = TRUE) -> jenkins.bar

x11()
jenkins.bar

df %>% add_count(., siteID) %>% group_by(siteID) %>% mutate(n = ifelse(row_number(n)!=1, NA, n)) %>%
  ggplot(., mapping = aes(x = year, y = (AGBChojnacky * 0.001)))+
  geom_bar(stat = "identity")+
  xlab("")+
  ylab("Total Biomass in Mg [Chojnacky et al. (2014)]")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  facet_wrap(vars(siteID))+
  geom_text(aes(label = n, x = 2015, y = 650), size = 3, vjust = -0.5, parse = TRUE) -> choj.bar

x11()
choj.bar
  
#### group by jenkins
df %>%
  group_by(jenkins_model) %>%
  summarise(wBio = sum(!is.na(AGBJenkins)),
            naBio = sum(is.na(AGBJenkins)),
            wDBH = sum(!is.na(stemDiameter)),
            naDBH = sum(is.na(stemDiameter)))

df %>%
  group_by(chojnacky) %>%
  summarise(wBio = sum(!is.na(AGBJenkins)),
            naBio = sum(is.na(AGBJenkins)),
            wDBH = sum(!is.na(stemDiameter)),
            naDBH = sum(is.na(stemDiameter)))

#### QA/QC
#### 
#### # find missing taxons
neon.bio %>%
  dplyr::filter(stemDiameter > 0 & is.na(AGBJenkins)) %>%
  dplyr::filter(str_detect(growthForm, "tree")) %>%
  select(taxonID, FIA.Code, Common.Name) %>% 
  distinct() %>%
  data.frame() -> zero.missing.allo

write.csv(zero.missing.allo, "./summary/MissingJenkins.csv", row.names = FALSE)


neon.bio %>%
  dplyr::filter(stemDiameter > 0 & is.na(AGBChojnacky)) %>%
  dplyr::filter(str_detect(growthForm, "tree")) %>%
  select(taxonID, FIA.Code, Common.Name) %>% 
  distinct() %>%
  data.frame() -> zero.missing.allo.choj

write.csv(zero.missing.allo.choj, "./summary/MissingChojnacky.csv", row.names = FALSE)

# now to merge them together
zero.missing.allo.choj %>%
  mutate(match = ifelse(taxonID %in% zero.missing.allo$taxonID, 1, 0)) %>%
  arrange(match) %>%
  mutate(issue = ifelse(match == 1, "No matching allometry", "No matching allometry from Chojnacky et al. (2014)")) %>%
  data.frame() -> missing

write.csv(missing, "./summary/missing_taxons.csv", row.names = FALSE)

### look at number of species
neon.bio %>%
  dplyr::filter(str_detect(plantStatus, "Live")) %>%
  group_by(taxonID, growthForm) %>%
  tally() %>%
  data.frame() -> species.tally

bad.table <-  distinct(neon.bio[ , c("taxonID", "FIA.Code", "Common.Name", "growthForm")] )
# make nicer
species.tally <- merge(species.tally, bad.table )

# how many with no biomass
neon.bio %>%
  dplyr::filter(str_detect(plantStatus, "Live")) %>%
  group_by(taxonID, growthForm) %>%
  tally(is.na(AGBJenkins)) %>%
  data.frame() -> jenkins.tally
names(jenkins.tally)[names(jenkins.tally) == "n"] <- "NoJenkBiomass"

# how many plots


# how many with no biomass
neon.bio %>%
  dplyr::filter(str_detect(plantStatus, "Live")) %>%
  group_by(taxonID, growthForm) %>%
  tally(is.na(AGBChojnacky)) %>%
  data.frame() -> choj.tally

names(choj.tally)[names(choj.tally) == "n"] <- "NoChojBiomass"

species.tally <- merge(species.tally, jenkins.tally, all.x = TRUE)
species.tally <- merge(species.tally, choj.tally, all.x = TRUE)

write.csv(species.tally, "./summary/BiomassSpeciesQAQC20240305.csv")

#####
neon.bio %>%
  filter(stemDiameter > 0) %>%
  data.frame() -> non.zero

neon.bio %>%
  filter(is.na(stemDiameter)) %>%
  data.frame() -> zero
  
table(non.zero$growthForm)
table(zero$growthForm)

# look at trees
zero %>%
  dplyr::filter(str_detect(growthForm, "tree")) %>%
  data.frame() -> zero.tree

table(zero.tree$plantStatus)

# now look at live zero trees
zero.tree %>%
  filter(plantStatus == "Live") %>%
  data.frame() -> zero.live.tree

# look at saplings
# look at trees
zero %>%
  dplyr::filter(str_detect(growthForm, "sapling")) %>%
  data.frame() -> zero.sap

#### high values
neon.bio %>%
  filter(AGBJenkins > 20000)


summary(lm(AGBJenkins ~ AGBChojnacky, data = neon.bio))
sqrt(mean((neon.bio$AGBJenkins - neon.bio$AGBChojnacky)^2, na.rm = TRUE ))
library(Metrics)
rmse(neon.bio$AGBJenkins, neon.bio$AGBChojnacky)

#### BIOMASS COMP
x11()
ggplot(neon.bio, aes(x = AGBJenkins, y = AGBChojnacky))+
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

summary(lm(AGBJenkins ~ AGBChojnacky, data = neon.bio))

write.csv(df, "NEONBiomass20240305.csv")
