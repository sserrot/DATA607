library(tm)
library(pdftools)
library(here)
library(tidyverse)
library(tidytext)
library(wordcloud)
library(reshape2)
library(ggplot2)

path_to_pdf <- here("GitHub","DATA606","Project","WoT")

files <- list.files(path = path_to_pdf, pattern = "pdf$")

# abstract out to now manually pull each dataframe.
complete_path <- function(x) { str_c(path_to_pdf, "/",x)}
files <- complete_path(files)

# read in all pdfs in the WoT folder
wot <- lapply(files, pdf_text)




cos_book <- wot[[1]]
title <- cos_book[1] %>% str_split("\n")
title <- title[[1]][1]
cos_book_df <- tibble(book = title, page = 1:length(cos_book), text = cos_book)
cos_book_df <- cos_book_df %>% unnest_tokens(word, text)


dragon_reborn <- wot[[2]]
title <- dragon_reborn[1] %>% str_split("\n")
title <- title[[1]][1]
dragon_reborn_df <- tibble(book = title, page = 1:length(dragon_reborn), text = dragon_reborn)
dragon_reborn_df <- dragon_reborn_df %>% unnest_tokens(word, text)
data(stop_words)

testing_function <- function(list) {
  data(stop_words)
  title <- list[1] %>% str_split("\n")
  title <- title[[1]][1]
  pdf_book <- tibble(book = title, page=1:length(list), text = list)
  pdf_book <- pdf_book %>% unnest_tokens(word, text)
  pdf_book <- pdf_book %>% anti_join(stop_words)
}


all_books <- lapply(wot, testing_function)
  
all_books <- all_books %>% reduce(rbind) # bind all dataframes together


# remove stop words
afinn <- get_sentiments("afinn")
all_books <- all_books %>% inner_join(afinn)
word_count <- all_books %>% count(word, sort= TRUE)
wordcloud(word_count$word,word_count$n,  max.words = 20) # die - dice? died

dragon_reborn_words <- all_books %>% inner_join(afinn) %>% group_by(word) %>% summarize(value = mean(value))
dragon_reborn_words <- all_books %>% inner_join(afinn) %>% group_by(book,word) %>% summarize(value = mean(value))
dragon_reborn_pages <- all_books %>% inner_join(afinn) %>% group_by(page) %>% summarize(value = sum(value))
dragon_reborn_value <- all_books %>% inner_join(afinn) %>% group_by(book) %>% summarize(value = sum(value))
dragon_reborn_mean_value <- all_books %>% inner_join(afinn) %>% group_by(book) %>% summarize(value = mean(value))


ggplot(dragon_reborn_pages, aes(x=page,y=value)) + geom_point()



ggplot(all_books, aes(x=book,y=value)) + geom_boxplot()

## NRC
# sentiment analysis

nrc <- get_sentiments("nrc") # emotions


all_books_nrc <- all_books %>% inner_join(nrc)

# remove positive / negative since we already check that using AFINN quantitatively

all_books_nrc <- all_books_nrc %>% filter(!sentiment %in% c("positive","negative"))

all_books_sentiment <- all_books_nrc %>% group_by(book,sentiment) %>% summarize(count = n())

all_books_nrc %>% ggplot(aes(x=book, color = sentiment)) + geom_bar(position = "fill")+ coord_flip()

