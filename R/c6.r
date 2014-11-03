setwd("~/Code/R/RBook/")
Owls <- read.table(file = "Owls.txt",
                   header = TRUE)
names(Owls)
str(Owls)
unique(Owls$Nest)

Owls.ATV <- Owls[Owls$Nest == "AutavauxTV",]


AllNests <- unique(Owls$Nest)
for ( i in 1:27) {
    Nest.i <- AllNests[i]
    Owls.i <- Owls[Owls$Nest == Nest.i,]
    YourFileName <- paste(Nest.i, ".jpg", sep = " ")
    jpeg(file = YourFileName)
    
    plot(x = Owls.i$ArrivalTime,
         y = Owls.i$NegPerChick,
         xlab = "Arrival Time",
         main = Nest.i,
         ylab = "Negotiation behaviour")
    dev.off()
 }
