setwd("~/Code/R/RBook")
Owls <- read.table(file = "Owls.txt",header = TRUE)
boxplot(Owls$NegPerChick)

par(mfrow = c(2,2), mar = c(3,3,2,1))
boxplot(NegPerChick ~ SexParent, data = Owls)
boxplot(NegPerChick ~ FoodTreatment, data = Owls)
boxplot(NegPerChick ~ SexParent * FoodTreatment, data = Owls)
boxplot(NegPerChick ~ SexParent * FoodTreatment,
        names = c("F/Dep", "M/Dep", "F/Sat", "M/Sat"),
        data = Owls)
boxplot(NegPerChick ~ Nest, data = Owls)

