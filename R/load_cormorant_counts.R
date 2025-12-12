#' Loading cormorant count data from censuses
#'
#' This function loads cormorant colony counts from censuses carried out in 2006, 2012 and 2023
#' @export
#' @examples
#' cormorant_data = load_cormorant_census_counts()



load_cormorant_census_counts <- function(){

  # load data
  cormorant.census = read.csv("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seals-cormorants/cormorant-counts/cormorant-census-data.csv", fileEncoding = "ISO-8859-1") # load data

  return(cormorant.census)

}


#' Loading cormorant count data from counts carried out in counties
#'
#' This function loads cormorant colony counts from individual counties
#' @export
#' @examples
#' cormorant_data = load_cormorant_county_counts(counties = c("Stockholm"))


load_cormorant_county_counts <- function(counties){

  cormorant.county.data = read.csv("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seals-cormorants/cormorant-counts/cormorant-county-data.csv", fileEncoding = "ISO-8859-1") # load data

  cormorant.county.data = subset(cormorant.county.data, county %in% counties)

  return(cormorant.county.data)

}
