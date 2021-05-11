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



#Creating Term-Document Matrix:
#-------------------------
#---following text analysis assignment code:
papers_dtm <- DocumentTermMatrix(papers_data)
print(papers_dtm[[1]])
#---following stackoverflow code which includes stemming and stem completion:
#don't understand this code and need to ask Prof McSweeny about it
#papers_tdm <- TermDocumentMatrix(papers_data, control = list(stemming = TRUE)) 
#use an assigned variable so you can refer to completed
#cbind(stems = rownames(papers_tdm), completed = stemCompletion(rownames(papers_tdm), papers_data))



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

#Analyze how frequently terms appear by summing the content of all terms (i.e., rows).
freq=colSums(as.matrix(papers_dtm_tf))
head(freq,10)

#see 10 most frequent terms:
#question why tail?
tail(sort(freq),n=10)

#plotting top frequent terms:
high.freq=tail(sort(freq),n=10)
hfp.df=as.data.frame(sort(high.freq))
hfp.df$names <- rownames(hfp.df) 

ggplot(hfp.df, aes(reorder(names,high.freq), high.freq)) +
  geom_bar(stat="identity") + coord_flip() + 
  xlab("Terms") + ylab("Frequency") +
  ggtitle("Term frequencies")

#trying to remove most frequent terms from papers dtm
install.packages("udpipe")
library(udpipe)
freq_terms <- c("accountability", "models", "recourse", "systems", "algorithmic", "trust", "data", "explanations", "model", "fairness")

#----------QUESTION FROM HERE:
#why didn't stemming work? or rather how and when do use stemCompletion? before or after DTM?
#why are frequent words I already removed like data and fairness still showing up as most frequent? 
papers_data_frq <- tm_map(papers_data, removeWords, freq_terms)
print(papers_data_frq[[10]][1])
papers_dtm_frq <- DocumentTermMatrix(papers_data)

freq_2<-colSums(as.matrix(papers_dtm_frq))
tail(sort(freq_2),n=10)

#tf-idf doesn't seem to change anything and causes issues
#With advice from Prof.McSweeney:

#-Next way to see if I get different results would be in incorporating stemmed results
#--set the table of stem and stemcompleted to a variable so you can reference a column if need be
#so trial 3 is with a STEMMED papers_dtm not weighted with tf-idf. 

#analysis could begin with understanding:
#- what terms appear in some topics and which don't? If data appears in 2/3 topics why might that be?

#- if terms appear frequently across topics why might that be? Could those terms be used in different ways within those topics?
#--one way to analyze this might be reconnecting topics to paper sources/ids:
#---specifically pulling out which papers are great representations of each topic, looking at these papers to see what they have in common in-topic? 
#---and seeing if these words are being deployed in the same way

#stemming again:
#-----------------------
stem_dtm <- DocumentTermMatrix(papers_data, control = list(stemming = TRUE)) 
stem_terms <-cbind(stems = rownames(stem_dtm), completed = stemCompletion(rownames(stem_dtm), papers_data))
write.csv(stem_terms, "/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/stem_completed_terms.csv")
stem_terms

k3 <- 3
papers_lda_3 <- LDA(stem_dtm, k = k3, control = list(seed=1234)) 
papers_lda_3 
papers_lda_3_terms <- terms(papers_lda_3,5)

#plot LDA 3 where k=3
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

#----------------------------

k4 <- 10
papers_lda_4 <- LDA(stem_dtm, k = k4, control = list(seed=1234)) 
papers_lda_4 
papers_lda_4_terms <- terms(papers_lda_4,10)

#plot lda 4 where k=10
papers_lda_4_topics <-as.matrix(papers_lda_4_terms) 
head(papers_lda_4_topics) 
write.csv(papers_lda_4_topics,"/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers_lda_trial4.csv")

tidy_papers_lda_4 <- tidy(papers_lda_4)
top_terms_lda_4 <- tidy_papers_lda_4 %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

top_terms_lda_4 %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill=factor(topic))) + geom_col(show.legend=FALSE) + facet_wrap(~ topic, scales = "free")+ coord_flip()

#testing looking at topicProbabilities
topicProbabilities <- as.data.frame(papers_lda_3@gamma)
topicProbabilities
#---LDAviz
install.packages("LDAvis")
library(LDAvis)
help(createJSON, package = "LDAvis")



#------Seeing Example Paper of topics---------------
#probabilities where k=3
topicProbabilities <- as.data.frame(papers_lda_3@gamma)
topicProbabilities

papers_meta <-cbind(papers = papers["title"], id = papers["paperID"])
papers_meta

term_title_probabilities <- cbind(papers_meta,t = topicProbabilities)
ttp <- term_title_probabilities
#writing dataframe with titles and topic probabilities where k=3 to csv I can work on python
write.csv(term_title_probabilities, "/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/topic_paper_probabilities_k3.csv")

#probabilities where K=10
p10 <- as.data.frame(papers_lda_4@gamma)
p10 

ttp10 <- cbind(papers_meta, topic = p10)

  
write.csv(ttp10, "/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/topic_paper_probabilities_k4.csv")
#probabilities where K 
  
#--------------Topic Model where k=20  
k5 <- 20
papers_lda_5 <- LDA(stem_dtm, k = k5, control = list(seed=1234)) 
papers_lda_5 
papers_lda_terms_k20 <- terms(papers_lda_5,5)
write.csv(papers_lda_5, "/Users/aster/Desktop/sp21_da/da_proj/info640_da_final/data/csv/papers_lda_trial5.csv")


#--------------Visualizing Topics:
#installing LDAvis
install.packages("LDAvis")
library(LDAvis)

help(createJSON, package = "LDAvis")
#Where K = 3
#Where K = 10
#Where K = 20
#-----Topic Coherence:
num_k = c(3,6,10,20,40,60)



#---making an LDA model where k=20


#tidy_papers_lda_5 <- tidy(papers_lda_5)
#top_terms_lda_5 <- tidy_papers_lda_5 %>% 
  #group_by(topic) %>% 
  #top_n(5, beta) %>% 
  #ungroup() %>% 
  #arrange(topic, -beta)

#top_terms_lda_5 %>% 
 # mutate(term = reorder(term, beta)) %>% 
  #ggplot(aes(term, beta, fill=factor(topic))) + geom_col(show.legend=FALSE) + facet_wrap(~ topic, scales = "free")+ coord_flip()

#---plot coherence where k=20

