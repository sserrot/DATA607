---
title: "Working with XML and JSON in R"
author: "Santiago Torres"
date: "10/10/2021"
output: 
  rmdformats::robobook:
    keep_md: true
---



# Overview

This assignment was to get familiar with manipulating a variety of different data types: xml, html, and json.

I put together a list of three books that I enjoy in the fantasy genre in simple files:

  + A Memory of Light
  + King of Thorns
  + Lord Loss

# Libraries

  + Tidyverse for data manipulation and piping data
  + rvest for reading the html file
  + XML and xml2 for reading the XML file and creating a dataframe from XML
  + jsonlite for reading JSON


# Loading Data

I uploaded all the files I created up to my GitHub:


```r
html_library_url <- "https://raw.githubusercontent.com/sserrot/DATA607/main/Homework/Working_with_XML_and_JSON_in_R/books.html"
xml_library_url <- "https://raw.githubusercontent.com/sserrot/DATA607/main/Homework/Working_with_XML_and_JSON_in_R/books.xml"
json_library_url <- "https://raw.githubusercontent.com/sserrot/DATA607/main/Homework/Working_with_XML_and_JSON_in_R/books.json"
```


## HTML

Rvest has a very simple and straightforward way to directly select a table element in html using `html_elements`:


```r
html_library_df <- read_html(html_library_url)
html_library_df %>% html_elements("table")
```

```
## {xml_nodeset (1)}
## [1] <table>\n<tr>\n<th>Title</th>\n    <th>Author(s)</th>\n    <th>Genre</th> ...
```

and a convenient way to create a tibble out of it using `html_table()`



```r
html_library_df <- html_library_df %>% html_elements("table") %>% html_table()
html_library_df
```

```
## [[1]]
## # A tibble: 3 x 4
##   Title             `Author(s)`                      Genre   `Goodreads Rating`
##   <chr>             <chr>                            <chr>                <dbl>
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy               4.5 
## 2 King of Thorns    Mark Lawrence                    Fantasy               4.19
## 3 Lord Loss         Darren Shan                      Fantasy               4.23
```


## XML


We can preview the XML using XML parse. 

```r
xmlData <- read_xml(xml_library_url)
xmlParse(xmlData)
```

```
## <?xml version="1.0" encoding="UTF-8"?>
## <LIBRARY>
##   <BOOK>
##     <TITLE>A Memory of Light</TITLE>
##     <AUTHORS>Robert Jordan, Brandon Sanderson</AUTHORS>
##     <GENRE>Fantasy</GENRE>
##     <GOODREADS_RATING>4.50</GOODREADS_RATING>
##   </BOOK>
##   <BOOK>
##     <TITLE>King of Thorns</TITLE>
##     <AUTHORS>Mark Lawrence</AUTHORS>
##     <GENRE>Fantasy</GENRE>
##     <GOODREADS_RATING>4.19</GOODREADS_RATING>
##   </BOOK>
##   <BOOK>
##     <TITLE>Lord Loss</TITLE>
##     <AUTHORS>Darren Shan</AUTHORS>
##     <GENRE>Fantasy</GENRE>
##     <GOODREADS_RATING>4.23</GOODREADS_RATING>
##   </BOOK>
## </LIBRARY>
## 
```


The XML package has a `xmlToDataFrame` function that can directly create dataframes from a straightforward xml file. Let's see if it works:


```r
xml_library_df <- xmlData %>% xmlParse() %>% xmlToDataFrame()
xml_library_df
```

```
##               TITLE                          AUTHORS   GENRE GOODREADS_RATING
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy             4.50
## 2    King of Thorns                    Mark Lawrence Fantasy             4.19
## 3         Lord Loss                      Darren Shan Fantasy             4.23
```




```r
#xml_library_df <- tibble(xml_library_df)
```


## JSON


`fromJSON` creates a list but we'll do some manipulation later to make the dataframe equivalent


```r
json_library_df <- fromJSON(json_library_url)
json_library_df
```

```
## $library
##               title                          authors   genre rating
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy   4.50
## 2    King of Thorns                    Mark Lawrence Fantasy   4.19
## 3         Lord Loss                      Darren Shan Fantasy   4.23
```

```r
class(json_library_df)
```

```
## [1] "list"
```



# Comparison & Observations

Now we have three dataframe like set of books created from our different sources we can compare.


```r
class(html_library_df)
```

```
## [1] "list"
```

```r
class(xml_library_df)
```

```
## [1] "data.frame"
```

```r
class(json_library_df)
```

```
## [1] "list"
```

## HTML Library


```r
html_library_df
```

```
## [[1]]
## # A tibble: 3 x 4
##   Title             `Author(s)`                      Genre   `Goodreads Rating`
##   <chr>             <chr>                            <chr>                <dbl>
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy               4.5 
## 2 King of Thorns    Mark Lawrence                    Fantasy               4.19
## 3 Lord Loss         Darren Shan                      Fantasy               4.23
```
  
  Our HTML source becomes a list that holds a tibble with our information. The title itself is in quotations because the source has parentheses in it `Author(s)`. Multiple authors are also stored as characters

```r
html_library_df[[1]]$`Author(s)`
```

```
## [1] "Robert Jordan, Brandon Sanderson" "Mark Lawrence"                   
## [3] "Darren Shan"
```

```r
class(html_library_df[[1]]$`Author(s)`)
```

```
## [1] "character"
```

We can access the list and then rename the authors column


```r
html_library_df <- html_library_df[[1]]

html_library_df <- html_library_df %>% rename (Authors = `Author(s)`)
html_library_df
```

```
## # A tibble: 3 x 4
##   Title             Authors                          Genre   `Goodreads Rating`
##   <chr>             <chr>                            <chr>                <dbl>
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy               4.5 
## 2 King of Thorns    Mark Lawrence                    Fantasy               4.19
## 3 Lord Loss         Darren Shan                      Fantasy               4.23
```

## XML Library

The XML basically requires no real manipulation to have it consistent with the other sources. Looks like the AUTHORS column is also stored as `chr` We could apply `tibble()` just to keep it in the same technical format:


```r
xml_library_df
```

```
##               TITLE                          AUTHORS   GENRE GOODREADS_RATING
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy             4.50
## 2    King of Thorns                    Mark Lawrence Fantasy             4.19
## 3         Lord Loss                      Darren Shan Fantasy             4.23
```

```r
xml_library_df <- xml_library_df %>% tibble()

xml_library_df
```

```
## # A tibble: 3 x 4
##   TITLE             AUTHORS                          GENRE   GOODREADS_RATING
##   <chr>             <chr>                            <chr>   <chr>           
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy 4.50            
## 2 King of Thorns    Mark Lawrence                    Fantasy 4.19            
## 3 Lord Loss         Darren Shan                      Fantasy 4.23
```

Looks like it didnt recognize that the ratings are numerical


```r
xml_library_df$GOODREADS_RATING <-  xml_library_df$GOODREADS_RATING %>% as.numeric()
xml_library_df
```

```
## # A tibble: 3 x 4
##   TITLE             AUTHORS                          GENRE   GOODREADS_RATING
##   <chr>             <chr>                            <chr>              <dbl>
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy             4.5 
## 2 King of Thorns    Mark Lawrence                    Fantasy             4.19
## 3 Lord Loss         Darren Shan                      Fantasy             4.23
```

## JSON Library

```r
json_library_df
```

```
## $library
##               title                          authors   genre rating
## 1 A Memory of Light Robert Jordan, Brandon Sanderson Fantasy   4.50
## 2    King of Thorns                    Mark Lawrence Fantasy   4.19
## 3         Lord Loss                      Darren Shan Fantasy   4.23
```


The JSON was read in as a list so we have to convert it into a tibble structure using `tibble`


```r
json_library_df <- tibble(json_library_df$library)
json_library_df
```

```
## # A tibble: 3 x 4
##   title             authors   genre   rating
##   <chr>             <list>    <chr>    <dbl>
## 1 A Memory of Light <chr [2]> Fantasy   4.5 
## 2 King of Thorns    <chr [1]> Fantasy   4.19
## 3 Lord Loss         <chr [1]> Fantasy   4.23
```

```r
json_library_df$authors
```

```
## [[1]]
## [1] "Robert Jordan"     "Brandon Sanderson"
## 
## [[2]]
## [1] "Mark Lawrence"
## 
## [[3]]
## [1] "Darren Shan"
```
You can see that the JSON stored the multiple authors as a list due to the nature of the JSON file itself. This can be beneficial when working with datasets that have large lists within the data structure.

# Conclusion

  + HTML
    + Numerical values are appropriately read in.
    + HTML data is created as a list that we convert to a tibble()
  + XML
    + We can create a dataframe, but we have to manually convert numerical values
  + JSON
    + `fromJSON` reads in our data as a list that can be converted to a tibble()
    + JSON can hold arrays as values within its original format, which creates list values when you convert from JSON to tibble(). This is the biggest difference between methods and feels more _technically_ correct for storing multiple authors.
