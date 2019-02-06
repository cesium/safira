#!/usr/bin/python
import sys
import csv
import subprocess

def geraPDF(badge,numero):
    subprocess.call(['mkdir '+'-p '+'pdf'], shell = True)
    subprocess.call(['./heroku.sh '+ badge+' '+ str(int(numero)+1)], shell = True)
    subprocess.call(['./script.sh '+ badge], shell = True)

file = open(sys.argv[1],'r')
reader = csv.reader(file)
for row in reader:
    geraPDF(row[0],row[1])
