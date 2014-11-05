y <- matrix(1:20, nrow = 5, ncol = 4)
cells <- c(1,26,24,68)
rnames <- c("R1", "R2")
cnames <- c("C1", "C2")
mymatrix <- matrix(cells, nrow = 2, ncol = 2,
                   byrow = TRUE, dimnames = list(rnames, cnames))
mymatrix

dim1 <- c("A1", "A2")
dim2 <- c("B1", "B2", "B3")
dim3 <- c("C1", "C2", "C3", "C4")
z <- array(1:24, c(2, 3, 4), dimnames = list(dim1,dim2,dim3))
z

patientID <- c(1, 2, 3, 4)
age <- c(25, 34, 28, 52)
diabetes <- c("Type1", "Type2", "Type1", "Type1")
status <- c("Poor", "Improved", "Excellent", "Poor")

diabetes <- factor(diabetes)
status <- factor(status, order = TRUE)
patientdata <-  data.frame(patientID, age, diabetes, status)

str(patientdata)
summary(patientdata)

patientdata$gender <- factor(patientdata$gender,
                             levels = c(1, 2),
                             labels = c("male", "female"))
