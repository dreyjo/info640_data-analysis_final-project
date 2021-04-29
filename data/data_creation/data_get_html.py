#Grabbing HTML Files and saving them.
import pandas as pd
#requests allows us to get htnml pages from ACM
import requests
#then beautoful soup will help us parse the requested html information and
from bs4 import BeautifulSoup

#import regex
import re
from re import search

#import time for delay between steps
import time

#Pulling in Data for FAT 2019 & 2020 proceedings:

#ACM Proceedings Link:
#fat19 = "https://dl.acm.org/doi/proceedings/10.1145/3287560"
#fat20 = "https://dl.acm.org/doi/proceedings/10.1145/3351095"
fat21 = "https://dl.acm.org/doi/proceedings/10.1145/3442188?id=31"

# r19 = requests.get(fat19)
# r20 = requests.get(fat20)
r21 = requests.get(fat21)
#soup = BeautifulSoup(r.text,'html.parser')

#checking server access status for FAT 19' proceedings page
# if r19.status_code == 200:
#     print("FAT 19 Sever Access is a go!")
# else:
#     print("There is a problem with accessing FAT19")
#     print(r19.status_code)
#
# #checking server access status for FAT 19' proceedings page
# if r20.status_code == 200:
#     print("FAT 20 Sever Access is a go!")
# else:
#     print("There is a problem with accessing FAT20")
#     print(r19.status_code)
#
# time.sleep(5)
#
# #writing fat 19 search page to a text document
# with open('fat19_proceeds.txt', 'w') as f19:
#     f19.write(r19.text)
#
# time.sleep(5)
#
# #writing fat 20 search page to a text document
# with open('fat20_proceeds.txt', 'w') as f20:
#     f20.write(r20.text)

#collecting FAccT21 papers:
#checking server status:
if r21.status_code == 200:
    print("FAccT 21' Sever Access is a go!")
    time.sleep(5)
    with open('facct21_proceeds.txt', 'w') as f21:
        f21.write(r21.text)
else:
    print("There is a problem with accessing FAccT 21' proceedings")
    print(r21.status_code)

#writing FAccT21 search page to a text document
# with open('facct21_proceeds.txt', 'w') as f21:
#     f21.write(r21.text)
#
# time.sleep(5)
