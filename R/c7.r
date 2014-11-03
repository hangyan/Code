setwd("~/Code/R/RBook")
BFCases <- read.table(file = "Birdflucases.txt",
                      header = TRUE)
names(BFCases)
str(BFCases)

Cases <- rowSums(BFCases[,2:16])
names(Cases) <- BFCases[,1]
Cases

par(mfrow = c(3,4),mar = c(3,3,2,1))
pie(Cases, main = "Ordinary pie chart")
pie(Cases, col = gray(seq(0.4,1.0,length = 6)),
     clockwise = TRUE,main = "Grey colours")
pie(Cases, col = rainbow(6), clockwise = TRUE,    main = "Rainbow colours")

library(plotrix)
pie3D(Cases,labels = names(Cases),
      explode = 0.1, main = "3D pie chart",
      labelcex = 0.6)




BFDeaths <- read.table(file = "Birdfludeaths.txt",
                       header = TRUE)
Deaths <- rowSums(BFDeaths[,2:16])
names(Deaths) <- BFDeaths[,1]
Deaths

par(mfrow = c(2,2), mar = c(3,3,2,1))
barplot(Cases, main = "Bird flu cases")

Counts <- cbind(Cases,Deaths)
barplot(Counts)
barplot(t(Counts), col = gray(c(0.5,1)))
barplot(t(Counts), beside = TRUE)
