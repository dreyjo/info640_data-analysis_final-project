library(dplyr)
library(lubridate)
library(tidyverse)
library(tidytext)
library(tm)
library(stringr)
install.packages("textreg")
install.packages("quanteda")
install.packages("qdap")
library(textreg)
library(quanteda)

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
papers <-read.csv("Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers_cleaned_trial1.csv", header=TRUE, encoding="utf-8", stringsAsFactors=TRUE)
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
papers_data <- tm_map(papers_data, content_transformer(tolower))
#remove stopwords
stop <- stopwords("en")
papers_data <- tm_map(papers_data, removeWords, stop)
#strip whitespace:
papers_data <- tm_map(papers_data, stripWhitespace)
print(papers_data[[10]][1]) 

#Spent way too long trying to figure out stemming in R. Just going to block off this code
#Questions should I/ can I stem before making TDM? Or do I have to do this all in one move. 
#moving on to tdm code from text analysis assignment and from stackoverflow: https://stackoverflow.com/questions/30321770/r-warning-in-stemcompletion-and-error-in-termdocumentmatrix
#-----------------------
#stem - stem corpus, make a dicitonary of stemmed terms then use stemming completion
#stemmed_data <- tm_map(papers_data, stemDocument, language = "english")

#dict <- convert.tm.to.character(papers_data)
#data <- as.character(papers_data)
#dict = unnest_tokens(papers_data)

#dict <- papers_corpus
#x <-as.character(stemmed_data)
#stemmed_data <- stemCompletion(x, dict)

#print(stemmed_data[[10]][1])

#lem - lemmatize words, make a dictionary of lemmed words 
#-----------------------

#Creating Term-Document Matrix:
#-------------------------
#---following text analysis assignment code:
papers_dtm <- DocumentTermMatrix(papers_data)
print(papers_dtm[[1]])
#---following stackoverflow code which includes stemming and stem completion:
#don't understand this code and need to ask Prof McSweeny about it
papers_tdm <- TermDocumentMatrix(papers_data, control = list(stemming = TRUE)) 
cbind(stems = rownames(papers_tdm), completed = stemCompletion(rownames(papers_tdm), papers_data))

#checking data type and class type
typeof(papers_data)
class(papers_data)
all_term <- list(colnames(papers_dtm))

#Topic Modeling
#-------------------------
#---LDA
#making sure only unique indexes are being used
#Questions: In a DTM would this mean not selecting papers that had null completely null values? Like in a sparse matrix the document would be 0 all the way across?
unique_indexes <- unique(papers_dtm$i) 
papers_dtm <- papers_dtm[unique_indexes,] 
papers_dtm

#tidying 
tidy_papers_dtm <- tidy(papers_dtm)
tidy_papers_dtm

#fitting LDA:
#first trial choosing k=3 
#theoretical basis is based on definitely expecting: algorithmic formalism and social science informed and then unknown
k1 <- 3
papers_lda_1 <- LDA(papers_dtm, k = k1, control = list(seed=1234)) 
papers_lda_1 
papers_lda_1_terms <- terms(papers_lda_1,5)

papers_lda_1_topics <-as.matrix(papers_lda_1_terms) 
head(papers_lda_1_topics) 
write.csv(papers_lda_1_topics,"/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers_lda_trial1.csv")

#second trial k=6
k2 <- 6
papers_lda_2 <- LDA(papers_dtm, k = k2, control = list(seed=1234)) 
papers_lda_2 
papers_lda_2_terms <- terms(papers_lda_1,5)

papers_lda_2_topics <-as.matrix(papers_lda_2_terms) 
head(papers_lda_2_topics) 
write.csv(papers_lda_2_topics,"/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers_lda_trial2.csv")

#---EDA for LDA trials
tidy_papers_lda_1 <- tidy(papers_lda_1) 
top_terms_lda_1 <- tidy_papers_lda_1 %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

top_terms_lda_1

top_terms_lda_1 %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill=factor(topic))) + geom_col(show.legend=FALSE) + facet_wrap(~ topic, scales = "free")+ coord_flip()

tidy_papers_lda_2 <- tidy(papers_lda_2)
top_terms_lda_2 <- tidy_papers_lda_2 %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

top_terms_lda_2 %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill=factor(topic))) + geom_col(show.legend=FALSE) + facet_wrap(~ topic, scales = "free")+ coord_flip()


#---TF-IDF
#--following this r notebook: https://rstudio-pubs-static.s3.amazonaws.com/118341_dacd8e7a963745eeacf25f96da52770e.html
#now a trial with tf-idf
papers_dtm_tf <- DocumentTermMatrix(papers_data, control = list(weighting = weightTfIdf))
papers_dtm_tf

#Analyse how frequently terms appear by summing the content of all terms (i.e., rows).
freq=colSums(as.matrix(papers_dtm_tf))
head(freq,10)

#see 10 most frequent terms:
#question why tail?
tail(sort(freq),n=10)

k3 <- 3
papers_lda_3 <- LDA(papers_dtm_tf, k = k3, control = list(seed=1234)) 
papers_lda_3 
papers_lda_3_terms <- terms(papers_lda_3,5)

papers_lda_3_topics <-as.matrix(papers_lda_3_terms) 
head(papers_lda_3_topics) 
write.csv(papers_lda_3_topics,"/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers_lda_trial3.csv")

tidy_papers_lda_3 <- tidy(papers_lda_3)
top_terms_lda_3 <- tidy_papers_lda_3 %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

top_terms_lda_3 %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill=factor(topic))) + geom_col(show.legend=FALSE) + facet_wrap(~ topic, scales = "free")+ coord_flip()


#---LDAviz


