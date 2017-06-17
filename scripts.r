## list of functions to read EDM

setwd("~/learning/r/20170616_stressTestMachine")
# options(repos = c(CRAN= "http://cran.rstudio.com"))
source("ipak.r")
packages <- c("data.table", "parallel", "SDMTools", "magrittr")
ipak(packages)


getPointDist <- function(latLonList, fInfoAll, RNIProxy) {
    # latLonList <- c(43.26306, 140.6425)
    library("SDMTools")
    library("data.table")
    fInfoAll <- fi
    # we take top segment of each plane, and only those points within +- 8 degrees lat longs
    fInfo <- fInfoAll[SegmentID == 1][((StartLatitude > (latLonList[1] - RNIProxy)) & (EndLatitude < latLonList[1] + RNIProxy)) & ((StartLongitude > (latLonList[2] - RNIProxy)) & (EndLongitude < latLonList[2] + RNIProxy))]
    fInfo$distanceStart <- data.table(distance2(data.frame(latLonList[1],latLonList[2], fInfo$StartLatitude, fInfo$StartLongitude),bearing=FALSE))$distance/1000
    fInfo$distanceEnd <- data.table(distance2(data.frame(latLonList[1],latLonList[2], fInfo$EndLatitude, fInfo$EndLongitude),bearing=FALSE))$distance/1000
    return(transform(fInfo, "dMin"= ifelse(distanceStart > distanceEnd, distanceEnd, distanceStart)))
} 

distance2 <- function (lat1, lon1 = NULL, lat2 = NULL, lon2 = NULL, bearing = FALSE) 
{
        library("SDMTools")
        library("data.table")
        lat1 = as.matrix(lat1)
        lon2 = lat1[, 4]
        lat2 = lat1[, 3]
        lon1 = lat1[, 2]
        lat1 = lat1[, 1]
        out = data.frame(lat1 = lat1, lon1 = lon1, lat2 = lat2, lon2 = lon2)
        out$distance = .Call("Dist", out$lat1, out$lon1, out$lat2, 
            out$lon2, PACKAGE = "SDMTools")
        return(out)
}

createDist <- function(i) {
    library("SDMTools")
    library("data.table")
    return(getPointDist(c(li[i]$Latitude, li[i]$Longitude), fi, 2.5))
}

## implementation
t1 <- Sys.time()
li <- fread('li.csv')
t2 <- Sys.time()
print('Time to read locations is ')
print(t2-t1)
fi <- fread('fi.csv')
t3 <- Sys.time()
print('Time to read faults is ')
print(t3-t2)
ncl <- (detectCores())
cl <- makeCluster(getOption("cl.cores", ncl))
clusterExport(cl=cl, varlist=c("li", "fi", "distance2", "getPointDist"), envir=environment())
distRaw <- parLapply(cl,1:nrow(li),createDist)
stopCluster(cl)
t4 <- Sys.time()
print('Time to generate distances on the fly is ')
print(t4-t3)
distances <- rbindlist(distRaw)
t5 <- Sys.time()
print('Time to get rbindlist is ')
print(t5-t4)

