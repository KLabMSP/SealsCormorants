#' Calculating seal or cormorant predation index
#'
#' This function extracts seal or cormorant predation index based on year and location. Count data has to contain the columns lat, long, year and count. The dataset for which to extract values has to contain the columns lat, long and year. Species has to be 'cormorant' or 'grey_seal'.
#' @export
#' @examples
#' dataframe.extract = data.frame(year = 2023, long = 16.68711, lat = 57.50516)
#' dataframe.counts = load_cormorant_census_counts()
#' dataframe.counts = subset(df_data, year == 2023)
#' species = "cormorant"
#' predation = predation_index(dataframe.counts, dataframe.extract, species)


predation_index <- function(dataframe.counts, dataframe.extract, species){


  # check format of data frames
  if(sum(names(dataframe.counts) %in% c("long", "lat", "year", "count")) != 4) return(print("Count data has to contain the columns lat, long, year and count. Try again!"))
  if(sum(names(dataframe.extract) %in% c("long", "lat", "year")) != 3) return(print("The dataset for which to extract values has to contain the columns lat, long and year. Try again!"))

  # smooth paras
  if(species == "cormorant") max_dist = 30000
  if(species == "grey_seal") max_dist = 60000
  if(!(species %in% c("cormorant", "grey_seal"))) return(print("Species has to be 'cormorant' or 'grey_seal'. Try again!"))


  sigma = max_dist/		2.576 # 99% of data contained within

  land = terra::rast("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/GIS-filer/baltic_sea_bathymetry_database/BSBD_0.9.6_250m/BSBD_0.9.6_250m.tif")
  land = terra::crop(land, terra::ext(4.25e+06, 5.45e+06, 3.3e+06, 5e+06))
  land = as.numeric(land < 0)
  terra::values(land)[terra::values(land) == 0] = NA

  # years
  years = sort(unique(dataframe.extract$year))
  if(!(years %in% dataframe.counts$year)) return(print("You do not have count data for these years. Try again!"))

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
      if(species == "cormorant") dists = terra::distance(land, terra::vect(locs)[l,], rasterize = TRUE) # calculate distances from colony (assume can fly over land)
      if(species == "grey_seal"){ # calculate distances from haul-out site (only travel by water)

        # move to closest location in water
        loc = locs[l,]
        cell = terra::extract(land, loc, search_radius = 10000)[2,3]

        # calculate distance excluding land
        terra::values(land)[cell] = 2
        dists = terra::costDist(land, target = 2)
        terra::values(land)[cell] = 1

      }

      # density as a function of distance
      pred.index = dists
      terra::values(pred.index) = (dnorm(terra::values(dists), 0, sigma)/dnorm(0, 0, sigma)) # function of distance
      pred.index[pred.index > max_dist] = 0 # always zero beyond max distance



      # set land to NA
      terra::values(pred.index)[is.na(terra::values(land))] = NA

      # scaling factor by colony/haul-out count so that numbers add up
      count.scaling = as.numeric(counts.y$count[l])/sum(terra::values(pred.index), na.rm = T)
      pred.index = (pred.index*count.scaling) # apply scaling


      # recalculate to per m2
      pred.index = pred.index/(250*250)


      # add values to total map
      tot = tot + pred.index

      # show progress
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

  # set land to NA
  terra::values(tot)[is.na( terra::values(land))] = NA


  return(extract.res)

}
