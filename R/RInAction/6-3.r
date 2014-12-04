par(lwd = 2)
library(sm)
attach(mtcars)

cyl.f <- factor(cyl, levels = c(4, 6, 8),
                labels = c("4 c", "6 c", "8 c"))
sm.density.compare(mpg, cyl, xlab = "MPG")
title(main = "MPG HHHH")



