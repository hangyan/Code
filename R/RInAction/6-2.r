par(mfrow = c(2,2))

slices <- c(10, 12.4, 16, 8)
lbls <- c("US", "UK", "Australia", "Germany", "France")

pie(slices, labels = lbls, main = "Simple Pie Chart")

pct <- round(slices/sum(slices)*100)
lbls2 <- paste(lbls, " ", pct, "%", sep = "")
pie(slices, labels = lbls2, col = rainbow(length(lbls2)), main = "Pie")

library(plotrix)


fan.plot(slices, labels = lbls, main = "Fan")
