library(ggmap)

library(plyr)

library(dplyr)

library(XML)

setwd("E:/Raw Data/Borough Taxi Data")

xmltop <- xmlRoot(xmlParse("http://monkeyhomes.com/map/nyc.xml"))

xmlAttrsNum <- function(xmlthing,n){
  return(as.numeric(xmlAttrs(xmlthing)[n]))
}

xmlAttrsStr <- function(xmlthing,n){
  return(xmlAttrs(xmlthing)[n])
}

subwaysdf <- data.frame(latitude = as.numeric(xmlSApply(xmltop, xmlAttrsNum, 1)),
                        longitude = as.numeric(xmlSApply(xmltop, xmlAttrsNum, 2)),
                        stopName = xmlSApply(xmltop, xmlAttrsStr, 3),
                        stopID = as.numeric(xmlSApply(xmltop, xmlAttrsNum, 5)))

subwaysdf$stopName <- as.character(subwaysdf$stopName)

subwaysdf <- rbind(subwaysdf, c(40.858882, -73.855375, "Pelham Pkwy 5", 429))

subwaysdf$latitude <- as.numeric(subwaysdf$latitude)
subwaysdf$longitude <- as.numeric(subwaysdf$longitude)
subwaysdf$stopID <- as.numeric(subwaysdf$stopID)

delta <- 0.0018

subwaysdf$maxLat <- subwaysdf$latitude + delta
subwaysdf$minLat <- subwaysdf$latitude - delta
subwaysdf$maxLon <- subwaysdf$longitude + delta
subwaysdf$minLon <- subwaysdf$longitude - delta

any(subwaysdf$minLat < testlat & testlat < subwaysdf$maxLat &
  subwaysdf$minLon < testlon & testlon < subwaysdf$maxLon)

40.72161  -73.84478	71-Continental Aves	270	40.72291	40.72031	-73.84348	-73.84608


(subwaysdf %>% filter(stopID == 22))$latitude


rides <- read.csv("trip201406.csv")

rides$id <- 1:dim(rides)[1]

#rides <- head(rides,1000)

subwaytest <- function(data){
  
  datatest <- subwaysdf$minLat < data$Dropoff_latitude & data$Dropoff_latitude < subwaysdf$maxLat &
    subwaysdf$minLon < data$Dropoff_longitude & data$Dropoff_longitude < subwaysdf$maxLon
  
  if(length(datatest[datatest]) == 1){
    subwayTagDF <- data.frame(datatest = datatest, stopID = subwaysdf$stopID)
    subwayTag <- (subwayTagDF %>% filter(datatest))$stopID
    c(subwayID = subwayTag)
  } else {
    c(subwayID = NA)
  }
  
  #c(datatest = with(data, any(subwaysdf$minLat < Dropoff_latitude & 
  #                              Dropoff_latitude < subwaysdf$maxLat &
  #                              subwaysdf$minLon < Dropoff_longitude &
  #                              Dropoff_longitude < subwaysdf$maxLon)))
  
}

subwaybool <- ddply(rides, .variables = "id", .fun = subwaytest)

subwayboolfiltered <- subwaybool %>% filter(!is.na(subwaybool$subwayID))

rides <- rides %>% filter(id %in% subwayboolfiltered$id)

months2013 <- c("09","10","11","12")
months2014 <- c("01","02","03","04","05","06")

names2013 <- paste("trip2013",months2013,".csv",sep="")
names2014 <- paste("trip2014",months2014,".csv",sep="")
names <- c(names2013,names2014)
names

rides <- read.csv("trip201308.csv")


for(name in names[10]){
  rides <- rbind(rides,read.csv(name))
}

rides <- read.csv("trip201309.csv")

rides$lpep_pickup_datetime <- strptime(rides$lpep_pickup_datetime, format="%Y-%m-%d %H:%M:%S")
rides$Lpep_dropoff_datetime <- strptime(rides$Lpep_dropoff_datetime, format="%Y-%m-%d %H:%M:%S")

nyc <- get_map(location = c(lon=-73.968410, lat=40.725496), zoom = 11)
ggmap(nyc)

ggmap(nyc, extent="device")

ggmap(nyc) + geom_point(data=rides, aes(x=Dropoff_longitude, y=Dropoff_latitude))

ggmap(nyc) + geom_point(data=rides, aes(x=Pickup_longitude, y=Pickup_latitude))

nyc <- get_map(location= c(lon=-73.847628, lat=40.728729), zoom = 15)

ggmap(nyc) + geom_point(data=rides, aes(x=Pickup_longitude, y=Pickup_latitude))

morningRides <- rides[rides$lpep_pickup_datetime$hour %in% c(7,8,9),]



ggmap(nyc) + geom_point(data=morningRides, aes(x=Pickup_longitude, y=Pickup_latitude))

morningRidesMerged <- merge(morningRides, subwayboolfiltered, by="id")

morningRidesSubway <- morningRides[morningRides$Dropoff_longitude > -73.844860 &
                                     morningRides$Dropoff_longitude < -73.843154 &
                                     morningRides$Dropoff_latitude > 40.720679 &
                                     morningRides$Dropoff_latitude < 40.722346,]

ggmap(nyc) + geom_point(data=morningRidesSubway, aes(x=Pickup_longitude, y=Pickup_latitude))

write.csv(morningRidesMerged, "gtdelta00018.csv")

write.csv(subwaysdf, "subwaypoly.csv")

library(RPostgreSQL)

con <- dbConnect(RPostgreSQL::PostgreSQL(), user="postgres", password="is607",
                 dbname="borocabs")

con

dbWriteTable(con, "rides", rides, row.names=TRUE)

