#-*-coding:utf-8-*-
import urllib
import HTMLParser
import sys

class MyHTMLParser(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self.imgs=[]
        
    def handle_starttag(self,tags,attrs):
        if tags=='img':
            for attr in attrs:
                for t in attr:
                    if 'i10' in t:
                        self.imgs.append(t)
                    else:
                        pass
    def get_imgs(self):
        return self.imgs
    def empty_imgs(self):
        self.imgs=[]

reload(sys)
sys.setdefaultencoding('utf8')
parser=MyHTMLParser()

url='http://www.topit.me/item/'
num='3000013'
path='/home/yuyan/downloads/img/'

while 1:
    urlTemp=url
    url+=num
    page=urllib.urlopen(url)
    url=urlTemp
    html=page.read()
    parser.feed(html)
    imgs=parser.get_imgs()
    pathTemp=path
    path+=num+'.jpg'
    if len(imgs)>0:
        data=urllib.urlopen(imgs[0]).read()
        parser.empty_imgs()
        f=file(path,"wb")
        f.write(data)
        f.close()
    path=pathTemp
    numI=int(num)
    numI+=1
    if numI>3000500:
        break
    num=str(numI)
    #zero=(7-len(num))*'0'
    #num=zero+num
page.close()
