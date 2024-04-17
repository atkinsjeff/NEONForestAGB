---
editor_options: 
  markdown: 
    wrap: 72
---

# NEONForestAGB

# Using the dataset

To bring the data directly into the R workspace, first download or copy
the file `./R/NEONForestAGB.R` from this repo.

Direct URL:
<https://github.com/atkinsjeff/NEONForestAGB/blob/main/R/NEONForestAGB.R>

Then the following code will directly import the NEONForestAGB data into
the workspace:

```         
# Change this to wherever you download the file

source("./R/NEONForestAGB.R")

# import the data
df <- getAGB()
```

Metadata can be viewed and downloaded via `getAGBMeta()` and the source
taxonomy and allometry data can be viewed and downloaded bia
`getAGBTaxons()`.

Alternativly, one can copy the function contents of the
`NEONForestAGB.R` file or access the data directly via the [figshare
repository](https://figshare.com/articles/dataset/NEONForestAGBv2/25625352).


# Methodology

This code uses the Jenkins et al. 2003 and Chojnacky et al. 2014
allometric equations fit to NEON taxon ID information for 40 NEON
terrestrial sites to generate estimate of aboveground biomass (AGB) for
individuals.

## Additional Notes

The Jenkins allometric equations classify trees into several groups
(e.g., mixed hardwood, pine, woodland) with a specific equation of the
form:

$$\LARGE e^{\beta_{1} + \beta_{2} \ln dbh}$$

Where ${\beta_{1}}$ and ${\beta_{2}}$ are the group specific
coefficients and $dbh$ is the diameter-at-breast height in cm.

Individual trees in the NEON data set are assigned a `taxonID` which was
used to match with the assigned groups from Jenkins et al. 2003 and
Chojnacky et al. (2014).\
However, where there was no initially obvious classification group that
could be assigned, the USDA PLANTS database and other sources were
consulted and a best guess was made. Please feel free to offer
suggestions for improvements.

Taxon classification information is found in the
`./data/MasterTaxonList.csv` file.

## References:

Atkins, J. W., Fahey, R. T., Hardiman, B. S., & Gough, C. M. (2018).
Forest canopy structural complexity and light absorption relationships
at the subcontinental scale. Journal of Geophysical Research:
Biogeosciences, 123(4), 1387-1405.

Gough, C. M., Atkins, J. W., Fahey, R. T., & Hardiman, B. S. (2019).
High rates of primary production in structurally complex forests.

Jenkins, J. C., Chojnacky, D. C., Heath, L. S., & Birdsey, R. A. (2003).
National-scale biomass estimators for United States tree species. Forest
science, 49(1), 12-35.

Chojnacky ..... (2014)
