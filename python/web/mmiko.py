#-*-coding:utf-8-*-


#
#A script to download pictures from mmkio.com.
#
#

import urllib
import HTMLParser
import sys

class MyHTMLParser(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self.readingtitle=0
        self.title=''
        self.imgs=[]
        self.urls=[]
        self.urls.append('http://img.album.pchome.net/54/79/15/02/faa24ecd9bd3e0a105f1aea1e0de34ee.jpg')
        self.urls.append('http://img.album.pchome.net/54/74/03/32/e320256029b534bb7315b8e0bbe63b6d.jpg')
        self.urls.append('http://img.album.pchome.net/54/74/03/32/f7215f8e312a9ab9eee71351a5581cca.jpg')
        self.urls.append('http://img.album.pchome.net/54/74/03/32/02d4f6340750f321c952132a0795ac72.jpg')
        self.urls.append('http://img.album.pchome.net/54/75/67/38/6dec8582c8a3294300828401b7bc3962.jpg')
        self.urls.append('http://img.album.pchome.net/54/74/69/53/9617b138ca1e4b2ce6398e4e65ee1c67.jpg')
        self.urls.append('http://img.album.pchome.net/54/74/34/01/cbc0b23e9c21a604d25f300ec0e293e3.jpg')
        self.urls.append('http://img.album.pchome.net/54/74/34/01/64ad214cf3d49f265c25b572aead3f5d.jpg')
    def handle_starttag(self,tags,attrs):
        if tags=='title':
            self.readingtitle=1
        if tags=='img':
            for attr in attrs:
                for t in attr:
                    if 'jpg' in t and 'uploads' not in t and t not in self.urls:
                        self.imgs.append(t)
                    else:
                        pass
    def get_imgs(self):
        return self.imgs
    def empty_imgs(self):
        self.imgs=[]
    def handle_data(self,data):
        if self.readingtitle:
            self.title+=data
    def handle_endtag(self,tag):
        if tag=='title':
            self.readingtitle=0
    def gettitle(self):
        return self.title

reload(sys)
sys.setdefaultencoding('utf8')



url='http://www.mmiko.com/archives/'
pageNum='1752'
fileNum='1'
path='./mmiko/'

while 1:
    parser=MyHTMLParser()
    urlTemp=url
    url+=pageNum
    page=urllib.urlopen(url)
    url=urlTemp
    
    html=page.read()
    parser.feed(html)
    imgs=parser.get_imgs()

    if '小花' in parser.gettitle() and len(imgs)>0:
        for img in imgs:
            pathTemp=path
            fnum=int(fileNum)
            if fnum>0:
                path+=fileNum+'.jpg'
                data=urllib.urlopen(img).read()
                f=file(path,"wb")
                f.write(data)
                f.close()
                path=pathTemp
            fnum+=1
            fileNum=str(fnum)
    
    parser.empty_imgs()        
    num=int(pageNum)
    num-=1
    if num<1:
        break
    pageNum=str(num)
    
parser.close()
