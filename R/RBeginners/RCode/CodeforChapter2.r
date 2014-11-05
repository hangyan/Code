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



Wingcrd <- c(59, 55, 53.5, 55, 52.5, 57.5, 53, 55)
Wingcrd[1]

S.win <- sum(Wingcrd)
S.win


Tarsus <- c(22.3, 19.7, 20.8, 20.3, 20.8, 21.5, 20.6, 21.5)
Head <- c(31.2, 30.4, 30.6, 30.3, 30.3, 30.8, 32.5, NA)
Wt <- c(9.5, 13.8, 14.8, 15.2, 15.5, 15.6, 15.6, 15.7)

sum(Head, na.rm = TRUE)

BirdData <- c(Wingcrd, Tarsus, Head, Wt)
Id <- c(1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2,
     2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4)


rep(c(1, 2, 3, 4), each = 8)
rep(1 : 4, each = 8)
a <- seq(from = 1, to = 4, by = 1)
a

a <- seq(from = 1, to = 4, by = 1)
rep(a, each = 8)



VarNames <- c("Wingcrd", "Tarsus", "Head", "Wt")
Id <- rep(VarNames, each = 8)


Z <- cbind(Wingcrd, Tarsus, Head, Wt)
n <- dim(Z)
n
n <- dim(Z)[1]
n

W <- vector(length = 8)
W[1] <- 59
W[2] <- 55
W[3] <- 53.5
W[4] <- 55
W[5] <- 52.5
W[6] <- 57.5
W[7] <- 53
W[8] <- 55


Dmat <- matrix(nrow = 8, ncol = 4)
Dmat

Dmat[, 1] <- c(59, 55, 53.5, 55, 52.5, 57.5, 53, 55)
Dmat[, 2] <- c(22.3, 19.7, 20.8, 20.3, 20.8, 21.5,
                 20.6, 21.5)
Dmat[, 3] <- c(31.2, 30.4, 30.6, 30.3, 30.3, 30.8,
                 32.5, NA)
Dmat[, 4] <- c(9.5, 13.8, 14.8, 15.2, 15.5, 15.6,
                 15.6, 15.7)

Dmat

colnames(Dmat) <- c("Wingcrd", "Tarsus", "Head", "Wt")
Dmat

Dmat2 <- as.matrix(cbind(Wingcrd,Tarsus,Head, Wt))

Dfrm <- data.frame(WC = Wingcrd, TS = Tarsus,
                HD = Head, W = Wt)
Dfrm


M <- lm(WC ~ Wt, data = Dfrm)


AllData <- list(BirdData = BirdData, Id = Id, Z = Z,
                VarNames = VarNames)

AllData <- list(BirdData, Id, Z, VarNames)

setwd("C:\\RBook\\")
Squid <- read.table(file = "squidGSI.txt",header = TRUE)


Sq1<-read.table(file="C:/RBook/squid1.txt",header=T)
Sq2<-read.table(file="C:/RBook/squid2.txt",header=T)

ZMerged<-merge(Sq1,Sq2,by="Sample")

write.table(ZMerged, file = "C:/RBook/MergedSquid.txt",
            sep = " ",quote=FALSE,append=FALSE,
            na="NA")
