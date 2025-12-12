#' Calculating seal or cormorant predation index
#'
#' This function extracts seal or cormorant predation index based on year and location.
#' @export
#' @examples
#' dataframe.extract = data.frame(year = 2023, long = 16.68711, lat = 57.50516)
#' dataframe.counts = load_cormorant_census_counts()
#' dataframe.counts = subset(df_data, year == 2023)
#' species = "cormorant"
#' predation = predation_index(dataframe.counts, dataframe.extract, species)


predation_index <- function(dataframe.counts, dataframe.extract, species){

  # smooth paras
  if(species == "cormorant") max_dist = 40000
  sigma = max_dist/1.96

  land = terra::rast("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/GIS-filer/baltic_sea_bathymetry_database/BSBD_0.9.6_250m/BSBD_0.9.6_250m.tif")
  land = terra::crop(land, terra::ext(4.25e+06, 5.45e+06, 3.3e+06, 5e+06))
  land = as.numeric(land > 0)

  # years
  years = sort(unique(dataframe.extract$year))
  if(!(years %in% dataframe.counts$year)) print("You do not have count data for these years!")

  extract.res = data.frame()


  # for displaying progress
  tot.progr = nrow(subset(dataframe.counts, year %in% years))
  current.progr = 0
  seq.to.print = round(seq(1, tot.progr, length.out = 50))

  for(y in years){

    # subset to counts
    counts.y = subset(dataframe.counts, year == y)
    extract.y = subset(dataframe.extract, year == y)


    # fix coordinates to match map
    locs = sf::st_as_sf(counts.y, coords = c("long", "lat"), crs = 4326)
    locs = sf::st_transform(locs, terra::crs(land))


    # empty raster for adding new values
    tot = land; terra::values(tot) = 0

    for(l in 1:nrow(counts.y)){
      dists = terra::distance(land, terra::vect(locs)[l,], rasterize = TRUE)
      terra::values(dists) = (dnorm(terra::values(dists), 0, sigma)/dnorm(0, 0, sigma))*as.numeric(counts.y$count[l])
      dists[dists > 40000] = 0

      tot = tot + dists

      current.progr = current.progr + 1
      if(current.progr %in% seq.to.print) print(paste(round((current.progr/tot.progr)*100), "% done"))


    }


    # fix coordinates for extraction to match map
    locs = sf::st_as_sf(extract.y, coords = c("long", "lat"), crs = 4326)
    locs = sf::st_transform(locs, terra::crs(land))

    # extract values and add to dataframe
    extract.y$predation = terra::extract(tot, locs)$BSBD_0.9.6_250m
    extract.res = rbind(extract.res, extract.y)

  }

  return(extract.res)

}
