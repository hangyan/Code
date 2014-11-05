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


ISIT<-read.table("ISIT.txt",header=TRUE)
library(lattice)
xyplot(Sources~SampleDepth|factor(Station),data=ISIT,
xlab="Sample Depth",ylab="Sources",
strip=function(bg='white', ...)
strip.default(bg='white', ...),
panel = function(x, y) {
panel.grid(h=-1, v= 2)
I1<-order(x)
llines(x[I1], y[I1],col=1)})




#Read the data

setwd("C:/RBook/")
ISIT<-read.table("ISIT.txt",header=TRUE)
library(lattice) #Load the library for lattice plots
#
#Start the actual plotting
#Plot Sources as a function of SampleDepth, and use a
#panel for data of each cruise.
#Use the colour black (col=1), and specify x and y
#labels (xlab and ylab).
#Use white background in the boxes that contain
#the labels for cruise
xyplot(Sources~SampleDepth|factor(Station), data = ISIT,
  xlab="Sample Depth",ylab="Sources",
  strip=function(bg='white', ...)
  strip.default(bg='white', ...),
  panel = function(x, y) {
      #Add grid lines
      #Avoid spaghetti plots
      #plot the data as lines (in the colour black)
        panel.grid(h=-1, v= 2)
        I1<-order(x)
        llines(x[I1], y[I1],col=1)})
        
        
ISIT <- read.table("C://Bookdata/ISIT.txt", header = TRUE)
library(lattice) #Load the lattice package
#
#Start the actual plotting
#Plot Sources as a function of SampleDepth, and use a
#panel for data of each cruise.
#Use the colour black (col=1), and specify x and y
#labels (xlab and ylab).
#Use white background in the boxes that contain
#the labels for station
xyplot(Sources ~ SampleDepth | factor(Station),
  data = ISIT,
  xlab = "Sample Depth", ylab = "Sources",
  strip = function(bg = 'white', ...)
  strip.default(bg = 'white', ...),
  panel = function(x, y) {
      #Add grid lines
      #Avoid spaghetti plots
      #plot the data as lines (in the colour black)
        panel.grid(h = -1, v = 2)
        I1 <- order(x)
        llines(x[I1], y[I1], col = 1)})
        

setwd("C:/RBook/")
Data<-read.table("Antarcticbirds.txt",header=T)
attach(Data)
library(rgdal)
library(pixmap)
penguin2 <- read.pnm("penguin5.ppm")
plot(Year,LayingEP,type="n",xlab="Year",ylab="Laying day")
addlogo(penguin2, c(1950,2005), c(38,52))
lines(Year,LayingEP,lwd=4,col="white")

                    


setwd("C:/RBook/")
ISIT<-read.table("ISIT.txt",header=TRUE)

xyplot(Sources ~ SampleDepth | factor(Station),
  data = ISIT,
  xlab = "Sample Depth", ylab = "Sources",
  strip = function(bg = 'white', ...)
  strip.default(bg = 'white', ...),
  panel = function(x, y) {
      #Add grid lines
      #Avoid spaghetti plots
      #plot the data as lines (in the colour black)
        panel.grid(h = -1, v = 2)
        I1 <- order(x)
        llines(x[I1], y[I1], col = 1)})


