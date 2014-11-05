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



setwd("C:/RBook/")
BFCases <- read.table(file="Birdflucases.txt", header = TRUE,sep="\t")
#BFCases <- read.table(file="Birdflucases.txt", header = TRUE)
                                                                      

names(BFCases)
str(BFCases)


Cases  <- rowSums(BFCases[,2:16])
names(Cases ) <- BFCases[,1]


#Piechart
par(mfrow = c(2,2), mar = c(3, 3, 2, 1))
pie(Cases , main = "Ordinary pie chart")
pie(Cases , col = gray(seq(0.4,1.0,length=6)),
    clockwise=TRUE, main = "Grey colours")
pie(Cases , col = rainbow(6),clockwise = TRUE, main="Rainbow colours")


# 3D Exploded Pie Chart
library(plotrix)
pie3D(Cases , labels = names(Cases ), explode = 0.1,
    main = "3D pie chart", labelcex=0.6)
      
      
op <- par(mfrow = c(2,2), mar = c(3, 3, 2, 1))
pie(Cases , main = "Ordinary pie chart")
pie(Cases , col = gray(seq(0.4,1.0,length=6)),
    clockwise=TRUE, main = "Grey colours")
pie(Cases , col = rainbow(6),clockwise = TRUE,
    main = "Rainbow colours")
pie3D(Cases , labels = names(Cases ), explode = 0.1,
      main = "3D pie chart", labelcex=0.6)
par(op)

      
#Barplots
#BFDeaths <- read.table(file="Birdfludeaths.txt", header = TRUE)
BFDeaths <- read.table(file="Birdfludeaths.txt", header = TRUE, sep="\t")

Deaths <- rowSums(BFDeaths[,2:16])
names(Deaths) <- BFDeaths[,1]
Deaths

Counts <- cbind(Cases, Deaths)
Counts

par(mfrow = c(2,2), mar = c(3, 3, 2, 1))
barplot(Cases , main = "Bird flu cases")
barplot(Counts)
barplot(t(Counts), col = gray(c(0.5,1)))
barplot(t(Counts), beside = TRUE)



#Example 2
setwd("C:/RBook/")
#Benthic <- read.table(file = "RIKZ2.txt", header = TRUE)
Benthic <- read.table(file = "RIKZ2.txt", header = TRUE, sep="\t")

Bent.M <- tapply(Benthic$Richness, INDEX=Benthic$Beach, FUN=mean)
Bent.sd <- tapply(Benthic$Richness, INDEX=Benthic$Beach, FUN=sd)
MSD<- cbind(Bent.M, Bent.sd)

bp <- barplot(Bent.M, xlab = "Beach",
	      ylab = "Richness", col = rainbow(9), ylim = c(0,20))
arrows(bp, Bent.M, bp, Bent.M + Bent.sd, lwd = 1.5,
     angle=90,length=0.1)
box()

Benth.le <- tapply(Benthic$Richness, INDEX=Benthic$Beach, FUN=length)
Bent.se <- Bent.sd / sqrt(Benth.le)

stripchart(Benthic$Richness ~ Benthic$Beach, vert = TRUE,
           pch=1, method = "jitter", jit = 0.05, xlab = "Beach",
   	       ylab = "Richness")
points(1:9,Bent.M, pch = 16, cex = 1.5)


arrows(1:9, Bent.M,
       1:9, Bent.M + Bent.se, lwd = 1.5,
       angle=90, length=0.1)
arrows(1:9, Bent.M,
       1:9, Bent.M - Bent.se, lwd = 1.5,
       angle=90, length=0.1)

    
#Add lines for sd.
#boxplots





setwd("C:/RBook/")

#Owls <- read.table(file = "Owls.txt", header= TRUE)
Owls <- read.table(file = "Owls.txt", header= TRUE, sep="\t")
boxplot(Owls$NegPerChick, main = "Negotiation per chick")

par(mfrow = c(2,2), mar = c(3, 3, 2, 1))
Owls$LogNeg <- log10(Owls$NegPerChick + 1)
boxplot(NegPerChick~SexParent, data = Owls)
boxplot(NegPerChick~FoodTreatment, data = Owls)
boxplot(NegPerChick~SexParent * FoodTreatment,data = Owls)
boxplot(NegPerChick~SexParent * FoodTreatment,
        names = c("F/Dep","M/Dep","F/Sat","M/Dep"),data = Owls)

par(mar = c(2,2,3,3))
boxplot(NegPerChick~Nest, data = Owls, axes = FALSE, ylim = c (-3.5, 9))
axis(2, at = c(0, 2, 4, 6, 8))
text(x = 1:27, y = -2, labels = levels(Owls$Nest),
     cex=0.75, srt=65)

#Boxplot for RIKZ data
setwd("C:/RBook/")
Benthic <- read.table(file = "RIKZ2.txt", header= TRUE, sep="\t")
Bentic.n <- tapply(Benthic$Richness, Benthic$Beach, FUN =length)
Bentic.n

bp <- boxplot(Richness ~ Beach, data = Benthic, col = "grey",
       xlab = "Beach", ylab = "Richness")

bpmid <- bp$stats[2, ] + (bp$stats[4,] - bp$stats[2,]) / 2
text(1:9, bpmid, Bentic.n, col = "white", font = 2)

#Dotplot



setwd("C:/RBook/")
Boar <-read.table("Deer.txt", header = TRUE, sep="\t")

par(mfrow=c(1,2))
dotchart(Boar$LCT, xlab="Length (cm)", ylab = "Observation number")
#dotchart(Boar$LCT, groups = factor(Boar$Sex))
Isna <- is.na(Boar$Sex)
dotchart(Boar$LCT[!Isna], groups = factor(Boar$Sex[!Isna]),
         xlab = "Length (cm)", ylab = "Observation number grouped by sex")

dotchart(Owls$NegPerChick, xlab = "Negotiation per check", ylab = "Order of the data")


setwd("C:/RBook/")
Benthic <- read.table(file = "RIKZ2.txt", header= TRUE,sep="\t")
Benthic$fBeach <- factor(Benthic$Beach)
par(mfrow=c(1,2))
dotchart(Benthic$Richness,groups=Benthic$fBeach,
   xlab="Richness", ylab = "Beach")

Bent.M<-tapply(Benthic$Richness,Benthic$Beach,FUN = mean)

dotchart(Benthic$Richness,groups=Benthic$fBeach,
	       gdata = Bent.M, gpch=19, xlab="Richness", ylab="Beach")

legend("bottomright",c("values","mean"),pch=c(1,19),bg="white")



#plot
setwd("C:/RBook/")
Benthic <- read.table(file = "RIKZ2.txt", header= TRUE,sep="\t")
Benthic$fBeach <- factor(Benthic$Beach)
plot(Benthic$Richness,Benthic$fBeach)

par(mfrow = c(2,2), mar = c(4,4,2,2) +.5)
plot(y = Benthic$Richness, x = Benthic$NAP,
     xlab = "Mean high tide (m)", ylab = "Species richness",
     main = "Benthic data")
M0 <- lm(Richness ~ NAP, data = Benthic)
abline(M0)

plot(y = Benthic$Richness, x = Benthic$NAP,
     xlab = "Mean high tide (m)", ylab = "Species richness",
     xlim = c(-3, 3), ylim = c (0,20))

plot(y = Benthic$Richness, x = Benthic$NAP,
     type = "n", axes = FALSE,
     xlab = "Mean high tide", ylab = "Species richness")
points(y = Benthic$Richness, x = Benthic$NAP)


plot(y = Benthic$Richness, x = Benthic$NAP,
     type = "n", axes = FALSE,
     xlab = "Mean high tide", ylab = "Species richness",
     xlim = c(-1.75,2), ylim = c(0,20))
points(y = Benthic$Richness, x = Benthic$NAP)
axis(2, at = c(0, 10, 20), tcl = 1)
axis(1, at = c(-1.75,0,2), labels = c("Sea","Water line","Dunes") )





setwd("C:/RBook/")
Birds <- read.table(file="loyn.txt", header= TRUE, sep="\t")
Birds$LOGAREA<- log10(Birds$AREA)
Birds$fGRAZE <- factor(Birds$GRAZE)

M0 <- lm(ABUND~ LOGAREA + fGRAZE, data = Birds)
summary(M0)

plot(x = Birds$LOGAREA, y = Birds$ABUND,
     xlab="Log transformed AREA", ylab="Bird abundance")

LAR<-seq(-1, 3, by = 0.1)

ABUND1 <- 15.7 +  7.2 * LAR
ABUND2 <- 16.1 +  7.2 * LAR
ABUND3 <- 15.5 +  7.2 * LAR
ABUND4 <- 14.1 +  7.2 * LAR
ABUND5 <- 3.8 +  7.2 * LAR

lines(LAR, ABUND1, lty = 1, lwd = 1, col =1)
lines(LAR, ABUND2, lty = 2, lwd = 2, col =2)
lines(LAR, ABUND3, lty = 3, lwd = 3, col =3)
lines(LAR, ABUND4, lty = 4, lwd = 4, col =4)
lines(LAR, ABUND5, lty = 5, lwd = 5, col =5)

legend.txt <- c("Graze 1","Graze 2","Graze 3","Graze 4","Graze 5")
legend("topleft",
       legend = legend.txt,
       col = c(1,2,3,4,5),
       lty = c(1,2,3,4,5),
       lwd = c(1,2,3,4,5),
       bty = "o",
       cex = 0.8
       )

title("Fitted model", cex.main = 2, family = "serif", font.main = 1)




setwd("C:/RBook/")
Whales <- read.table(file="TeethNitrogen.txt", header= TRUE)
N.Moby <- Whales$X15N[Whales$Tooth == "Moby"]
Age.Moby <- Whales$Age[Whales$Tooth == "Moby"]
plot(x = Age.Moby, y = N.Moby, xlab = "Age",
     ylab = expression(paste(delta^{15}, "N")))
     



#Spagethi
par(mfrow=c(1,3))
plot(x = Benthic$NAP, y = Benthic$Richness, type = "b",
     xlab="NAP", ylab="Richness")
Iord <- order(Benthic$NAP)
plot(x = Benthic$NAP[Iord], y = Benthic$Richness[Iord], type="b",
     xlab = "NAP", ylab = "Richness")
plot(x = Benthic$NAP[Iord],Benthic$Richness[Iord],
     panel.first=lines(lowess(Benthic$NAP[Iord],
     Benthic$Richness[Iord])),xlab="NAP",
     ylab="Richness")

#Identify
plot(y = Benthic$Richness, x = Benthic$NAP,
     xlab = "Mean high tide (m)", ylab = "Species richness",
     main = "Benthic data")
identify(y = Benthic$Richness, x = Benthic$NAP)




#pairs
setwd("C:/RBook/")
Benthic <- read.table(file = "RIKZ2.txt", header= TRUE)
plot(Benthic[,2:9])

pairs(Benthic[, 2:9])

pairs(Benthic[, 2:9], diag.panel = panel.hist,
upper.panel = panel.smooth, lower.panel = panel.cor)

panel.hist <- function(x, ...)
{
    usr <- par("usr"); on.exit(par(usr))
    par(usr = c(usr[1:2], 0, 1.5) )
    h <- hist(x, plot = FALSE)
    breaks <- h$breaks; nB <- length(breaks)
    y <- h$counts; y <- y/max(y)
    rect(breaks[-nB], 0, breaks[-1], y, col="cyan", ...)
}


panel.cor <- function(x, y, digits=2, prefix="", cex.cor)
{
    usr <- par("usr"); on.exit(par(usr))
    par(usr = c(0, 1, 0, 1))
    r <- abs(cor(x, y))
    txt <- format(c(r, 0.123456789), digits=digits)[1]
    txt <- paste(prefix, txt, sep="")
    if(missing(cex.cor)) cex <- 0.8/strwidth(txt)
    text(0.5, 0.5, txt, cex = cex * r)
}

pairs(Benthic[, 2:9], diag.panel = panel.hist,
      upper.panel = panel.smooth, lower.panel = panel.cor)



#Coplot
setwd("C:/RBook/")
Benthic <- read.table(file = "RIKZ2.txt", header= TRUE, sep="\t")
coplot(Richness ~ NAP | as.factor(Beach), pch=19, data = Benthic)


coplot(Richness ~ NAP | grainsize, pch=19, data = Benthic)

panel.lm = function(x, y, ...) {
  tmp<-lm(y~x,na.action=na.omit)
  abline(tmp, lwd = 2)
  points(x,y, ...)}

coplot(Richness ~ NAP | as.factor(Beach), pch=19,
panel = panel.lm, data=Benthic)


coplot(Richness ~ NAP | as.factor(Beach), pch=19, span =1,
panel = panel.smooth, data=Benthic)


setwd("C:/RBook/")
pHEire<-read.table(file="SDI2003.txt",
                   header=TRUE, sep="\t")

pHEire$LOGAlt <- log10(pHEire$Altitude)
pHEire$fForested <- factor(pHEire$Forested)

coplot(pH ~ SDI | LOGAlt * fForested,
	 panel=panel.lm,data=pHEire)

coplot(pH ~ SDI | LOGAlt * fForested,
	 panel=panel.lm,data=pHEire, number=3)


panel.lm2=function(x,y,col.line="black",lwd=par("lwd"),
	lty=par("lwt"), ...){
	tmp<-lm(y~x,na.action=na.omit)
	points(x,y, ...)
	abline(tmp,col=col.line,lwd=lwd,lty=lty)}


CI <- co.intervals(pHEire$LOGAlt,3)
GV <- list(CI,c(2,1))

pHEire$Temperature
pHEire$Temp2 <- cut(pHEire$Temperature, breaks = 2)
pHEire$Temp2.num <- as.numeric(pHEire$Temp2)
pHEire$Temp2.num

 coplot(pH ~ SDI | LOGAlt * fForested,
	 panel=panel.lm, data=pHEire,
   given.values = GV,
	 cex=1.5,pch=19,
	 col=gray(pHEire$Temp2.num/3))

#light grey (high temp) is light value


MyLayOut <- matrix(c(2,0,1,3), nrow = 2, ncol=2, byrow = TRUE)
MyLayOut

nf <- layout(mat = MyLayOut,widths = c(3, 1),
           heights = c(1, 3), respect = TRUE)

layout.show(nf)

xrange<-c(min(Benthic$NAP),max(Benthic$NAP))
yrange<-c(min(Benthic$Richness),max(Benthic$Richness))

par(mar=c(4,4,2,2))
plot(Benthic$NAP,Benthic$Richness,xlim=xrange,ylim=yrange, xlab = "NAP", ylab="Richness")

par(mar=c(0,3,1,1))
boxplot(Benthic$NAP,horizontal=TRUE,axes=F,
	frame.plot=F,ylim=xrange,space=0)

par(mar=c(3,0,1,1))
boxplot(Benthic$Richness,axes=F,ylim=yrange,space=0,horiz=TRUE)




