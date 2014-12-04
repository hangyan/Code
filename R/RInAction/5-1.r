cars <- mtcars[1:5, 1:4]
cars
t(cars)

options(digits = 3)
attach(mtcars)
aggdata <- aggregate(mtcars, by = list(cyl, gear), FUN = mean, na.rm = TRUE)
aggdata

library(vcd)
counts <- table(Arthritis$Improved)
counts

counts <- table(Arthritis$Improved, Arthritis$Treatment)
counts
