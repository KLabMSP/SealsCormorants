
nearestLand <- function (points, raster, max_distance) {
  # get nearest non_na cells (within a maximum distance) to a set of points
  # points can be anything extract accepts as the y argument
  # max_distance is in the map units if raster is projected
  # or metres otherwise

  # function to find nearest of a set of neighbours or return NA
  nearest <- function (lis, raster) {
    neighbours <- matrix(lis[[1]], ncol = 2)
    point <- lis[[2]]
    # neighbours is a two column matrix giving cell numbers and values
    land <- !is.na(neighbours[, 2])
    if (!any(land)) {
      # if there is no land, give up and return NA
      return (c(NA, NA))
    } else{
      # otherwise get the land cell coordinates
      coords <- raster::xyFromCell(raster, neighbours[land, 1])

      if (nrow(coords) == 1) {
        # if there's only one, return it
        return (coords[1, ])
      }

      # otherwise calculate distances
      dists <- sqrt((coords[, 1] - point[1]) ^ 2 +
                      (coords[, 2] - point[2]) ^ 2)

      # and return the coordinates of the closest
      return (coords[which.min(dists), ])
    }
  }

  # extract cell values within max_distance of the points
  neighbour_list <- raster:extract(raster, points,
                            buffer = max_distance,
                            cellnumbers = TRUE)

  # add the original point in there too
  neighbour_list <- lapply(1:nrow(points),
                           function(i) {
                             list(neighbours = neighbour_list[[i]],
                                  point = as.numeric(points[i, ]))
                           })

  return (t(sapply(neighbour_list, nearest, raster)))
}



#' Extracting data from the seal density maps
#'
#' This function extracts seal density from maps based on year and location.
#' @export
#' @examples
#' df = data.frame(year = c(2020, 2020), long = c(17.6, 19.6), lat = c(60.5, 60.5))
#' seal_density = extract_seal_density(df)


extract_seal_density <- function(dataframe){

  res = data.frame()

  # loop through years
  for(y in unique(dataframe$year)){

    map = terra::rast(paste0("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seals-cormorants/grey-seal-maps-Floris/densityLayersNormalized/Predictions_" , y, "_normalized.tif"))

    df.sub = subset(df, year == y)

    locs = sf::st_as_sf(df.sub, coords = c("long", "lat"), crs = 4326)
    locs = sf::st_coordinates(sf::st_transform(locs, terra::crs(map)))

    locs_fixed = as.data.frame(nearestLand(points = locs, raster = raster::raster(map), max_distance = 10000))

    distances = sf::st_distance(sf::st_as_sf(as.data.frame(locs), coords = c("X", "Y"), crs = terra::crs(map)),
                            sf::st_as_sf(as.data.frame(locs_fixed), coords = c("x", "y"), crs = terra::crs(map)),
                            by_element = T)

    res = rbind(
      res,
      cbind(df.sub, terra::extract(map, locs_fixed), data.frame(distance_to_data = distances))

    )
  }

  return(res)

}


#' Plotting seal density maps
#'
#' This function plots seal density for each year
#' @export
#' @examples
#' plot_seal_density_maps()


plot_seal_density_maps <- function(){

  plot.list = list()

  for(y in 2003:2020){

    map = terra::rast(paste0("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seals-cormorants/grey-seal-maps-Floris/densityLayersNormalized/Predictions_" , y, "_normalized.tif"))

    map = terra::crop(map, terra::ext(4.6e+06, 5.4e+06, 3.4e+06, 4.8e+06))

    p = ggplot2::ggplot() +
      tidyterra::geom_spatraster(data = map$pred_mean) +
      tidyterra::scale_fill_whitebox_c(palette = "muted") +
      ggplot2::coord_sf(crs = terra::crs(map)) +
      ggplot2::labs(
        fill = "Grey seal\ndensity index",
        title = y) +
      ggplot2::theme_void()

    plot.list[[y-2002]] = p

  }


  p = ggpubr::ggarrange(plot.list[[1]],
                        plot.list[[2]],
                        plot.list[[3]],
                        plot.list[[4]],
                        plot.list[[5]],
                        plot.list[[6]],
                        plot.list[[7]],
                        plot.list[[8]],
                        plot.list[[9]],
                        plot.list[[10]],
                        plot.list[[11]],
                        plot.list[[12]],
                        plot.list[[13]],
                        plot.list[[14]],
                        plot.list[[15]],
                        plot.list[[16]],
                        plot.list[[17]],
                        plot.list[[18]],
                        common.legend = T,
                        nrow = 3, ncol = 6,
                        legend = "right"
  )
  return(p)

}
