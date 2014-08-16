import os
import commands
import MySQLdb
import string
import rrdtool
from xml.etree.ElementTree import ElementTree


#working directory
root="/var/lib/ganglia/rrds/hap"
dirs=os.listdir(root)

#mysql table name limit
map1=string.maketrans('.','_')
map2=string.maketrans('-','_')

conn=MySQLdb.connect(host='localhost', user='root',passwd='123456')
cursor=conn.cursor()

for onedir in dirs:
    dbname=onedir.translate(map1).translate(map2)
    conn.select_db(dbname)

    files=os.listdir(root+"/"+onedir)
    os.chdir(root+"/"+onedir)
    for onefile in files:
        xmlfile=onefile[:-4]+".xml"
        os.system("rrdtool dump "+onefile+">"+xmlfile)
        first=commands.getoutput("rrdtool first swap_free.rrd")
        tablename=onefile[:-4].translate(map1)
        firsttime=int(first) #rows=244 15
        xmltree=ElementTree(file=xmlfile)
        database=xmltree.find('rra/database')
        count=0
        for item in database.findall('row/v'):
            value=item.text.strip()
            if(value=='NaN' or value=='nan'):
               pass
            else:
                invalues=[firsttime+count*15,value]
                cursor.execute("insert into "+tablename+
                               " values(%s,%s)",invalues)
            count+=1            
cursor.close();
