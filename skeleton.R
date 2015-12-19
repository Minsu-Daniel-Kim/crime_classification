# Skeleton code of Crime Classification project.
# author: Daniel Minsu Kim, Yaxin Yu

#if (!require(devtools)) {
#  install.packages("devtools")
#}
#library("devtools")
#source_gist(9112634)
#package(c('devtools', 'geosphere', 'ggplot2','RCurl','party','caret', 'dplyr', 'ggmap', 'XML', 'lubridate', 'rpart', 'rattle', 'rpart.plot', 'RColorBrewer', 'doMC'))

#################### Project Directory Setup ########################
library(RCurl)
library(XML)
library(geosphere)
library(rattle)
library(party)
library(rpart.plot)
library(caret)
library(RColorBrewer)
library(dplyr)
library(rpart)
library(doMC)
library(lubridate)
library(ggplot2)
library(ggmap)
# set up project folder, create necessary subdirectories
dir.create("code")
dir.create("rawdata")
dir.create("data")
dir.create("resources")
dir.create("report")
dir.create("images")

# move files to corresponding folders
file.rename(from = "preprocess.R", to = "code/preprocess.R")
file.rename(from = "getMinDistanceFromStarbucks.R", to = "code/starbucks.R")
file.rename(from = "utils.R", to = "code/utils.R")
file.rename(from = "utils2.R", to = "code/utils2.R")
file.rename(from = "modeling.R", to = "code/modeling.R")
file.rename(from = "minDists.csv", to = "data/minDists.csv")
file.rename(from = "plotMaps.R", to = "code/plotMaps.R")
file.rename(from = "plotCrimeMinStarbucksDist.R", to = "code/plotCrimeMinStarbucksDist.R")
file.rename(from = "crime.csv", to = "rawdata/crime.csv")

######################## Data Retrieval ###############################

# retrieve crime data

# IMPORTANT NOTE: the following line is going take 10 minutes to download
# the raw crime data file. For your time, we also submitted a pre-downlaoded
# csv file. Feel free to skip this line. If you'd like to use the pre-downloaded file
# comment out the code below.
# crime <- read.csv("rawdata/crime.csv", nrows = 878049)
download.file("https://data.sfgov.org/api/views/gxxq-x39z/rows.csv?accessType=DOWNLOAD",destfile="rawdata/crime.csv",method="libcurl")

# retrieve map
mapgilbert <- get_map(location = c(lon = mean(crime$X), lat = mean(crime$Y)), zoom = 12, scale = 2)

# retrieve San Francisco Starbucks data
addresses <- c()
pages <- c("", "-2", "-3", "-4", "-5", "-6", "-7")
for (i in 1:length(pages)) {
  url <- paste0("http://www.city-data.com/locations/Starbucks/San-Francisco-California", pages[i], ".html")
  page <- htmlTreeParse(url, useInternalNodes = TRUE)
  addressNodes <- getNodeSet(page, "//div/span/span")
  values <- sapply(addressNodes, xmlValue)
  indices <- grep("streetAddress", sapply(addressNodes, xmlAttrs))
  addresses <- c(addresses, values[indices])
}
starAdd <- data.frame(address = addresses)
write.csv(starAdd, file = "rawdata/StarbucksAdd.csv", row.names = FALSE)


# save metadata about the raw data in rawdata subdirectory
write.table(summary(crime), file = "rawdata/metadata", row.names = FALSE)

#################### Load Utility and Plotting Functions & Clean Data ##########################
# load utility functions and clean raw data
source("code/utils.R")
source("code/utils2.R")
source("code/preprocess.R")

#IMPORTANT NOTE# we strongly suggest not to run the following line of code, as it will take 
# apporximately 10 hours. For each crime instance, getMinDistanceFromStarbucks.R calculates
# its distance from the closest Starbucks shop. Instead, we have submitted the result
# (minDists.csv in data directory) along with our code scripts. The csv file will be loaded
# directly when needed. 
# source("code/getMinDistanceFromStarbucks.R")
# so, we suggest to import directly from csv file.
dists <- read.csv("data/minDists.csv", stringsAsFactors = FALSE)
# load plotting functions
source("code/plotMaps.R")

source("code/plotCrimeMinStarbucksDist.R")
# since this script runs all of ML algorithms, it takes time to import.
source("code/modeling.R")
