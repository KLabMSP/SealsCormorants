#' Calculating seal or cormorant predation index
#'
#' This function extracts seal or cormorant predation index based on year and location.
#' @export
#' @examples
#' df_locs = data.frame(year = 2023, long = 18, lat = 60.5)
#' df_data =
#' predation = predation_index(df)


predation_index <- function(dataframe, species){


  # load data

  if(species == "grey_seal"){
    counts = read.csv("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seals-cormorants/grey-seal-counts/grey_seal_count.csv", fileEncoding = "ISO-8859-1")
  }


  # subset count data to area to reduce time it takes
  if(species == "grey_seal") max_distance = 60

  counts = subset



  # years
  years = dataframe$year


  # interpolation step if needed
  if( unique(years) %in% c(2006, 2012, 2023) ){

  }

  # subset to relevant years
  corm.counts = subset(corm.counts, year %in% years)




}
