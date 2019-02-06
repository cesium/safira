#!/usr/bin/python
import sys
import csv
import subprocess

def geraPDF(email,badge):
    subprocess.call(['./heroku.sh '+ email +' '+ badge ], shell=True)

file = open(sys.argv[1],'r')
reader = csv.reader(file)
for row in reader:
    geraPDF(row[0], str(int(sys.argv[2])))
