#data_creation
import pandas as pd
#requests allows us to get htnml pages from ACM
import requests
#then beautoful soup will help us parse the requested html information and
from bs4 import BeautifulSoup

#import regex
import re
from re import search

import time

#f19 = 'fat19_proceeds.txt'
#f20 = 'fat20_proceeds.txt'
f21 = 'facct21_proceeds.txt'

#r19 = requests.get(f19)
#r20 = requests.get(f20)
#r21 = requests.get(f21)

#soup19 = BeautifulSoup(open(f19).read(),'html.parser')
# soup20 = BeautifulSoup(open(f20).read(),'html.parser')
soup21 = BeautifulSoup(open(f21).read(),'html.parser')

#FAT 19 Proceedings - Get Data:

#Step1: Get DOIs and put in an empty dictionary
doi=[]
#making a variable to hold the paper url as a substring
substring = 'https://doi.org'
links = soup21.find_all('a', href=True)
for a in links:
    if re.search(substring,a['href']):
        #append acm url to DOIs, now we have URLs for every paper in proceedings
        doi.append(a['href'])

#print(doi)

#Step 2: Get titles
def get_titles(list):
    #create empty list to hold titles
     t = []
     #for each item in passed list, where x is individual URLs and list is a passed list of URLs
     for x in list:
         #request the html page for each item in passed list
         r=requests.get(x)
         #use bs to parse html
         soup = BeautifulSoup(r.text,'html.parser')
         #find the h1 tag which we know is how the paper title is tagged and get the tag text
         ttl=soup.find_all('h1', class_="citation__title")
         for w in ttl:
             l = w.get_text()
         #add the grabbed title to our empty list
         t.append(l)
         #delay 3 seconds and do it again.
         time.sleep(3)
     return t

tl=get_titles(doi)

#--------

#Step 3: Get abstracts
def get_abstracts(list):
    a = []
    for x in list:
        r=requests.get(x)
        soup = BeautifulSoup(r.text,'html.parser')
        abs=soup.find_all('div', class_="abstractSection abstractInFull")
        for w in abs:
            l = w.get_text()
        a.append(l)
        time.sleep(3)
    return a

ab=get_abstracts(doi)

#--------

#Step 4: Get authors
#still need to figure out

#--------

#Step 5: Get references
# rf = []
# refs=soup.find_all('span', class_="references__note")
#  for c in refs:
#      print(c.get_text())

# def get_refs(list):
#     rf = []
#     for x in list:
#         r=requests.get(x)
#         soup = BeautifulSoup(r.text,'html.parser')
#         refs=soup.find('span', class_="references__note")
#         for i in refs:
#             o=i.text
#
#         rf.append(o)
# #        rf.append(o)
#         time.sleep(5)
#     return rf
#
# print(get_refs(doi))


#Step 6: Create Dataframe:
data = list(zip(tl,ab))
df = pd.DataFrame(data, columns=['title', 'abstract'])
df['date_published'] = 'March 2021'
df.to_csv("facct20_papers.csv")


#FAT 20 Proceedings - Get Data:
