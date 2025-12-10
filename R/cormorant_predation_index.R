#' Calculating cormorant predation index
#'
#' This function calculates cormorant predation index based on year and location.
#' @export
#' @examples
#' df = data.frame(year = 2023, long = 18, lat = 60.5)
#' cormorant_predation = cormorant_predation_index(df)


cormorant_predation_index <- function(dataframe){

  # years
  years = dataframe$year

  # load data
  corm.counts = read.csv("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seals-cormorants/grey-seal-counts/grey_seal_count.csv", fileEncoding = "ISO-8859-1")


  # subset count data to area to reduce time it takes



  # interpolation step if needed
  if( unique(years) %in% c(2006, 2012, 2023) ){

  }

  # subset to relevant years
  corm.counts = subset(corm.counts, year %in% years)




}
