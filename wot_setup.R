library(tm)
library(pdftools)

files <- list.files(pattern = "pdf$")
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
