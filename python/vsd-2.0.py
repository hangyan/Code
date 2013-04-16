#!/usr/bin/env python
#-*-coding:gbk-*-
import urllib
import HTMLParser
import sys
from PySide import QtCore,QtGui

class MyHTMLParser(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self.filmSrc=''
        
    def handle_starttag(self,tags,attrs):
        if tags=='param':
            for attr in attrs:
                for t in attr:
                    if 'mp4' in t:
                        self.filmSrc=t
                    else:
                        pass
    def getFilmSrc(self):
        return self.filmSrc

class MyWindow(QtGui.QMainWindow):
    def __init__(self):
        QtGui.QMainWindow.__init__(self)
        self.setWindowTitle('Rapid Download')
        self.resize(300,200)
        label=QtGui.QLabel(
        

reload(sys)
sys.setdefaultencoding('gbk')

parser=MyHTMLParser()

basicUrl='http://v.sharein.us/play.php?urlid='
pageNum='1'
filmPath='/home/yuyan/downloads/film/'
while 1:
    urlTemp=basicUrl
    basicUrl+=pageNum
    page=urllib.urlopen(basicUrl)
    basicUrl=urlTemp

    html=page.read()
    parser.feed(html)

    filmSrcGot=parser.getFilmSrc()
    filmSrcList=filmSrcGot.split('&')
    filmsrc=filmSrcList[0]
    src=filmsrc[5:]

    pathTemp=filmPath
    filmPath+=num+'.mp4'
    data=urllib.urlopen(src).read()
    f=file(filmPath,"wb")
    filmPath=pathTemp
    f.write(data)
    f.close()

    numI=int(num)
    numI+=1
    if numI>100:
        break
    num=str(numI)
page.close()
