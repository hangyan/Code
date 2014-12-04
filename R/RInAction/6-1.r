library(vcd)
counts <- table(Arthritis$Improved, Arthritis$Treatment)

states <- data.frame(state.region, state.x77)
means <- aggregate(states$Illiteracy, by = list(state.region), FUN = mean)

means <- means[order(means$x),]

attach(Arthritis)
counts <- table(Treatment, Improved)
spine(counts, main = "Spinogram Example")
detach(Arthritis)

