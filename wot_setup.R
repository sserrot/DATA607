library(tm)
library(pdftools)
library(here)

library(tidyverse)
library(tidytext)
library(wordcloud)
library(reshape2)

path_to_pdf <- here("Data Science", "Data Acquisition and Management", "DATA607","WoT")

files <- list.files(path = path_to_pdf, pattern = "pdf$")
wot <- lapply(files, pdf_text)

dragon_reborn <- wot[[1]]
dragon_reborn_df <- tibble(book = "The Dragon Reborn", page = 1:330, text = dragon_reborn)
dragon_reborn_df <- dragon_reborn_df %>% unnest_tokens(word, text)

# remove stop words

data(stop_words)

dragon_reborn_df <- dragon_reborn_df %>% anti_join(stop_words)

nrc_joy <- get_sentiments("nrc") %>% filter(sentiment == "negative")

dragon_reborn_df %>% inner_join(nrc_joy) %>% count(word, sort= TRUE)


eotw <- wot[[2]]
eotw_df <- tibble(book = "The Eye Of The World", page = 1:length(eotw), text = eotw)
eotw_df <- eotw_df %>% unnest_tokens(word, text)
eotw_df <- eotw_df %>% anti_join(stop_words)

eotw_df %>% count(word, sort=TRUE)
