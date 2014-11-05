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

x=1:25
y=1:5
z=rep(1,5)

par(mar=c(2,0,1,2))
plot(z,y,pch=x[1:5],axes=FALSE,xlim=c(0,5),xlab="",ylab="")
text(z-0.3,y,x[1:5],cex=0.8)

z1=rep(2,5)
points(z1,y,pch=x[6:10])
text(z1-0.3,y,x[6:10],cex=0.8)

z2=rep(3,5)
points(z2,y,pch=x[11:15])
text(z2-0.3,y,x[11:15],cex=0.8)

z3=rep(4,5)
points(z3,y,pch=x[16:20])
text(z3-0.3,y,x[16:20],cex=0.8)

z4=rep(5,5)
points(z4,y,pch=x[21:25])
text(z4-0.3,y,x[21:25],cex=0.8)


plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19))

plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     pch = 19)
     
plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     pch = Veg$Transect)
     
Veg$fTransect <- factor(Veg$Transect)
plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     pch = Veg$fTransect)
     
     
Veg$Time2 <- Veg$Time
Veg$Time2[Veg$Time <= 1974] <- 1
Veg$Time2[Veg$Time > 1974] <- 16

plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     pch = Veg$Time2)


plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     pch = Veg$Time)


plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     col = 2)
     

plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     col = 3)


x <- 1:8
plot(x,col=x)


Veg$Time2 <- Veg$Time
Veg$Time2[Veg$Time <= 1974] <- 15
Veg$Time2[Veg$Time > 1974] <- 16

Veg$Col2 <- Veg$Time
Veg$Col2[Veg$Time <= 1974] <- 1
Veg$Col2[Veg$Time > 1974] <- 2

plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     pch = Veg$Time2,
     col = Veg$Col2)
     

plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     pch = 16, cex = 1.5)

Veg$Cex2 <- Veg$Time
Veg$Cex2[Veg$Time == 2002] <- 2
Veg$Cex2[Veg$Time != 2002] <- 1

plot(x = Veg$BARESOIL, y = Veg$R, xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19))
M.Loess <- loess(R ~ BARESOIL, data = Veg)
Fit <- fitted(M.Loess)
lines(Veg$BARESOIL, Fit)


plot(x = Veg$BARESOIL, y = Veg$R,
     xlab = "Exposed soil",
     ylab = "Species richness", main = "Scatter plot",
     xlim = c(0, 45), ylim = c(4, 19),
     pch = 16, cex = Veg$Transect / 4)


M1 <- lm(R~BARESOIL * factor(Transect), data = Veg)
summary(M1)


