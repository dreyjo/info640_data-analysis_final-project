library(dplyr)
library(lubridate)
library(tidyverse)
library(tidytext)
library(tm)
library(stringr)

#loading datasets:
fat19 <- read.csv("Desktop/sp21_da/da_proj/info640_da_final/data/csv/fat19_papers.csv", header=TRUE)
fat20 <- read.csv("Desktop/sp21_da/da_proj/info640_da_final/data/csv/fat20_papers.csv", header=TRUE)
facct21 <- read.csv("Desktop/sp21_da/da_proj/info640_da_final/data/csv/facct21_papers.csv", header=TRUE)

#combining FAT 2019, FAT 2020, FAccT 2021 into one datase using rbind()
#---you can also use bind_rows()
#---the difference being rbind() requires thr 
f <- rbind(fat19,fat20)
papers <- rbind(f,facct21)

#change papers "X" column to "paperID"
names(papers)[names(papers) == "X"] <- "paperID"

#save full dataset to csv 
write.csv(papers,"/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers.csv")



#---Cleaning/Preprocessing
#got rid of new line in python. Using R for rest of cleaning. Will jump back to python for any cleaning I have issues with
papers <-read.csv("Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers_cleaned.csv", header=TRUE, encoding="utf-8", stringsAsFactors=TRUE)
#getting rid of random column, leaivng unamed one for now, we still have paperID for an index
papers <- subset(papers, select=-c(X, Unamed...0))

#Create Corpus, save as an R object

names(papers)[names(papers)=="paperId"] <- "doc_id" 
#apparently $doc_id should be created as a variable first 
papers$doc_id <- NA
papers$doc_id <- as.character(papers$doc_id) 
names(papers)[names(papers)=="abstract"] <- "text" 
colnames(papers)

#removing unneccesary columns
papers <- papers %>% select(-1, -2) 
colnames(papers)

#save full dataset to csv 
write.csv(papers,"/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers_cleaned_trial2.csv")

#----"papers_doc_id" is our Document IDs
#----"papers_text" is the text we will be analysing

#Finalizing corpus and dataframe source 
papers_source <- DataframeSource(papers) 
papers_corpus <- VCorpus(papers_source)

#Cleaning Corpus with tm_map
#remove numbers:
papers_data <- tm_map(papers_corpus, removeNumbers)
#remove punctuation
papers_data <- tm_map(papers_data, removePunctuation)
#lowercase:
papers_data <- tm_map(papers_data, tolower)

#strip whitespace:
papers_data <- tm_map(papers_data, stripWhitespace)

#remove stopwords
stop <- stopwords("en")
papers_data <- tm_map(papers_data, removeWords, stop)
print(papers_data[[10]][1])

#stem - stemmatize words, make a dicitonary of stemmed terms then use stemming compensation

#lem - lemmatize words, make a dictionary of lemmed words 

#strip whitespace:
papers_data <- tm_map(papers_data, stripWhitespace)
