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


setwd("c:/RBook/")
Veg <- read.table(file="Vegetation2.txt",
    header =TRUE)
names(Veg)
str(Veg)

m <- mean(Veg$R)
m1 <- mean(Veg$R[Veg$Transect == 1])
m2 <- mean(Veg$R[Veg$Transect == 2])
m3 <- mean(Veg$R[Veg$Transect == 3])
m4 <- mean(Veg$R[Veg$Transect == 4])
m5 <- mean(Veg$R[Veg$Transect == 5])
m6 <- mean(Veg$R[Veg$Transect == 6])
m7 <- mean(Veg$R[Veg$Transect == 7])
m8 <- mean(Veg$R[Veg$Transect == 8])
c(m, m1, m2, m3, m4, m4, m5, m6, m7, m8)

Me <- tapply(Veg$R, Veg$Transect, mean)
Sd <- tapply(Veg$R, Veg$Transect, sd)
Le <- tapply(Veg$R, Veg$Transect, length)
cbind(Me, Sd, Le)

sapply(Veg[, 5:10], FUN = mean)

Z <-cbind(Veg$R, Veg$ROCK, Veg$LITTER, Veg$ML)
colnames(Z) <- c("R","ROCK","LITTER","ML")
summary(Z)

names(Veg)

# [1] "TransectName" "Samples"      "Transect"
# [4] "Time"         "R"            "ROCK"
# [7] "LITTER"       "ML"           "BARESOIL"
#[10] "FallPrec"     "SprPrec"      "SumPrec"
#[13] "WinPrec"      "FallTmax"     "SprTmax"
#[16] "SumTmax"      "WinTmax"      "FallTmin"
#[19] "SprTmin"      "SumTmin"      "WinTmin"
#[22] "PCTSAND"      "PCTSILT"      "PCTOrgC"

summary(Veg[,c("R","ROCK","LITTER","ML")])
summary(Veg[,c(5,6,7,8)])




setwd("c:/RBook/")
Deer <- read.table(file="Deer.txt", header =TRUE)
names(Deer)
str(Deer)

table(Deer$Farm)
table(Deer$Sex, Deer$Year)