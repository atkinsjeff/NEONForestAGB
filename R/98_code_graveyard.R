# coding graveyard
# 
# 
# 
#####################################################
### QA FOR NUMBERS
df %>%
  filter(!is.na(stemDiameter) | !is.na(basalStemDiameter)) %>%
  data.frame() -> g

table(g$growthForm)

df %>%
  filter(!is.na(AGBAnnighofer)) %>%
  data.frame() -> f

table(f$growthForm)
dim(f)

df %>%
  filter(!is.na(stemDiameter) | !is.na(basalStemDiameter)) %>%
  select(individualID, growthForm) %>%
  data.frame() -> j

table(h$growthForm)
dim(h)

table(j$growthForm)
dim(j)


df %>%
  filter(!is.na(stemDiameter) | !is.na(basalStemDiameter)) %>%
  select(individualID, growthForm) %>%
  filter(duplicated(.)) %>%
  distinct() %>%
  data.frame() -> j


# look at how many biomass estimates there were
df %>%
  filter(!is.na(AGBJenkins) & is.na(AGBAnnighofer)) %>%
  data.frame() -> k
dim(k)
df %>%
  filter(is.na(AGBJenkins) & !is.na(AGBAnnighofer)) %>%
  data.frame() -> l
dim(l)



##### SET FINAL QUALTI














# look at no of plots and individuals
length(unique(neon.bio$plotID))
length(unique(neon.bio$individualID))


length(unique(df$plotID))
length(unique(df$individualID))
### SUMMARY STATS
table(neon.bio$growthForm)
# look at ones with measurements
neon.bio %>%
  select(taxonID, individualID, plotID, siteID, growthForm, stemDiameter) %>%
  na.omit() %>%
  data.frame() -> df.all.stem.msmts

# how many saplings
neon.bio %>%
  select(taxonID, individualID, plotID, siteID, growthForm, basalStemDiameter) %>%
  na.omit() %>%
  data.frame() -> df.all.basal
table(df.all.basal$growthForm)

# look at ones that have both basal stem and stem diameters so are getting double counted
neon.bio %>%
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




######## SCALING
# plot biomass based on jenkins
neon.bio%>%
  select(siteID, year, AGBJenkins) %>%
  group_by(siteID, year) %>%
  summarize(AGBtotal = sum(AGBJenkins, na.rm = TRUE)) %>%
  data.frame() -> bob

# now the vst_perplotperyear table
per.plot <- neon_read(table = "vst_perplotperyear", site = NA, dir = "./data/neonstore/")

per.plot$year <- as.integer(format(per.plot$date, "%Y"))


per.plot %>%
  group_by(siteID, year) %>%
  summarize(total.area = sum(totalSampledAreaTrees, na.rm = TRUE)) %>%
  data.frame() -> plot.area.by.year

carl <- merge(bob, plot.area.by.year)

carl$AGBMg_ha <- (carl$AGBtotal * 0.001) / (carl$total.area * 0.0001)

# JENKINS biomass by year
x11()
ggplot(carl[1:230,], aes(x = year, y = AGBMg_ha))+
  geom_bar(stat = "identity")+
  xlab("")+
  ylab(expression(paste("AGB (Mg ha"^"-1)")))+
  #ylab(expression(Anthropogenic~SO[4]^{"2-"}~(ngm^-3))) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))+
  facet_wrap(vars(siteID))

x11()
jenkins.bar

df %>% add_count(., siteID) %>% group_by(siteID) %>% mutate(n = ifelse(row_number(n)!=1, NA, n)) %>%
  ggplot(., mapping = aes(x = stemDiameter))+
  geom_density()+
  xlab("")+
  ylab("Total measured stems")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  facet_wrap(vars(siteID)) -> dbh.density
geom_text(aes(label = n, x = 10, y = 750), size = 3, vjust = -0.5) -> jenkins.bar

x11()
dbh.density

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
neon.bio %>%
  group_by(jenkins_model) %>%
  summarise(wBio = sum(!is.na(AGBJenkins)),
            naBio = sum(is.na(AGBJenkins)),
            wDBH = sum(!is.na(stemDiameter)),
            naDBH = sum(is.na(stemDiameter)))

neon.bio %>%
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











#### look at comps
df.both <- df.qa.qc[!is.na(df.qa.qc$AGBJenkins) & !is.na(df.qa.qc$AGBChojnacky), ]

summary(lm(AGBJenkins ~ AGBChojnacky, data = df.x))
sqrt(mean((neon.bio$AGBJenkins - neon.bio$AGBChojnacky)^2, na.rm = TRUE ))
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

summary(lm( AGBChojnacky ~ AGBJenkins, data = neon.bio))
sqrt(mean((df.both$AGBJenkins - df.both$AGBChojnacky)^2))

# find bias by species
df.both$agbdiff <- df.both$AGBJenkins - df.both$AGBChojnacky
df.both %>%
  group_by(Genus) %>%
  count() %>%
  data.frame() -> genus.count

require(forestmangr)
# Fit SH model by group:
lm.output <- lm_table(df.both, AGBChojnacky ~ AGBJenkins, "Genus")

lm.table <- merge(genus.count, lm.output)

write.csv(lm.table, "./summary/lm_results_allometry.csv")

#write.csv(df, "./summary/NEONBiomass20240305.csv", row.names = FALSE)
#write.csv(neon.bio, "./summary/NEONBiomassAllIndividualsv1.csv", row.names = FALSE)




