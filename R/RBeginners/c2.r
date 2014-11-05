Wingcrd <- c(59, 55, 53.5, 55, 52.5, 57.5, 53, 55)

Tarsus <- c(22.3, 19.7, 20.8, 20.3, 20.8, 21.5, 20.6, 21.5)
Head <- c(31.2, 30.4, 30.6, 30.3, 30.3, 30.8, 32.5, NA)
Wt <- c(9.5, 13.8, 14.8, 15.2, 15.5, 15.6, 15.6, 15.7)


sum(Head,na.rm = TRUE)
BirdData <- c(Wingcrd,Tarsus,Head,Wt)

Id <- c(1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2,
     2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4)

Id <- rep(c(1,2,3,4), each = 8 )
Id <- rep(1 : 4, each = 8)
VarNames <- c("Wingcrd", "Tarsus", "Head", "Wt")
Id2 <- rep(VarNames, each = 8)
Z <- cbind(Wingcrd,Tarsus,Head,Wt)
Z2 <- rbind(Wingcrd,Tarsus,Head,Wt)
Dmat <- matrix(nrow=8, ncol = 4)

Dmat[, 1] <- c(59, 55, 53.5, 55, 52.5, 57.5, 53, 55)
Dmat[, 2] <- c(22.3, 19.7, 20.8, 20.3, 20.8, 21.5,
                 20.6, 21.5)
Dmat[, 3] <- c(31.2, 30.4, 30.6, 30.3, 30.3, 30.8,
                 32.5, NA)
Dmat[, 4] <- c(9.5, 13.8, 14.8, 15.2, 15.5, 15.6,
                 15.6, 15.7)

colnames(Dmat) <- c("Wingcrd", "Tarsus", "Head", "Wt")

Dmat2 <- as.matrix(cbind(Wingcrd, Tarsus, Head, Wt))
Dmat2

## 数据框
Dfrm <- data.frame(WC = Wingcrd,
                   TS = Tarsus,
                   HD = Head,
                   W = Wt)
Dfrm

Dfrm <- data.frame(WC = Wingcrd,
                   TS = Tarsus,
                   HD = Head,
                   W = Wt,
                   Wsq = sqrt(Wt))
Dfrm

x1 <- c(1,2,3)
x2 <- c("a","b","c","d")
x3 <- 3
x4 <- matrix(nrow = 2, ncol = 2)
x4[,1] <- c(1,2)
x4[,2] <- c(3,4)
Y <- list(x1 = x1, x2 = x2, x3 = x3, x4 =x4)
Y

AllData <- list(BirdData = BirdData, Id = Id2, Z = Z,VarNames = VarNames)
AllData

## read data
Squid <- read.table(file = "~/Code/R/RBook/squid.txt", header = TRUE)


names(Squid)

## show data type
str(Squid)

mean(Squid$GSI)

## attach(Squid)

## boxplot(GSI)



unique(Squid$Sex)

Sel <- Squid$Sex == 1
SquidM <- Squid[Sel,]
SquidF <- Squid[Squid$Sex == 2, ]

SquidM.1 <- Squid[Squid$Sex == 1 & Squid$Location == 1,]
Ord1 <- order(Squid$Month)

## merge data
setwd("~/Code/R/RBook")
Sq1 <- read.table(file = "squid1.txt", header = TRUE)
Sq2 <- read.table(file = "squid2.txt", header = TRUE)
SquidMerged <- merge(Sq1,Sq2,by = "Sample")

write.table(SquidM,file="MaleSquid.txt",sep=" ",quote=FALSE,append=FALSE,na="NA")

Squid$fLocation <- factor(Squid$Location)
Squid$fSex <- factor(Squid$Sex)
Squid$fSex <- factor(Squid$Sex, levels = c(1,2), labels = c("M", "F"))

#boxplot(GSI ~ fSex, data = Squid)
M1 <- lm(GSI ~ fSex + fLocation,data = Squid)
summary(M1)

## boxplot(GSI ~ fLocation, data = Squid)
Squid$fLocation <- factor(Squid$Location, levels = c(2,3,1,4))
## boxplot(GSI ~ fLocation, data = Squid)

SquidM <- Squid[Squid$Sex == 1,]
SquidM <- Squid[Squid$fSex == "1",]
Squid$fSex <- factor(Squid$Sex, labels = c("M","F"))
Squid$fLocatoin <- factor(Squid$Location)
str(Squid)













