#    A Beginner's Guide to R (2009)
#    Zuur, Ieno, Meesters.    Springer
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.




setwd("C:/RBook")
Env <- read.table(file="RIKZENV.txt",header = TRUE)
names(Env)

#"Sample"     "Date"       "DateNr"     "dDay1"      "dDay2"     
# [6] "dDay3"      "Station"    "Area"       "X31UE_ED50" "X31UN_ED50"
#[11] "Year"       "Month"      "Season"     "SAL"        "T"         
#[16] "CHLFa"

## Are there NAs?
  str(Env)
  sum(is.na(Env))  #2975 NAs

## where are the NAs?

    # Stations in each area
    table(Env$Station,Env$Area)
    
    tapply(Env$SAL,list(Env$Station,Env$Year,Env$Month),length)
    tapply(Env$SAL,list(Env$Station,Env$Month),length)
    tapply(Env$SAL,list(Env$Area,Env$Month),length)

    # count values
    ndata<-function(x) sum(!is.na(x))
    tapply(Env$SAL,list(Env$Station,Env$Month),ndata)
    tapply(Env$SAL,list(Env$Area,Env$Month),ndata)
    
    # count NAs
    nnas<-function(x) sum(is.na(x))
    tapply(Env$SAL,list(Env$Station,Env$Month),nnas)
    tapply(Env$SAL,list(Env$Area,Env$Month),nnas)



library(lattice)

Env$MyTime<-Env$Year+Env$dDay3/365

  xyplot(SAL ~ MyTime | factor(Station), type="l",
      strip = function(bg, ...)
           strip.default(bg = 'white', ...),
      col.line=1,
      data = Env)


xyplot(SAL ~ MyTime | factor(Station), data = Env)

xyplot(SAL ~ MyTime | factor(Station), type="l",
      strip = TRUE,
      col.line=1,
      data = Env)


xyplot(SAL ~ MyTime | factor(Station), type="l",
      strip = FALSE, col.line=1,
      data = Env)

  
bwplot(SAL ~ factor(Month) | Area,
   strip = strip.custom(bg = 'white'),
   cex = .5, layout = c(2, 5),
   data = Env, xlab = "Month", ylab = "Salinity",
   par.settings = list(
      box.rectangle = list(col = 1),
      box.umbrella  = list(col = 1),
      plot.symbol   = list(cex = .5, col = 1)))


bwplot(SAL ~ factor(Month) | Area,
   layout = c(2, 5), data = Env)





dotplot( factor(Month) ~ SAL  | Station,
    subset = Area=="OS", jitter.x = TRUE,
    data = Env, strip = strip.custom(bg = 'white'),
    col = 1, cex = 0.5, ylab = "Month",
    xlab = "Salinity")


dotplot(SAL ~ factor(Month) | Station,
    subset = Area=="OS", jitter.x = T,
    data = Env, strip = strip.custom(bg = 'white'),
    col = 1, cex = 0.5, xlab = "Month",
    ylab = "Salinity")



histogram( ~ SAL | Station, data = Env,
    subset = Area=="OS", layout = c(1,4),
    nint = 30, xlab = "Salinity", strip = FALSE,
    strip.left = TRUE, ylab="Frequencies")
    

#Example 1
xyplot(SAL ~ Month | Year, data = Env,
     type = c("p"), subset = (Station =="GROO"),
     xlim = c(0, 12), ylim = c(0, 30),pch = 19,
     panel = function (...){
     panel.xyplot(...)
     panel.grid(..., h = -1, v = -1)
     panel.loess(...)})


xyplot(SAL ~ Month | Year, data = Env,
     type = c("p"), subset = (Station =="GROO"),
     xlim = c(0, 12), ylim = c(0, 30),pch = 19, span = 0.5,
     panel = function (...){
     panel.xyplot(...)
     panel.grid(..., h = -1, v = -1)
     panel.loess(...)})




#Example 2

dotplot(factor(Month) ~ SAL | Station, pch = 16,
    subset = (Area=="OS"), data = Env,
    ylab = "Month", xlab = "Salinity",
    panel = function(x,y,...) {
      q1 <- summary(x,na.rm=TRUE)[2]
      q3 <- summary(x,na.rm=TRUE)[5]
      R <- q3 - q1
      L <- median(x,na.rm=TRUE) - 3 * (q3 - q1)
      MyCex <- rep(0.4,length(y))
      MyCol <- rep(1,length(y))
      MyCex[x < L] <- 1.5
      MyCol[x < L] <- 2
      panel.dotplot(x,y, cex = MyCex, col = MyCol, ...)})
      
setwd("C:/RBook")
library(lattice)
Env <- read.table(file="RIKZENV.txt",header = TRUE)

 dotplot(factor(Month) ~ SAL | Station, pch = 16,
    subset = (Area=="OS"), data = Env,
    ylab = "Month", xlab = "Salinity",
    panel = function(x, y, ...) {
      Q <- quantile(x, c(0.25, 0.5, 0.75) , 
                    na.rm = TRUE)
      R <- Q[3] - Q[1]
      L <- Q[2] - 3 * (Q[3] - Q[1])
      MyCex <- rep(0.4, length(y))
      MyCol <- rep(1, length(y))
      MyCex[x < L] <- 1.5
      MyCol[x < L] <- 2
      panel.dotplot(x, y, cex = MyCex, 
                    col = MyCol, ...)})



setwd("C:/RBook")
Sparrows<-read.table(file="Sparrows.txt", header=TRUE)
names(Sparrows)

#[1] "Species"  "Sex"      "Wingcrd"  "Tarsus"   "Head"     "Culmen"
#[7] "Nalospi"  "Wt"       "Observer" "Age"
 
library(lattice)


 xyplot(Wingcrd ~ Tarsus | Species * Sex,
     xlab = "Axis 1", ylab = "Axis 2", data = Sparrows,
     xlim = c(-1.1, 1.1), ylim = c(-1.1, 1.1),
     panel = function(subscripts, ...){
       zi <- Sparrows[subscripts, 3:8]
       di <- princomp(zi, cor = TRUE)
       Load <- di$loadings[, 1:2]
       Scor <- di$scores[, 1:2]
       panel.abline(a = 0, b = 0, lty = 2, col = 1)
       panel.abline(h = 0, v = 0, lty = 2, col = 1)
       for (i in 1:6){
           llines(c(0, Load[i, 1]), c(0, Load[i, 2]), 
                  col = 1, lwd = 2)
           ltext(Load[i, 1], Load[i, 2], 
                 rownames(Load)[i], cex = 0.7)}
       sc.max <- max(abs(Scor))
       Scor <- Scor / sc.max
       panel.points(Scor[, 1], Scor[, 2], pch = 1,
                   cex = 0.5, col = 1)
      })
     
     
     
 S1<-Sparrows[Sparrows$Species=="SESP" & Sparrows$Sex=="Female",3:8]
     
 di <- princomp(S1, cor = TRUE)
 Load <- di$loadings[, 1:2]
 Scor <- di$scores[, 1:2]
       
     
     
     
cloud(CHLFa ~ T * SAL | Station, data = Env,
    screen = list(z = 105, x = -70),
    ylab = "Sal", xlab = "T", zlab = "Chl. a",
    ylim = c(26,33),
    subset = (Area=="OS"),
    scales = list(arrows = FALSE))




setwd("C:/RBook")
Hawaii <- read.table("waterbirdislandseries.txt", header = TRUE)
library(lattice)

names(Hawaii)

Birds <- as.vector(as.matrix(Hawaii[,2:9]))


Time <- rep(Hawaii$Year, 8)
MyNames <- c("Stilt_Oahu","Stilt_Maui","Stilt_Kauai_Niihau",
             "Coot_Oahu","Coot_Maui","Coot_Kauai_Niihau",
             "Moorhen_Oahu","Moorhen_Kauai")
ID <- rep(MyNames, each = 48)


xyplot(Birds ~ Time|ID, ylab = "Bird abundance",
       layout = c(3, 3), type = "l", col = 1)



ID2 <- factor(ID,
             levels=c(
             "Stilt_Oahu",
             "Stilt_Kauai_Niihau",
             "Stilt_Maui",
             "Coot_Oahu",
             "Coot_Kauai_Niihau",
             "Coot_Maui",
             "Moorhen_Oahu",
             "Moorhen_Kauai"))


xyplot(Birds ~ Time|ID2, ylab = "Bird abundance",
       layout = c(3, 3), type = "l", col = 1)




xyplot(Birds ~ Time|ID2, ylab = "Bird abundance",
       layout = c(3, 3), type = "l", col = 1,
       scales = list(x = list(relation = "same"),
                     y = list(relation = "free"),
                     tck=-1))

  Species <-rep(c("Stilt","Stilt","Stilt",
            "Coot","Coot","Coot",
            "Moorhen","Moorhen"),each = 48)

 xyplot(Birds ~ Time|Species, ylab = "Bird abundance",
       layout = c(2, 2), type = "l", col = 1,
       scales = list(x = list(relation = "same"),
                     y = list(relation = "free")),
       groups = ID, lwd=c(1,2,3))



xyplot(Stilt_Oahu + Stilt_Maui + Stilt_Kauai_Niihau ~ Year,
       ylab = "Bird abundance", data = Hawaii,
       layout = c(2, 2), type = "l", col = 1,
       scales = list(x = list(relation = "same"),
                     y = list(relation = "free")))



setwd("C:/RBook")
Env <- read.table(file ="RIKZENV.txt", header = TRUE)
library(lattice)

AllAreas <- levels(unique(Env$Area))
for (i in AllAreas  ){ 
     Env.i <- Env[Env$Area==i,]
     dotplot(factor(Month)~SAL | Station, 
       data = Env.i)
     win.graph()
      }
           
           





