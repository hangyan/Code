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



#Code for Chapter 3 in Zuur, Ieno and Meesters (2009).
#August 2008

#Read the data
setwd("C:/RBook")
Squid <- read.table(file = "squidGSI.txt",
                  header = TRUE)

#What are the variable names?
names(Squid)
#"Sample"   "Year"     "Month"    "Location" "Sex"      "GSI"

str(Squid)

#Wrong way:
setwd("C:/RBook")
Squid2 <- read.table(file = "squidGSI.txt",
                  dec = ",", header = TRUE)
str(Squid2)
boxplot(Squid2$GSI)


mean(GSI, data = Squid)
boxplot(GSI ~ factor(Location), data = Squid)
boxplot(GSI, data = Squid)

Squid$GSI
mean(Squid$GSI)

#####

Squid$Sex
Sel <- Squid$Sex == 1
SquidF <- Squid[Sel, ]

SquidM <- Squid[Squid$Sex == 2, ]

SquidF.OR.1 <- Squid[Squid$Sex == 1 &
                   Squid$Location == 1,]

SquidF <- Squid[Squid$Sex == 1, ]
SquidF1 <- SquidF[Squid$Location == 1, ]
                   
Ord1 <- order(Squid$Month)
Squid[Ord1, ]
Squid

Squid$fLocation <- factor(Squid$Location)
Squid$fSex <- factor(Squid$Sex,labels=c("M","F"))
Squid$fSex

names(Squid)

Squid$fLocation <- factor(Squid$Location,
                    levels = c(2, 3, 1, 4))
Squid$fLocation




setwd("C:/RBook")
Sq1 <- read.table(file = "squid1.txt", header = TRUE)
Sq2 <- read.table(file = "squid2.txt", header = TRUE)
SquidMerged <- merge(Sq1, Sq2, by = "Sample")


SquidMerged <- merge(Sq1, Sq2, by = "Sample", all= TRUE)
SquidMerged[1:14,]

Squid$fSex <- factor(Squid$Sex, labels = c("M", "F"))
Squid$fLocation <- factor(Squid$Location)
str(Squid)

Squid[Squid$Location == 1 & Squid$Year == 1, ]

SquidM <- Squid[Squid$Sex == 1, ]
write.table(SquidM,
     file = "MaleSquid.txt",
     sep=" ", quote = FALSE, append = FALSE, na = "NA")
     
write.table(SquidM,
     file = "MaleSquid.txt",
     sep=",", quote = TRUE, append = FALSE, na = "NA")

write.table(SquidM,
     file = "MaleSquid.txt",
     sep=" ", quote = TRUE, append = TRUE, na = "NA")
     