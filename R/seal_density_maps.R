#' Extracting data from the seal density maps
#'
#' This function extracts seal density from maps based on year and location.
#' @export
#' @examples
#' df = data.frame(year = 2003:2020, long = 19.6, lat = 60.5)
#' seal_density = extract_seal_density(df)


extract_seal_density <- function(dataframe){

  res = data.frame()

  # loop through years
  for(y in dataframe$year){

    map = terra::rast(paste0("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seals-cormorants/grey-seal-maps-Floris/densityLayersNormalized/Predictions_" , y, "_normalized.tif"))

    df.sub = subset(df, year == y)

    locs = sf::st_as_sf(df.sub, coords = c("long", "lat"), crs = 4326)
    locs = sf::st_coordinates(sf::st_transform(locs, crs(map)))

    res = rbind(
      res,
      cbind(df.sub, terra::extract(map, locs))
    )
  }


}
