setwd("~/Code/R/RBook")
Veg <- read.table(file = "Vegetation2.txt",
                  header = TRUE)
# plot(Veg$BARESOIL,Veg$R)

Veg$Time2 <- Veg$Time
Veg$Time2 [Veg$Time <= 1974] <- 15
Veg$Time2 [Veg$Time > 1974] <- 16

Veg$Col2 <- Veg$Time
Veg$Col2 [Veg$Time <= 1974] <- 1
Veg$Col2 [Veg$Time > 1974] <- 2

Veg$Cex2 <- Veg$Time
Veg$Cex2 [Veg$Time == 2002 ] <- 2
Veg$Cex2 [Veg$Time != 2002 ] <-1



 plot(x = Veg$BARESOIL, y = Veg$R,
      xlab = "Exposed soil",
      ylab = "Species richness",
      main = "Scatter plot",
      xlim = c(0, 45), ylim = c(4, 19),
      pch = Veg$Time2,
      col = Veg$Col2,
      cex = Veg$Cex2)
 


M.Loess <- loess(R ~ BARESOIL, data = Veg)
Fit <- fitted(M.Loess)
Ord1 <- order(Veg$BARESOIL)
lines(Veg$BARESOIL[Ord1], Fit[Ord1],
      lwd = 3, lty =2)


