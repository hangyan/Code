#    A Beginner's Guide to R (2009)
#    Zuur, Ieno, Meesters.    Springer
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.



setwd("c:/RBook/")
Parasite <- read.table(file="CodParasite.txt", header = TRUE, dec =",")
names(Parasite)
str(Parasite)

mean(Parasite$Intensity)
boxplot(Parasite$Intensity)

mean(Parasite$Weight)
boxplot(Parasite$Weight)


#Attach section
setwd("c:/RBook/")
Parasite <- read.table(file="CodParasite.txt", header = TRUE)
attach(Parasite)
Prrrarassite


attach(Parasite)
names(Hake)
Length



Parasite <- read.table(file="CodParasite.txt", header = TRUE)
attach(Parasite)
Length
detach(Parasite)
Length
#Do other things
attach(Parasite)



setwd("c:/RBook/")
Parasite <- read.table(file="CodParasite.txt", header = TRUE)
Squid <- read.table(file="Squid.txt", header = TRUE)
names(Parasite)
names(Squid)
attach(Parasite)
attach(Squid)

boxplot(Intensity~Sex)
lm(Intensity~Sex)



#Section 9.2.4
setwd("c:/RBook/")
Parasite <- read.table(file="CodParasite.txt", header = TRUE)
Parasite$fSex <- factor(Parasite$Sex)
Parasite$fSex
attach(Parasite)
fSex
Parasite$fArea <- factor(Parasite$Area)
fLocation




setwd("c:/RBook/")
Parasite <- read.table(file="CodParasite.txt", header = TRUE)

M0 <- lm(Parasite$Intensity ~ Parasite$Length * factor(Parasite$Sex))
library(nlme)
M1 <- gls(Parasite$Intensity ~ Parasite$Length * factor(Parasite$Sex))



setwd("c:/RBook/")
Parasite <- read.table(file="CodParasite.txt", header = TRUE)

Parasite$LIntensity <- log(Parasite$Intensity)
Parasite$L1Intensity <- log(Parasite$Intensity + 1)

boxplot(Parasite$LIntensity, Parasite$L1Intensity,
        names = c("log(Intensity)","log(Intensity+1)"))




M0 <- lm(LIntensity ~ Length * factor(Sex), data=Parasite)


Error in lm.fit(x, y, offset = offset, singular.ok = singular.ok, ...) :
        NA/NaN/Inf in foreign function call (arg 4)
        
        
        
        
        
        
#Section 9.5
x <- seq(1,10)
plot(x,type="l")
plot(x,type="1")


par(mfrow=c(2,1),mar=c(3,3,2,1))
dotchart(Parasite$Depth)
dotchart(Parasite$Depth, col=Parasite$Prevalence, bg=1)
#





Owls <- read.table(file = "C:/RBook/Owls.txt", header= TRUE)
attach(Owls)
ls()
