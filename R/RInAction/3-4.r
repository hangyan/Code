attach(mtcars)
plot(wt, mpg,
     main = "Mileage vs. Car Weight",
     xlab = "Weight",
     ylab = "Mileage",
     pch = 18,
     col = "blue")

text(wt, mpg,
     row.names(mtcars),
     cex = 0.6,
     pos = 4,
     col = "red")

detach(mtcars)


opar <- par(no.readonly = TRUE)
par(cex = 1.5)
plot(1:7, 1:7, type = "n")
text(3, 3, "Example of default text")
text(4, 4, family = "mono", "Example of mono-spaced text")
text(5, 5, family = "serif", "Example of serif text")
par(opar)

