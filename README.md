# NEONForestAGB

The NEONForesAGB data product includes aboveground biomass (AGB) estimates from individual tree diameters scaled to whole tree biomass using generalized allometric equations for 35 National Ecological Observatory Network (NEON) sites within the United States and Puerto Rico. The data set includes 93,971 unique individuals of 478 different species in 1,216 terrestrial observation plots for 245,245 biomass estimates between the years 2014 to 2023.

![](https://private-user-images.githubusercontent.com/8354517/323279438-ef90d73c-1a57-4a02-b0f1-d3eb8f5d8881.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTMzNjcyMzIsIm5iZiI6MTcxMzM2NjkzMiwicGF0aCI6Ii84MzU0NTE3LzMyMzI3OTQzOC1lZjkwZDczYy0xYTU3LTRhMDItYjBmMS1kM2ViOGY1ZDg4ODEucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI0MDQxNyUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNDA0MTdUMTUxNTMyWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9ZmNkYTkwZTkxNjU1YzdkOTBkOGEzMjZiZWI3MTk5ZjE4NWRmZDIxYjJiNWY1NzY3NjVmMGU2YTZhNDZlMGUxMyZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.xQm2pCDdmt9tguwXtkZwNkuMWxxNRtTJ8Sw7TpVuIwY)

## Getting the data

To bring the data directly into the R workspace, first download or copy the file `./R/NEONForestAGB.R` from this repo.

Direct URL: <https://github.com/atkinsjeff/NEONForestAGB/blob/main/R/NEONForestAGB.R>

Then the following code will directly import the NEONForestAGB data into the workspace:

```         
# Change this to wherever you download the file
source("./R/NEONForestAGB.R")

# import the data
df <- getAGB()
```

Metadata can be viewed and downloaded via `getAGBMeta()` and the source taxonomy and allometry data can be viewed and downloaded bia `getAGBTaxons()`.

Alternativly, one can copy the function contents of the `NEONForestAGB.R` file or access the data directly via the [figshare repository](https://figshare.com/articles/dataset/NEONForestAGBv2/25625352).

## Methodology

This code uses the Jenkins et al. 2003 and Chojnacky et al. 2014 allometric equations fit to NEON taxon ID information for 40 NEON terrestrial sites to generate estimate of total AGB for individuals.

The Jenkins allometric equations classify trees into several groups (e.g., mixed hardwood, pine, woodland) with a specific equation of the form:

$$\LARGE e^{\beta_{1} + \beta_{2} \ln dbh}$$

Where ${\beta_{1}}$ and ${\beta_{2}}$ are the group specific coefficients and $dbh$ is the diameter-at-breast height in cm.

Individual trees in the NEON data set are assigned a `taxonID` which was used to match with the assigned groups from Jenkins et al. 2003 and Chojnacky et al. (2014).\
However, where there was no initially obvious classification group that could be assigned, the USDA PLANTS database and other sources were consulted and a best guess was made. Please feel free to offer suggestions for improvements.

Taxon classification information is found in the `./data/MasterTaxonList.csv` file.

## Data workflow

Source data files used in the creation of this data product are included in the `./R/` directory. Of particular interest
would be the `./R/001_allometry_script_20240320.R` file which demonstrates how the data are imported using the `neonstore` package
and then merged with allometric and taxonomy source data we compiled to determine biomass. With proper citation, this file may be 
adapted and used for your own purposes.

![](https://private-user-images.githubusercontent.com/8354517/323278019-152d7212-b282-48de-815e-6d18a8aef6fe.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTMzNjcwODMsIm5iZiI6MTcxMzM2Njc4MywicGF0aCI6Ii84MzU0NTE3LzMyMzI3ODAxOS0xNTJkNzIxMi1iMjgyLTQ4ZGUtODE1ZS02ZDE4YThhZWY2ZmUucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI0MDQxNyUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNDA0MTdUMTUxMzAzWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9YzhiODY0OTBkNGJlMmRhMDUwYmM2ODE0OWZjNTU1ZGFmYzZhNWQwNTdjNmFiZmRlYjQ0OGU0MDc3M2M0YTEyNiZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.BoH4UZedTv67uQ94wPiAG9eZ4-vC2Y7GhPAf2zUZvkk)

## References:

Atkins, J. W., Fahey, R. T., Hardiman, B. S., & Gough, C. M. (2018). Forest canopy structural complexity and light absorption relationships at the subcontinental scale. Journal of Geophysical Research: Biogeosciences, 123(4), 1387-1405.

Gough, C. M., Atkins, J. W., Fahey, R. T., & Hardiman, B. S. (2019). High rates of primary production in structurally complex forests.

Jenkins, J. C., Chojnacky, D. C., Heath, L. S., & Birdsey, R. A. (2003). National-scale biomass estimators for United States tree species. Forest science, 49(1), 12-35.

Chojnacky ..... (2014)
