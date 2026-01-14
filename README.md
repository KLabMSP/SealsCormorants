# SealsCormorants

The goal of SealsCormorants is to collate data and functions related to seal and cormorant count data used within the unit.

## Installation

You can install the development version of SealsCormorants from [GitHub](https://github.com/) with:

``` r
library(devtools)
install_github("KLabMSP/SealsCormorants", force = TRUE)
library(SealsCormorants)
library(dplyr)
```

## Load seal count data
These data were downloaded from Sharkweb and include data up until 2023. When new data are added, this file should be updated (potentially using https://cran.r-project.org/web/packages/SHARK4R/index.html).

This report provides a good description of how the data are collected: <https://septentrio.uit.no/index.php/NAMMCOSP/article/view/8086>

Some cleaning of the data is also done within this function - this can be seen in the corresponding script for this function.

Note that the data that are loaded here include all data, generally with multiple counts per location. Note that when the data are based on aerial surveys, zeroes are generally not provided, why maximum counts per location are generally used. This works fine overall, if it is the distribution or trend that is of interest, but if absolute numbers are needed, this becomes more problematic. So, if absolute numbers are needed it may be worth contacting NRM to get the numbers they use.

``` r
seals = load_grey_seal_counts()
```

## Load cormorant count data

The first function loads data from the census counts carried out in 2006, 2012 and 2023.

One important thing to note is that this can include some counts from lakes, but these are not consistently included and should perhaps be filtered out, even though these cormorants may forage at the coast. Also, in 2006, "landskap"" rather than county is provided.

See <https://pub.epsilon.slu.se/33190/1/lundstrom-k-20240321b.pdf> for details.

``` r
cormorant_data = load_cormorant_census_counts()
```

The second function loads data from counts carried out at the county level. So far, possible values for "counties" include: "Stockholm" "Blekinge" "Gävleborg" "Kalmar" "Östergötland" "Södermanland" "Uppsala".

Monitoring effort varies between counties. The number of pairs in a colony is set to NA if no monitoring was carried out, and zero if monitoring has been carried out (sometimes the latter is inferred, e.g. from knowing that a census was carried out in this year). It is possible to interpolate between counts, but it is important to remember that the number of pairs in a colony can vary drastically between years. Note also that methods may vary slightly between counties and years. The source of the data are noted.

Work is ongoing to fill in some of the gaps in the data.

``` r
cormorant_data_Stockholm = load_cormorant_county_counts(counties = c("Stockholm"))
```

## Grey seal density maps

These maps have been produced by Floris van Beest.

Briefly, they combine count data from all countries with telemetry data to produce maps of predicted densities. A more detailed method description can be found on the research server: "seals-cormorants/grey-seal-maps-Floris/Methods"

Material shouldn't be used/spread without contacting Floris.

The first function simply plots the maps:

``` r
plot_seal_density_maps()
```

The second function extracts data from the maps based on year, lat and long:

``` r
dataframe.extract = data.frame(lat = 58.840285981212844, long =  17.62186805181973, year = 2020)
seal_density_asko = extract_seal_density(dataframe.extract)
```

The output is a data frame with the input data, mean predicted densities from the map, upper and lower 95% predicted densities from the map, as well as the distance from the provided coordinates to closest cell in the map which contained data, from which the data were extracted.

## Calculated predation index

This function calculates a predation index, either from grey seals or great cormorants, based on a dataframe with the year(s) and location(s) (lat, long) for which the index is to be calculated, the species ("grey_seal" or "cormorant") as well as a data frame with count data of seals or cormorants. These count data could either be extracted using the functions within the package, or provided by the user. The count data should have the columns lat, long, year and count.

The function assumes that the seals and the cormorants spread out evenly in all directions around their colony. It is assumed that the maximum distance travelled is 30 km for cormorants (Fijn et al. 2021; Grémillet et al. 1997), and 60 km for grey seals (Oksanen et al. 2014; Sjöberg et al. 2000). Within this maximum distance, the density follows a normal distribution. This distributional field is then multiplied by the number of pairs in the colony, or seals counted at the haul-out site, and adjusted according to the area of land available within 30/60 km. The output can be interpreted as number of cormorant pairs/number of seals per m2, but considering the simplifying assumptions, it is better to think of it as a predation index. This is repeated for all the colonies/haul-out sites, and values are then added together to produce a map of densities, from which the values are extracted for the provided locations.

It is important to note that the function assumes that the count data are complete in relation to the provided coordinates and years. If data are missing then the function will assume that no seals or cormorants were present, and the predation index will be underestimated. So, data need to be available for within 30 and 60 km of the provided coordinates for cormorants and grey seals, respectively, for the relevant years.

Fijn, R. C., De Jong, J. W., Adema, J., Van Horssen, P. W., Poot, M. J., Van Rijn, S., ... & Boudewijn, T. J. (2022). GPS-tracking of Great Cormorants Phalacrocorax carbo sinensis reveals sex-specific differences in foraging behaviour. Ardea, 109(3), 491-505.

Grémillet, D. (1997). Catch per unit effort, foraging efficiency, and parental investment in breeding great cormorants (Phalacrocorax carbo carbo). ICES Journal of Marine Science, 54(4), 635-644.

Oksanen, S. M., Ahola, M. P., Lehtonen, E. & Kunnasranta, M. Using
movement data of Baltic grey seals to examine foraging-site fidelity:
implications for seal-fishery conflictmitigation. Mar. Ecol. Prog. Ser.
507, 297–308 (2014).

Sjöberg,M. & Ball, J. P. Grey seal, Halichoerus grypus, habitat
selection around haulout sites in the Baltic Sea: bathymetry or
central-place foraging? Can. J. Zool. 78, 1661–1667 (2000).

#### Important caveats:

-   The count data will generally be colony counts and haul-out counts from the seal moult counts. These may not necessarily be representative of the distribution of actively foraging seals and cormorants throughout the year.
-   Assumptions regarding movement are highly simplified - in reality both seals and cormorants are likely to target specific areas rather than spread evenly in all directions.

``` r
## cormorants

dataframe.extract = data.frame(lat = 58.840285981212844, long =  17.62186805181973, year = 2020) # Askö
dataframe.counts = load_cormorant_county_counts(counties = c("Stockholm")) %>% rename(count = value)
species = "cormorant"

pred.index.asko.cormorant = predation_index(dataframe.counts, dataframe.extract, species)


## seals

dataframe.counts = subset(seals, year == 2020) %>%
  group_by(year, station) %>% # this is because several counts are carried out by haul-out site per year
  reframe(long = mean(long),
          lat = mean(lat),
          count = max(count))
species = "grey_seal"

pred.index.asko.seal = predation_index(dataframe.counts, dataframe.extract, species)



```

## Comparison between grey seal density maps and calculated predation index

``` r

## calculate predation index

dataframe.extract = data.frame(loc = c("Asköfjärden" ,      "Forsmark"     ,   "Galtfjärden"   ,    "Gaviksfjärden"    , "Holmön"   , "Torhamn" , "Kinnbäcksfjärden" ,     "Kvädöfjärden"    , "Lagnö"        ,            "Långvindsfjärden"  ,    "Norrbyn"   ,            "Råneå" ),
                                 lat = c(58.83848,  60.43521, 60.15875, 62.87285, 63.67662, 56.08515, 65.04903,  58.01046, 59.56530,  61.45513, 63.53121, 65.83789),
                               long =  c(17.63617,  18.15241, 18.61587, 18.23981, 20.85831, 15.78161, 21.53025, 16.73979, 18.84103,  17.16184, 19.81318, 22.42413))
                               
dataframe.extract = expand.grid(dataframe.extract, year = 2003:2020)                               

dataframe.counts = subset(seals, year %in% 2003:2020) %>%
  group_by(year, station) %>%
  reframe(long = mean(long),
          lat = mean(lat),
          count = max(count))
species = "grey_seal"

predation.index = predation_index(dataframe.counts, dataframe.extract, species)

## extract densities from map

seal.density.map = extract_seal_density(dataframe.extract)




```






