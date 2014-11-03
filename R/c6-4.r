Benthic <- read.table("~/Code/R/RBook/RIKZ.txt",
                      header = TRUE)
Species <- Benthic[,2:76]
n <- dim(Species)

TA <- vector(length = n[1])
for (i in 1:n[1]) {
    TA[i] <- sum(Species[i,], na.rm = TRUE)
}

RS <- rowSums(Species, na.rm = TRUE)
prop <- Species / RS
H <- -rowSums(prop * log10(prop), na.rm = TRUE)

library(vegan)
H <- diversity(Species)

Index.function <- function(Spec, Choice1) {
    if (Choice1 == "Richness") {
        Index <- rowSums(Spec > 0, na.rm = TRUE)
    }
    if (Choice1 == "Total Abundance") {
        Index <- rowSums(Spec, na.rm = TRUE)
    }
    if (Choice1 == "Shanon") {
        RS <- rowSums(Spec, na.rm = TRUE)
        prop <- Spec / RS
        Index <- -rowSums(prop * log10(prop),
                          na.rm = TRUE)
    }

    list(Index = Index, MyChoice = Choice1)
}
