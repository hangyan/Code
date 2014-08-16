import os
import MySQLdb
import string

root="/var/lib/ganglia/rrds/hap"
dirs=os.listdir(root)

map1=string.maketrans('.','_')
map2=string.maketrans('-','_')

conn=MySQLdb.connect(host='localhost', user='root',passwd='123456')
cursor=conn.cursor()

for onedir in dirs:
    onedirname=onedir.translate(map1).translate(map2)
    cursor.execute("create database if not exists "+onedirname)
    conn.select_db(onedirname)
    print onedirname

    files=os.listdir(root+"/"+onedir)
    for onefile in files:
        onefile=onefile[:-4].translate(map1)
        cursor.execute("CREATE TABLE "+onefile+"(time_id int,value varchar(30))")
    
cursor.close();
