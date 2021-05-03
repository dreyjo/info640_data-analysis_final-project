import pandas as pd
import re
import string
import os
import os.path
import csv

file = os.path.join("/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers.csv")
papers = pd.read_csv(file)

#get rid of new line test

papers["abstract"] = papers["abstract"].replace('\\n','', regex=True)

test= papers.to_csv("csv/papers_cleaned_trial1.csv")
test
