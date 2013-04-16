#!/usr/bin/env python
#-*-coding:gbk-*-
import urllib
import HTMLParser
import sys

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

        

reload(sys)
sys.setdefaultencoding('gbk')

parser=MyHTMLParser()

basicUrl='http://v.sharein.us/play.php?urlid='
pageNum='180'
filmPath='vsd/'
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
    filmPath+=pageNum+'.mp4'
    try:
        data=urllib.urlopen(src).read()
        f=file(filmPath,"wb")
        filmPath=pathTemp
        f.write(data)
        f.close()
    except:
        filmPath=pathTemp
    num=int(pageNum)
    num+=1
    pageNum=str(num)
page.close()
