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
names(papers)

papers["abstract"][1]
papers["abstract"] <- gsub("[\\n]", "", papers["abstract"])
papers["abstract"][1]

#save full dataset to csv 
write.csv(papers,"/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers.csv")

#***data checkpoint
papers <- read.csv("papers.csv", header=TRUE, encoding="utf-8", stringsAsFactors=TRUE)
#deleting X repeating column 
papers <- subset(papers, select=-c(X))

#papers["paperID"] <- as.numeric(papers["paperID"])
#names(papers)

#Create Corpus, save as an R object
names(papers)[names(papers)=="paperId"] <- "doc_id" 
#apparently $doc_id should be created as a variable first 
papers$doc_id <- NA
papers$doc_id <- as.character(papers$doc_id) 
names(papers)[names(papers)=="abstract"] <- "text" 
colnames(papers)

#"papers_doc_id" is our Document IDs
#"papers_text" is the text we will be analysing

#Finalizing corpus and dataframe source 
papers_source <- DataframeSource(papers) 
papers_corpus <- VCorpus(papers_source)

#Cleaning Corpus with tm_map
#remove numbers:
papers_cleaned <- tm_map(papers_corpus, removeNumbers)
print(papers_cleaned[[10]][1])

#remove punctuation
papers_cleaned <- tm_map(papers_cleaned, removePunctuation)
print(papers_cleaned[[10]][1])



#get rid of new line \n
#papers_cleaned <- tm_map(papers_cleaned, content_transformer(gsub(papers_cleaned, pattern = "\n", replacement = "")))
#papers_cleaned <- content_transformer(gsub("\\r\\n", "", peace_cleaned))
papers_cleaned <- tm_map(papers_cleaned, content_transformer(function(x) gsub('\n', '', peace_cleaned)))
print(papers_cleaned[[10]][1])



#remove parenthesis
#remove --, :, ', "

#lowercase:
papers_cleaned <- tm_map(papers_cleaned, tolower)


#strip whitespace



papers["abstract_cleaned"] <- tolower(papers["abstract"])
#remove punctuation:
papers["abstract_cleaned"] <- removePunctuation(papers["abstract_cleaned"])
#remove whitespace:
papers["abstract_cleaned"] <- stripWhitespace(papers["abstract_cleaned"])




