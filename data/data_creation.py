import pandas as pd
#requests allows us to get htnml pages from ACM
import requests
#then beautoful soup will help us parse the requested html information and
from bs4 import BeautifulSoup

#import regex
import re
from re import search

#Pulling in Data for FAT 2019 proceedings:

#ACM Proceedings Link:
fat19 = "https://dl.acm.org/doi/proceedings/10.1145/3287560"
#fat20 = "https://dl.acm.org/doi/proceedings/10.1145/3351095"

#****Prior Work Ignore!*****
#requsts variables hold links
#req19 = requests.get(fat19)
#req20 = requests.get(fat20)

#first i'd like to do a test of a specific web page. To make sure we can even scrape from acm and give us practice with scraping in general.
# test = "https://dl.acm.org/doi/10.1145/3287560.3287562"
# #print(url)
#
# r = requests.get(test)
# if r.status_code == 200:
#     print("Server access is good!")
#
# #print(r.text)
#
#soup = BeautifulSoup(r.text,'html.parser')
# #print(soup.prettify())
#
# #For scraping individual title on the paper url
# ttl=soup.find('h1').get_text()

#For scraping individual authors paper page
#auth=soup.find_all('span', class_="loa__author-name")
#for a in auth:
#     #print([a.get_text])
#     print([soup.find('span').get_text])

#For scraping individual abstracts in paper page
# abs=soup.find(class_='abstractSection abstractInFull').get_text()
# #abs=soup.find_all()




#-------------------------------
#Scraping from Proceedings page:
#-------------------------------

#Step1: use requests to get the url with the search and check server status
r = requests.get(fat19)
soup = BeautifulSoup(r.text,'html.parser')

if r.status_code == 200:
    print("Sever Access is a go!")


#Step2: Get DOIs and put in an empty dictionary
doi=[]
#making a variable to hold the paper url as a substring
substring = 'https://doi.org'
links = soup.find_all('a', href=True)
#for u in url:
for a in links:
    if re.search(substring,a['href']):
            #print(a['href'])
            #Step4: append acm url to DOIs, now we have URLs for every paper in proceedings
        doi.append(a['href'])

#Now doi holds a list of urls for all the papers we want/

#Step3: Writing function to get titles
def get_titles(list):
    t = []
    for x in list:
        #Here r and soup are local variables, so what assign them is only valid within the function!
        r=requests.get(x)
        soup = BeautifulSoup(r.text,'html.parser')
        ttl=soup.find('h1').get_text()
        t.append(ttl)
    return t

#testing to see if titles works
#IT WORKS!
tl=get_titles(doi)
#print(t)

#Step4: Writing function to get abstracts
def get_abstracts(list):
    a = []
    for x in list:
        r=requests.get(x)
        soup = BeautifulSoup(r.text,'html.parser')
        abs=soup.find(class_='abstractSection abstractInFull').get_text()
        a.append(abs)
    return a

ab=get_abstracts(doi)
#print(a)


#Step5: Writing function to get writers
# def get_authors(list):
#     wr = []
#     for x in list:
#         r=requests.get(x)
#         soup = BeautifulSoup(r.text,'html.parser')
#         auth=soup.find('span', class_="loa__author-name")
#             for a in auth:
#                 writers=soup.find('span').get_text()
#                 wr.append(writers)
#     return wr
#
# w=get_authors(doi)
# #print(w)

#Step6: Writing function to get references
rf = []

#Step6: Create dataframe using pandas and save as csv
data = list(zip(tl,ab))
df = pd.DataFrame(data, columns=['title', 'abstract'])
df.to_csv("data_creation.csv")







#print(url)

#append them to https://dl.acm.org/ to get the url
#store them as urls


    #get authors:
    #auth=soup.find_all('span', class_="loa__author-name")
    # for a in auth:
    #     #print([a.get_text])
    #     print([soup.find('span').get_text])
    # #print(auth)
