setwd("~/Code/R/RBook")
Benthic <- read.table(file = "RIKZ2.txt",
                      header = TRUE)
Bentic.n <-  tapply(Benthic$Richness,Benthic$Beach,FUN = length)
Bentic.n

