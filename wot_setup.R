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
test <- str_c(path_to_pdf, "/", files[1])
wot <- lapply(test, pdf_text)
wot <- lapply(files, pdf_text)

dragon_reborn <- wot[[1]]
dragon_reborn_df <- tibble(book = "The Dragon Reborn", page = 1:length(dragon_reborn), text = dragon_reborn)
dragon_reborn_df <- dragon_reborn_df %>% unnest_tokens(word, text)

# remove stop words

data(stop_words)

dragon_reborn_df <- dragon_reborn_df %>% anti_join(stop_words)

afinn <- get_sentiments("afinn")

word_count <- dragon_reborn_df %>% inner_join(afinn) %>% count(word, sort= TRUE)
wordcloud(word_count$word,word_count$n,  max.words = 50) # die - dice? died

dragon_reborn_words <- dragon_reborn_df %>% inner_join(afinn) %>% group_by(word) %>% summarize(value = mean(value))

dragon_reborn_pages <- dragon_reborn_df %>% inner_join(afinn) %>% group_by(page) %>% summarize(value = sum(value))

dragon_reborn_value <- dragon_reborn_df %>% inner_join(afinn) %>% group_by(book) %>% summarize(value = sum(value))

dragon_reborn_mean_value <- dragon_reborn_df %>% inner_join(afinn) %>% group_by(book) %>% summarize(value = mean(value))


ggplot(dragon_reborn_pages, aes(x=page,y=value)) + geom_point()

dr_box <- dragon_reborn_df %>% inner_join(afinn)

ggplot(dr_box, aes(x=book,y=value)) + geom_boxplot()






eotw <- wot[[2]]
eotw_df <- tibble(book = "The Eye Of The World", page = 1:length(eotw), text = eotw)
eotw_df <- eotw_df %>% unnest_tokens(word, text)
eotw_df <- eotw_df %>% anti_join(stop_words)

eotw_df %>% count(word, sort=TRUE)
