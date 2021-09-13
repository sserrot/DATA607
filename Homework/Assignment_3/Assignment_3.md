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





Please deliver links to an R Markdown file (in GitHub and rpubs.com) with solutions to the problems below.  You may work in a small group, but please submit separately with names of all group participants in your submission.

#1. Using the 173 majors listed in fivethirtyeight.com’s College Majors dataset [https://fivethirtyeight.com/features/the-economic-guide-to-picking-a-college-major/], provide code that identifies the majors that contain either "DATA" or "STATISTICS"


```r
majors_df <- read.csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/college-majors/majors-list.csv")

filt_majors <- majors_df %>% filter(grepl("DATA | STATISTICS", Major))

filt_majors
```

```
##   FOD1P                                         Major          Major_Category
## 1  6212 MANAGEMENT INFORMATION SYSTEMS AND STATISTICS                Business
## 2  2101      COMPUTER PROGRAMMING AND DATA PROCESSING Computers & Mathematics
```


#2 Write code that transforms the data below:

[1] "bell pepper"  "bilberry"     "blackberry"   "blood orange"

[5] "blueberry"    "cantaloupe"   "chili pepper" "cloudberry"  

[9] "elderberry"   "lime"         "lychee"       "mulberry"    

[13] "olive"        "salal berry"

Into a format like this:

c("bell pepper", "bilberry", "blackberry", "blood orange", "blueberry", "cantaloupe", "chili pepper", "cloudberry", "elderberry", "lime", "lychee", "mulberry", "olive", "salal berry")



```r
goal_vector <- c("bell pepper", "bilberry", "blackberry", "blood orange", "blueberry", "cantaloupe", "chili pepper", "cloudberry", "elderberry", "lime", "lychee", "mulberry", "olive", "salal berry")

sample_string <- '[1] "bell pepper"  "bilberry"     "blackberry"   "blood orange" 

[5] "blueberry"    "cantaloupe"   "chili pepper"  "cloudberry"  

[9] "elderberry"   "lime"         "lychee"       "mulberry"    

[13] "olive"        "salal berry"'


# read in everything into a list of 1

sample_string <- sample_string %>% str_split("\\\\")

# replace all non characters with blanks 
only_chars <- '([^a-z" ])'

sample_string <- sample_string %>% str_replace_all(only_chars, "")

# trim whitespace

sample_string <- sample_string %>% str_trim()

# remove escaped quotes
sample_string <- sample_string %>% str_replace_all('(["])', "")

# expand string with multiple spaces
sample_string <- sample_string %>% str_split("  ")

#change from list into character vector
sample_string <- sample_string[[1]]

#remove empty characters
sample_string <- sample_string[sample_string != ""]
#trim again
sample_string <- sample_string %>% str_trim()
sample_string
```

```
##  [1] "bell pepper"  "bilberry"     "blackberry"   "blood orange" "blueberry"   
##  [6] "cantaloupe"   "chili pepper" "cloudberry"   "elderberry"   "lime"        
## [11] "lychee"       "mulberry"     "olive"        "salal berry"
```

```r
setdiff(sample_string,goal_vector)
```

```
## character(0)
```

The two exercises below are taken from R for Data Science, 14.3.5.1 in the on-line version:

#3 Describe, in words, what these expressions will match:

(.)\1\1
"(.)(.)\\2\\1"
(..)\1
"(.).\\1.\\1"
"(.)(.)(.).*\\3\\2\\1"
#4 Construct regular expressions to match words that:

Start and end with the same character.
Contain a repeated pair of letters (e.g. "church" contains "ch" repeated twice.)
Contain one letter repeated in at least three places (e.g. "eleven" contains three "e"s.)
