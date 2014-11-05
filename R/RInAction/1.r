age <- c(1,3,5,2,11,9,3,9,12,3)
weight <- c(4.4,5.3,7.2,5.2,8.5,7.3,6.0,10.4,10.2,6.1)

mean(weight)
sd(weight)
cor(age,weight)
# plot(age,weight)

lmfit <- lm(mpg ~ wt, data = mtcars)
summary(lmfit)

plot(lmfit)
cook <- cooks.distance(lmfit)
plot(cook)


library(vcd)
Arthritis

example(Arthritis)
