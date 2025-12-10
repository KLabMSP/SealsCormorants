#' A Cat Function
#'
#' This function allows you to express your love of cats.
#' @param love Do you love cats? Defaults to TRUE.
#' @keywords cats
#' @export
#' @examples
#' cat_function()

load_grey_seal_counts <- function(){

  # load data
  seals.nrm = read.csv("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seal-scormorants/grey-seal-counts/grey_seal_count.csv", fileEncoding = "ISO-8859-1") # load data

  return(seals.nrm)


}
