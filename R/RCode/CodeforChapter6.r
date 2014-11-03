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




setwd("C:/RBook/")
Owls <- read.table(file="Owls.txt",header = TRUE)
names(Owls)
str(Owls)

#[1] "Nest"               "FoodTreatment"
#[3] "SexParent"          "ArrivalTime"
#[5] "SiblingNegotiation" "BroodSize"
#[7] "NegPerChick"

unique(Owls$Nest)

#> unique(Owls$Nest)
# [1] AutavauxTV      Bochet          Champmartin
# [4] ChEsard         Chevroux        CorcellesFavres
# [7] Etrabloz        Forel           Franex
#[10] GDLV            Gletterens      Henniez
#[13] Jeuss           LesPlanches     Lucens
#[16] Lully           Marnand         Moutet
#[19] Murist          Oleyes          Payerne
#[22] Rueyes          Seiry           SEvaz
#[25] StAubin         Trey            Yvonnand
#27 Levels: AutavauxTV Bochet Champmartin ... Yvonnand
#>

Owls.ATV<-Owls[Owls$Nest=="AutavauxTV",]

plot(x = Owls.ATV$ArrivalTime, y = Owls.ATV$NegPerChick,
     xlab = "Arrival Time", ylab = "Negotiation behaviour",
     main =  "AutavauxTV")




#Ensure that the following directory exists!
setwd("C:/AllGraphs/")

Nest.i <- "Bochet"
Owls.i <- Owls[Owls$Nest == Nest.i, ]
YourFileName <- paste(Nest.i,".jpg",sep="")
jpeg(file=YourFileName)

plot(x = Owls.i$ArrivalTime, y = Owls.i$NegPerChick,
     xlab = "Arrival Time", ylab = "Negotiation time",
     main =  Nest.i)
dev.off()


AllNests <- unique(Owls$Nest)
for (i in 1:27){
   Nest.i <- AllNests[i]
   Owls.i <- Owls[Owls$Nest == Nest.i, ]
   YourFileName <- paste(Nest.i,".jpg",sep="")
   jpeg(file=YourFileName)
   plot(x = Owls.i$ArrivalTime, y = Owls.i$NegPerChick,
     xlab = "Arrival Time", ylab = "Negotiation time",
     main =  Nest.i)
   dev.off()
}


#Function
MyPlot <- function(N.i, Z){
   Z.i <- Z[Z$Nest == N.i, ]
   YFName <- paste(N.i,".jpg",sep="")
   jpeg(file=YFName)
   plot(x = Z.i$ArrivalTime, y = Z.i$NegPerChick,
     xlab = "Arrival Time", ylab = "Negotiation time",
     main =  N.i)
   dev.off()
}

for (i in 1:27){
   Nest.i <- AllNests[i]
   MyPlot(Nest.i,Owls)
}


####
# Functions
setwd("c:/RBook/")
Parasite <- read.table(file="CodParasite.txt",
                    header = TRUE)

names(Parasite)

NAPerVariable<-function(X1) {
  D <- is.na(X1)
  colSums(D)
}

NAPerVariable(Parasite)

ZerosPerVariable<-function(X1) {
  D1 = X1 == 0
  colSums(D1)
}

ZerosPerVariable(Parasite)

ZerosPerVariable<-function(X1) {
  D1 = X1 == 0
  colSums(D1, na.rm = TRUE)
}

ZerosPerVariable(Parasite)

#NAs or zeros
VariableInfo<-function(X1,Choice1) {
  if (Choice1 =="Zeros"){ D1 = X1 == 0 }
  if (Choice1 =="NAs")  { D1 <- is.na(X1)}
  colSums(D1, na.rm = TRUE)
}


VariableInfo(Parasite,"Zeros")
VariableInfo(Parasite,"NAs")

#Add default value
VariableInfo<-function(X1,Choice1 = "Zeros") {
  if (Choice1 =="Zeros"){ D1 = X1 == 0 }
  if (Choice1 =="NAs")  { D1 <- is.na(X1)}
  colSums(D1, na.rm = TRUE)
}

VariableInfo(Parasite)


VariableInfo <- function(X1,Choice1 = "Zeros") {
  switch(Choice1,
       "Zeros" { D1 <- (X1 == 0) }
       "NAs"   { D1 <- is.na(X1)})

  colSums(D1, na.rm = TRUE)
}

VariableInfo(Parasite)


#Misspelling

#Add default value
VariableInfo<-function(X1,Choice1 = "Zeros") {
  if (Choice1 =="Zeros"){ D1 = X1 == 0 }
  if (Choice1 =="NAs")  { D1 <- is.na(X1)}
  if (Choice1 != "Zeros" & Choice1 != "Nas") {print("You made a typo")} else {
  colSums(D1, na.rm = TRUE)}
}

VariableInfo(Parasite,"abracadabra")


x<-seq(1:100)
y<-seq(1:100)

plot(x,y)
lines(x,y)
points(x,y)

jpeg(file="AnyName.jpg")
  plot(x,y)
  lines(x,y)
  points(x,y)
dev.off()

plot(x,y)
lines(x,y)
points(x,y)






##########  RIKZ STUFF
setwd("C:/RBook/")
Benthic <- read.table("RIKZ.txt",header=T)
Species <- Benthic[,2:76]
n <- dim(Species)

sum(Species[1, ], na.rm = TRUE)
sum(Species[2, ], na.rm = TRUE)

TA <- vector(length = n[1])
for (i in 1:n[1]){
    TA[i] <- sum(Species[i,], na.rm = TRUE)
  }


TA <- rowSums(Species, na.rm = TRUE)
sum(Species[1,] > 0, na.rm = TRUE)


Richness <- vector(length = n[1])
for (i in 1:n[1]){
   Richness[i] <- sum(Species[i, ] > 0, na.rm = TRUE)
  }
Richness


Richness <- rowSums(Species > 0, na.rm = TRUE)

RS <- rowSums(Species, na.rm = TRUE)
prop <- Species / RS
H <- -rowSums(prop * log10(prop), na.rm = TRUE)
H

library(vegan)
H <- diversity(Species)
H

Choice <- "Richness"

if (Choice == "Richness") {
     Index <- rowSums(Species >0 , na.rm = TRUE)}
if (Choice == "Total Abundance") {
      Index <- rowSums(Species, na.rm = TRUE) }
if (Choice=="Shannon") {
     RS <- rowSums(Species, na.rm = TRUE)
     prop <- Species / RS
     Index <- -rowSums(prop * log10(prop), na.rm = TRUE)}


Index.function <- function(Spec, Choice){
  if (Choice == "Richness") {
     Index <- rowSums(Spec>0, na.rm = TRUE)}
  if (Choice == "Total Abundance") {
      Index <- rowSums(Spec, na.rm = TRUE) }
  if (Choice=="Shannon") {
     RS <- rowSums(Species, na.rm = TRUE)
     prop <- Species / RS
     Index <- -rowSums(prop * log10(prop), na.rm = TRUE)}
  list(Index = Index, MyChoice = Choice)
  }
