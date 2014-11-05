setwd("~/Code/R/RBook/")
Veg <- read.table(file="Vegetation2.txt",
                  header = TRUE)
names(Veg)

m <- mean(Veg$R)
m1 <- mean(Veg$R[Veg$Transect == 1])
m2 <- mean(Veg$R[Veg$Transect == 2])
m3 <- mean(Veg$R[Veg$Transect == 3])
m4 <- mean(Veg$R[Veg$Transect == 4])
m5 <- mean(Veg$R[Veg$Transect == 5])
m6 <- mean(Veg$R[Veg$Transect == 6])
m7 <- mean(Veg$R[Veg$Transect == 7])
m8 <- mean(Veg$R[Veg$Transect == 8])
c(m,m1,m2,m3,m4,m5,m6,m7,m8)

tapply(Veg$R, Veg$Transect,mean)
Me <- tapply(X = Veg$R, INDEX = Veg$Transect, FUN = mean)
Sd <- tapply(X = Veg$R, INDEX = Veg$Transect, FUN = sd)
Le <- tapply(X = Veg$R, INDEX = Veg$Transect, FUN = length)
cbind(Me,Sd,Le)

sapply(Veg[,5:9], FUN = mean)
lapply(Veg[,5:9], FUN = mean)


sapply(data.frame(cbind(Veg$R,Veg$ROCK,Veg$LITTER,Veg$ML,Veg$BARESOIL)), FUN = mean)
Z <- cbind(Veg$R, Veg$ROCK, Veg$LITTER)
colnames(Z) <- c("R", "ROCK", "LITTER")
summary(Z)

summary(Veg[,c("R","ROCK","LITTER")])

summary(Veg[,c(5,6,7)])




















