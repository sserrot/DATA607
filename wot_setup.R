library(tm)
library(pdftools)
library(here)

library(tidyverse)
library(tidytext)
library(wordcloud)
library(reshape2)

path_to_pdf <- here("Data Science", "Data Acquisition and Management", "DATA607","WoT")

files <- list.files(path = path_to_pdf, pattern = "pdf$")
test <- lapply(files, pdf_text)


corp <- Corpus(URISource(files),
               readerControl = list(reader = readPDF))
wot.tdm <- TermDocumentMatrix(corp, 
                                   control = 
                                     list(removePunctuation = TRUE,
                                          stopwords = TRUE,
                                          tolower = TRUE,
                                          stemming = TRUE,
                                          removeNumbers = TRUE,
                                          bounds = list(global = c(3, Inf)))) 
inspect(wot.tdm[1,]) 
