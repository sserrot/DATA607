---
title: "Movie Night Analysis"
author: Santiago Torres
date: September 05, 2021
output:
  prettydoc::html_pretty:
    theme: cayman
    highlight: vignette
    keep_md: true
---





### Movie Night

For the past couple of months, a group of friends and I have been scheduling a virtual movie night as a group activity. After someone selected a movie, we would discuss and rate the movie and then store that rating in an offline Excel file. Eventually, one of our group decided to upload our data into a Google sheets document and we continued our process there, while adding metrics such as IMBD ratings and average group ratings. By pure luck, assignment 2 for Data607 involves inputting movie ratings into a SQL database, so I figured it would be a perfect opportunity to consolidate our data and learn how to set up a server on Microsoft Azure.

I've created a public copy simply for the use of this exercise. Ultimately, I hope to create a way for our group members to interact with my output in order to store our ratings.


```r
sheetslink <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vSjkE78uLem25GEQtzbvZgugAdJz-frrieRSCedT2zu4719tSnNHMqzCfEvtdjmnL5Jeag7LsJgTIEN/pub?gid=0&single=true&output=csv"

movieratings <- data.frame(read.csv(url(sheetslink)))

print(head(movieratings))
```

```
##        Date              Movie. IMDB.Rating.                       Genre.
## 1  4/5/2021 The Death of Stalin          7.3       Comedy, Drama, History
## 2 4/12/2021        Interstellar          8.6     Adventure, Drama, Sci-Fi
## 3 4/20/2021            Parasite          8.6      Comedy, Drama, Thriller
## 4 4/26/2021       Spirited Away          8.6 Animation, Adventure, Family
## 5  5/3/2021           Midsommar          7.1       Drama, Horror, Mystery
## 6 5/10/2021          Knives Out          7.9         Comedy, Crime, Drama
##   Picked.By. Jonathan Mason Bobby Danny Santiago Jacob Joshy Colby Juan
## 1   Jonathan        7     7     7     7      N/A   N/A   N/A   N/A  N/A
## 2      Mason        8    10    10     8       10    10   N/A   N/A  N/A
## 3      Bobby       10    10    10     9        8   N/A   N/A   N/A  N/A
## 4      Danny       10     9     8     9        8   N/A   N/A   N/A  N/A
## 5   Santiago        6   N/A     8     7        8   N/A   N/A   N/A  N/A
## 6   Jonathan       10    10     9     9       10     9   N/A   N/A  N/A
##   Average. Rating.Deviation.
## 1     7.00             -0.30
## 2     9.33              0.73
## 3     9.40              0.80
## 4     8.80              0.20
## 5     7.25              0.15
## 6     9.50              1.60
```

This is straightforward to understand when interacting with it personally, but not normalized from a database point of view and hard to maintain as we have to continually add a column each time someone joins.

I mocked up my quick thought process behind how to normalize the dataset 

![Imgur](https://i.imgur.com/4ePBHoi.jpg)

Ultimately, we'll create 3 dataframes that we'll load into a sql database.  

1. People - all the people who have watched, along with date_joined.
  + first_name
  + date_joined
2. Movies - holds movie information and who picked it
  + date_watched
  + movie_name
  + imbd_rating
  + genre
  + picked_by
3. Ratings - holds the movie ratings
  + movie_name
  + person
  + rating
  
  
## Data Cleaning

Start with some quick renaming and data selection.

The last row and the last two columns are  just a summary metrics like a person's average rating so we'll remove that for now.


```r
last_row <- nrow(movieratings)
last_column <- ncol(movieratings)

movieratings <- movieratings[-last_row,-c(last_column-1,last_column)]

movieratings <- movieratings %>% 
    rename(c("date_watched"=Date,"movie_name"=Movie.,"imbd_rating"=IMDB.Rating.,"genre"=Genre.,"picked_by"=Picked.By.))

#convert to date

movieratings$date_watched <- mdy(movieratings$date_watched)
```

The ratings are not all the same datatype due to N/As from people not attending so we have to convert to numeric. we can ignore the warning errors as we want to have NAs for where people did not rate a movie to avoid introducing zeros into any summary statistics.


```r
str(movieratings)
```

```
## 'data.frame':	22 obs. of  14 variables:
##  $ date_watched: Date, format: "2021-04-05" "2021-04-12" ...
##  $ movie_name  : chr  "The Death of Stalin" "Interstellar" "Parasite" "Spirited Away" ...
##  $ imbd_rating : num  7.3 8.6 8.6 8.6 7.1 7.9 8 8 5.8 7.1 ...
##  $ genre       : chr  "Comedy, Drama, History" "Adventure, Drama, Sci-Fi" "Comedy, Drama, Thriller" "Animation, Adventure, Family" ...
##  $ picked_by   : chr  "Jonathan" "Mason" "Bobby" "Danny" ...
##  $ Jonathan    : chr  "7" "8" "10" "10" ...
##  $ Mason       : chr  "7" "10" "10" "9" ...
##  $ Bobby       : num  7 10 10 8 8 9 10 9 5 8 ...
##  $ Danny       : num  7 8 9 9 7 9 8 9 7 8 ...
##  $ Santiago    : chr  "N/A" "10" "8" "8" ...
##  $ Jacob       : chr  "N/A" "10" "N/A" "N/A" ...
##  $ Joshy       : chr  "N/A" "N/A" "N/A" "N/A" ...
##  $ Colby       : chr  "N/A" "N/A" "N/A" "N/A" ...
##  $ Juan        : chr  "N/A" "N/A" "N/A" "N/A" ...
```

```r
movieratings[,6:length(movieratings)] <- sapply(movieratings[,6:length(movieratings)], as.numeric)
```

```
## Warning in lapply(X = X, FUN = FUN, ...): NAs introduced by coercion

## Warning in lapply(X = X, FUN = FUN, ...): NAs introduced by coercion

## Warning in lapply(X = X, FUN = FUN, ...): NAs introduced by coercion

## Warning in lapply(X = X, FUN = FUN, ...): NAs introduced by coercion

## Warning in lapply(X = X, FUN = FUN, ...): NAs introduced by coercion

## Warning in lapply(X = X, FUN = FUN, ...): NAs introduced by coercion

## Warning in lapply(X = X, FUN = FUN, ...): NAs introduced by coercion
```


## Person

Let's start with the easiest to set up - Person dataframe. 

I know which columns to exclude to focus on only people names so that makes things slightly simpler


```r
colnames(movieratings)
```

```
##  [1] "date_watched" "movie_name"   "imbd_rating"  "genre"        "picked_by"   
##  [6] "Jonathan"     "Mason"        "Bobby"        "Danny"        "Santiago"    
## [11] "Jacob"        "Joshy"        "Colby"        "Juan"
```

```r
people <- colnames(movieratings)
people <- people[6:length(people)]

people <- data.frame(first_name = people, stringsAsFactors = FALSE)
```



## Movies 

Data is already mostly cleaned up, we just have to select the columns we care about and drop the rest. we know it's just the first five columns


```r
movies <- movieratings[c(1:5)]

movies
```

```
##    date_watched                 movie_name imbd_rating
## 1    2021-04-05        The Death of Stalin         7.3
## 2    2021-04-12               Interstellar         8.6
## 3    2021-04-20                   Parasite         8.6
## 4    2021-04-26              Spirited Away         8.6
## 5    2021-05-03                  Midsommar         7.1
## 6    2021-05-10                 Knives Out         7.9
## 7    2021-05-17          Blade Runner 2049         8.0
## 8    2021-05-24               Perfect Blue         8.0
## 9    2021-05-31           Army of the Dead         5.8
## 10   2021-06-07 Bad Times at the El Royale         7.1
## 11   2021-06-14                      Creed         7.6
## 12   2021-06-21             The Lighthouse         7.5
## 13   2021-06-28                    Arrival         7.9
## 14   2021-07-05                    Samsara         8.5
## 15   2021-07-12                    Hot Rod         6.7
## 16   2021-07-19         Mad Max: Fury Road         8.1
## 17   2021-07-26                    Chappie         6.8
## 18   2021-08-02                 Ex Machina         7.7
## 19   2021-08-09        The Lives of Others         8.4
## 20   2021-08-16                Snowpiercer         7.1
## 21   2021-08-23         The Suicide Squad          7.4
## 22   2021-08-30     No Country for Old Men         8.1
##                           genre picked_by
## 1        Comedy, Drama, History  Jonathan
## 2      Adventure, Drama, Sci-Fi     Mason
## 3       Comedy, Drama, Thriller     Bobby
## 4  Animation, Adventure, Family     Danny
## 5        Drama, Horror, Mystery  Santiago
## 6          Comedy, Crime, Drama  Jonathan
## 7        Action, Drama, Mystery     Bobby
## 8     Animation, Crime, Mystery     Danny
## 9         Action, Crime, Horror  Santiago
## 10        Crime, Drama, Mystery  Jonathan
## 11                 Drama, Sport     Mason
## 12       Drama, Fantasy, Horror     Bobby
## 13                Drama, Sci-Fi     Danny
## 14           Documentary, Music  Santiago
## 15                Comedy, Sport     Joshy
## 16    Action, Adventure, Sci-Fi  Jonathan
## 17         Action, Crime, Drama     Mason
## 18      Drama, Sci-Fi, Thriller     Bobby
## 19     Drama, Mystery, Thriller     Danny
## 20        Action, Drama, Sci-Fi  Santiago
## 21    Action, Adventure, Comedy     Joshy
## 22       Crime, Drama, Thriller     Jacob
```

## Ratings

This seems more complicated as the data itself is in a flat table, but we simply just transpose the people columns to get their ratings and keep the movie_name I used the following links for some guidance: 

[StackOverflow](https://stackoverflow.com/questions/36136742/transpose-only-certain-columns-in-data-frame) and [Tidyverse Docs](https://tidyr.tidyverse.org/reference/pivot_longer.html)

we want to drop NA ratings as they are not actually data points - we can simply infer attendance from the existence of a rating or not.


```r
ratings <- movieratings[c(2, 6:length(movieratings))]
ratings <- ratings %>% pivot_longer(!movie_name, names_to = "first_name", values_to = "rating")
head(ratings)
```

```
## # A tibble: 6 x 3
##   movie_name          first_name rating
##   <chr>               <chr>       <dbl>
## 1 The Death of Stalin Jonathan        7
## 2 The Death of Stalin Mason           7
## 3 The Death of Stalin Bobby           7
## 4 The Death of Stalin Danny           7
## 5 The Death of Stalin Santiago       NA
## 6 The Death of Stalin Jacob          NA
```

```r
find_na <- is.na(ratings$rating)

#remove nas

ratings <- ratings[!find_na,]

head(ratings)
```

```
## # A tibble: 6 x 3
##   movie_name          first_name rating
##   <chr>               <chr>       <dbl>
## 1 The Death of Stalin Jonathan        7
## 2 The Death of Stalin Mason           7
## 3 The Death of Stalin Bobby           7
## 4 The Death of Stalin Danny           7
## 5 Interstellar        Jonathan        8
## 6 Interstellar        Mason          10
```


I realized I want to add the date someone joined to the person table so I have to do some quick manipulation


```r
date_joined <- movieratings[c(1, 6:length(movieratings))]
date_joined <- date_joined %>% pivot_longer(!date_watched, names_to = "first_name", values_to = "rating")

#find first non-na rating
people  <-  date_joined %>% filter(!is.na(rating)) %>% group_by(first_name) %>% summarise(date_joined = min(date_watched)) %>% arrange(date_joined)
people
```

```
## # A tibble: 9 x 2
##   first_name date_joined
##   <chr>      <date>     
## 1 Bobby      2021-04-05 
## 2 Danny      2021-04-05 
## 3 Jonathan   2021-04-05 
## 4 Mason      2021-04-05 
## 5 Jacob      2021-04-12 
## 6 Santiago   2021-04-12 
## 7 Joshy      2021-05-31 
## 8 Colby      2021-08-02 
## 9 Juan       2021-08-16
```


we now have our preliminary tables! Time to set up the Azure database.

## SQL

After creating an Azure account and setting it up on the Azure portal, we now have to connect through R.

###Connect to my Azure Database

I grab credentials from my keyring using the keyring package in r.


```r
username <- keyring::key_list("movienightdb")[1,2]
password <- keyring::key_get("movienightdb", username)
server <- keyring::key_list("movienightserver")[1,2]
```



```r
con <- dbConnect(odbc::odbc(), Driver = "SQL Server", server = server,Database="movienightsqldb",UID=username
,PWD=password)
```

Create the tables based on the data we've manipulated **note that eval = FALSE as I do not want to re-create the tables**


```r
dbWriteTable(con, "watchers", people)
dbWriteTable(con, "ratings", ratings)
dbWriteTable(con, "movies", movies)
```




## read back into R

```r
sql_watchers <- dbGetQuery(con, "SELECT * FROM watchers")
sql_ratings <- dbGetQuery(con, "SELECT * FROM ratings")
sql_movies <- dbGetQuery(con, "SELECT * FROM movies")
```

## Summary statistics

Just some quick stats


```r
movie_group <- sql_ratings %>% group_by(movie_name)
people_ratings <- sql_ratings %>% group_by(first_name)

mean_rating <- movie_group %>% summarise(avg_rating = mean(rating)) %>% arrange(avg_rating)
mean_rating
```

```
## # A tibble: 22 x 2
##    movie_name            avg_rating
##    <chr>                      <dbl>
##  1 "The Suicide Squad "        5.83
##  2 "Creed"                     6   
##  3 "The Lighthouse"            6.17
##  4 "Army of the Dead"          6.4 
##  5 "The Death of Stalin"       7   
##  6 "Perfect Blue"              7.17
##  7 "Midsommar"                 7.25
##  8 "Samsara"                   7.33
##  9 "Chappie"                   7.57
## 10 "Snowpiercer"               7.57
## # ... with 12 more rows
```

```r
people_ratings %>% summarise(rating = mean(rating), movies_watched = n()) %>% arrange(desc(rating))
```

```
## # A tibble: 9 x 3
##   first_name rating movies_watched
##   <chr>       <dbl>          <int>
## 1 Colby        9                 3
## 2 Santiago     8.48             21
## 3 Jonathan     8                19
## 4 Mason        7.94             18
## 5 Jacob        7.9              10
## 6 Bobby        7.77             22
## 7 Danny        7.59             22
## 8 Joshy        7.43             14
## 9 Juan         7                 3
```

Looks like I am definitely a lenient rater compared to most of my friends and the worst movie we've watched so far is _The Suicide Squad_

I hope to continue to expand on this throughout the semester with any new tools we learn.
