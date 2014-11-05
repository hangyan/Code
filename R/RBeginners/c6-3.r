setwd("~/Code/R/RBook/")
Veg <- read.table(file = "Vegetation2.txt",
                  header = TRUE)
names(Veg)

NAPerVariale <- function(X1) {
    D1 <- is.na(X1)
    colSums(D1)
}

Parasite <- read.table(file = "CodParasite.txt",
                       header = TRUE)
names(Parasite)

ZerosPerVariable <- function(X1) {
    D1 = (X1 == 0)
    colSums(D1)
}


VariableInfo <- function(X1, Choice1 = "Zeros") {
    if (Choice1 == "Zeros") { D1 = (X1 == 0) }
    if (Choice1 == "NAs") { D1 <- is.na(X1) }
    if (Choice1 != "Zeros" & Choice1 != "NAs") {
        print("You made a typo")
    } else {
        colSums(D1, na.rm = TRUE)
    }
}
