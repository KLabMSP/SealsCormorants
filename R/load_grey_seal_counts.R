#' Loading grey seal count data
#'
#' This function loads grey seal count data from our research server and cleans it up.
#' @return a file with grey seal count data
#' @examples
#' seal_data = load_grey_seal_counts()



load_grey_seal_counts <- function(){

  # load data
  seals.nrm = read.csv("//storage-ua.slu.se/research$/Aqua/Områdesskydd och havsplanering/seal-scormorants/grey-seal-counts/grey_seal_count.csv", fileEncoding = "ISO-8859-1") # load data

  # fix lat and long variables
  seals.nrm$lat = as.numeric(substr(seals.nrm$lat, 1,2)) +
    as.numeric(substr(seals.nrm$lat, 4,5))/60 +
    as.numeric(substr(seals.nrm$lat, 7,8))/10000
  seals.nrm$long = as.numeric(substr(seals.nrm$long, 1,2)) +
    as.numeric(substr(seals.nrm$long, 4,5))/60 +
    as.numeric(substr(seals.nrm$long, 7,8))/10000


  # fix date column
  seals.nrm$date = as.Date(seals.nrm$date, format = "%d/%m/%Y")


  # only interested in total count
  seals.nrm = subset(seals.nrm, parameter == "# counted")


  # remove reports from Finland (keeping Märket)
  seals.nrm = subset(seals.nrm, station != "Finland")


  # explore (and remove) observation on ice
  sum(seals.nrm$station == "Utsjö is")/nrow(seals.nrm)
  table(seals.nrm$year[seals.nrm$station == "Utsjö is"], seals.nrm$county[seals.nrm$station == "Utsjö is"])
  table(seals.nrm$year[seals.nrm$station == "Utsjö is"], lubridate::month(seals.nrm$date[seals.nrm$station == "Utsjö is"]))
  table(seals.nrm$year[seals.nrm$station != "Utsjö is"], lubridate::month(seals.nrm$date[seals.nrm$station != "Utsjö is"]))
  seals.nrm = subset(seals.nrm, station != "Utsjö is")


  # remove before 1990 (no reports available)
  seals.nrm = subset(seals.nrm, year >= 1990)


  # when zeroes were reported, often as Phocidae - change to grey seal
  seals.nrm$species[seals.nrm$count == 0] = "Halichoerus grypus" # if zero, change from Phocidae to grey seal
  seals.nrm = subset(seals.nrm, species %in% c("Halichoerus grypus", "Phocidae")) # remove observations of ringed and harbour seals (few - likely mistake to include, harbour seals from Måkläppen, where mixed - less clear whether ringed seal is mistake or not - very low numbers and far away from core area)
  seals.nrm$species[seals.nrm$station == "SÖRBROTT" & seals.nrm$year == 1990] =  "Halichoerus grypus" # in report there is nothing to suggest that these aren't grey seals
  seals.nrm$species[seals.nrm$station ==  "Lördagshällan"  & seals.nrm$year == 1990] =  "Halichoerus grypus" # based on time lapse data from Mikael Sjöberg, Umeå
  seals.nrm$species[seals.nrm$station ==  "SANDSÄNKAN"  & seals.nrm$year == 1990] =  "Halichoerus grypus" # in report there is nothing to suggest that these aren't grey seals
  seals.nrm = seals.nrm[!(seals.nrm$station ==  "Måkläppen" & seals.nrm$species == "Phocidae"),] #  At Måkläppen sometimes counted together - remove!
  seals.nrm = seals.nrm[!(seals.nrm$year == 2002 & seals.nrm$species == "Phocidae"),] # a few places where species were counted together
  seals.nrm = seals.nrm[!(seals.nrm$year == 2001 & seals.nrm$species == "Phocidae" & seals.nrm$station == "DEGERSHUVUD"),] # one seal reported in water
  seals.nrm$species[seals.nrm$year == 2001] =  "Halichoerus grypus" # rest of Phocidae this year are from Märket - these are grey seals

  seals.nrm$week = lubridate::week(seals.nrm$date)

  seals.nrm = seals.nrm[!(seals.nrm$year == 1999 & seals.nrm$species == "Phocidae"),] # ice count that can not be seen in report
  seals.nrm = seals.nrm[!(seals.nrm$year %in% 1994:1995 & seals.nrm$species == "Phocidae" & seals.nrm$station == "TISTERÖRARNA"),] # mixed ringed and grey
  seals.nrm = seals.nrm[!(seals.nrm$year == 1993 & seals.nrm$species == "Phocidae" & seals.nrm$station %in% c("Gunnarstenarna", "Haparanda skärgård")),] # unclear one-off observation
  seals.nrm$species[!(seals.nrm$year == 1993 & seals.nrm$species == "Phocidae" & seals.nrm$station %in% c("LÖVGRUNDS RABBAR",
                                                                                                          "LILLGRUND", "Bondgrund", "Nygrönhällan"))] = "Halichoerus grypus" #  in report there is nothing to suggest that these aren't grey seals
  seals.nrm$species[!(seals.nrm$year == 1992 & seals.nrm$species == "Phocidae")] = "Halichoerus grypus" #  in report there is nothing to suggest that these aren't grey seals
  seals.nrm$species[!(seals.nrm$year == 1991 & seals.nrm$species == "Phocidae" & seals.nrm$station %in% c("Gran", "SANDSÄNKAN"))] = "Halichoerus grypus" #  in report there is nothing to suggest that these aren't grey seals
  seals.nrm = seals.nrm[!(seals.nrm$year == 1991 & seals.nrm$species == "Phocidae" & seals.nrm$station %in% c("VÄRNANÄS", "VIDBRÄNNAN")),] # could be mix of grey and harbour seals or grey and ringed
  seals.nrm = seals.nrm[!(seals.nrm$year == 1990 & seals.nrm$species == "Phocidae" & seals.nrm$station %in% c("VÄRNANÄS", "VIDBRÄNNAN")),] # not clear whether these are grey seals
  seals.nrm$species[!(seals.nrm$year == 1990 & seals.nrm$species == "Phocidae" & seals.nrm$station %in% c("BJÄSSHÄLLAN"))] = "Halichoerus grypus" #  in report there is nothing to suggest that these aren't grey seals



  # remove unnecessary columns
  seals.nrm = subset(seals.nrm, select = c(year, date, station,  time,lat, long, parameter, count))

  return(seals.nrm)

}
