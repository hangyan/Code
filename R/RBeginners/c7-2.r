setwd("~/Code/R/RBook")
Benthic <- read.table(file = "RIKZ2.txt",
                       header = TRUE)

Bent.M <- tapply(Benthic$Richness,
                 INDEX = Benthic$Beach,
                 FUN = mean)
Bent.sd <- tapply(Benthic$Richness,
                  INDEX = Benthic$Beach,
                  FUN = sd)
MSD <- cbind(Bent.M,Bent.sd)

# barplot(Bent.M)
barplot(Bent.M, xlab = "Beach", ylim = c(0,20),
        ylab = "Richness", col = rainbow(9))

bp <- barplot(Bent.M, xlab = "Beach", ylim = c(0,20),
              ylab = "Richness", col = rainbow(9))
arrows(bp, Bent.M,bp,Bent.M + Bent.sd,lwd = 1.5,
       angle = 90,length = 0.1)
box()
