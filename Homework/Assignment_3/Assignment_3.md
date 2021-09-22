---
title: "Assignment 3 - R Character Manipulation"
author: Santiago Torres
date: September 12, 2021
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

sample_string
```

```
## [1] "[1] \"bell pepper\"  \"bilberry\"     \"blackberry\"   \"blood orange\" \n\n[5] \"blueberry\"    \"cantaloupe\"   \"chili pepper\"  \"cloudberry\"  \n\n[9] \"elderberry\"   \"lime\"         \"lychee\"       \"mulberry\"    \n\n[13] \"olive\"        \"salal berry\""
```

```r
setdiff(sample_string, goal_vector)
```

```
## [1] "[1] \"bell pepper\"  \"bilberry\"     \"blackberry\"   \"blood orange\" \n\n[5] \"blueberry\"    \"cantaloupe\"   \"chili pepper\"  \"cloudberry\"  \n\n[9] \"elderberry\"   \"lime\"         \"lychee\"       \"mulberry\"    \n\n[13] \"olive\"        \"salal berry\""
```

```r
# read in everything into a list of 1

sample_string <- sample_string %>% str_split("\\\\")

# replace all non characters with blanks 
only_chars <- '([^a-z" ])'

sample_string <- sample_string %>% str_replace_all(only_chars, "")

sample_string 
```

```
## [1] " \"bell pepper\"  \"bilberry\"     \"blackberry\"   \"blood orange\"  \"blueberry\"    \"cantaloupe\"   \"chili pepper\"  \"cloudberry\"   \"elderberry\"   \"lime\"         \"lychee\"       \"mulberry\"     \"olive\"        \"salal berry\""
```

```r
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

* (.)\1\1
  + While this would not be valid regex in R - in theory this would capture any character except line breaks _(.)_ and then _\1_ is a back-reference that would fit the first capture group and since it is repeated, it would be match the first capture group twice. So something like _aaa_ would match. However, since the backslashes are not escaped ("\\\\1" and then "\\\\1"), it would not match anything.

* "(.)(.)\\\\2\\\\1"
  + This regular expression has two capture groups that match any character and then back-references that refer to the second capture group and then the first capture group. Thus it would match anything that follows a pattern of _abba_ where the second character repeats and the first character ends the four character phrase

* (..)\1
  + This regex has a capture group that matches any two character and then a back-reference to the capture group of the same set. So this would match the pattern _abab_. However, like the first example, this is not properly formed regex in R and it would fail to actually match the expected pattern.

* "(.).\\\\1.\\\\1"
  + There is a capture group matching any character followed by any character, a back-reference to the capture group, any character, and then another back-reference to the first capture group. This means the regex would match a pattern like _azaxa_ or anything where the first character follows any single character consecutively _bybib_ or _;z;w;_

* "(.)(.)(.).*\\\\3\\\\2\\\\1"
  + First, you start off capturing a single character in a row. Then you match on any character 0 or more times until it ends with the third capture group then the second capture group and lastly the first captured character. A simple example would be _abc anythinginhere cba_


#4 Construct regular expressions to match words that:

* Start and end with the same character.
  + "\\b([A-Za-z])[A-Za-z]*\\1\\b"
  + Start with a `\\b` word boundary and then capture any a-z or A-Z character. Then you can have 0 to any characters from a-z or A-Z until it ends with the first character that was captured

  

```r
sentence <- "This sentence has all the types of words that we are looking for like elevate or church or eleven"
pattern <- "\\b([A-Za-z])[A-Za-z]*\\1\\b"

str_extract_all(string = sentence, pattern = pattern)
```

```
## [[1]]
## [1] "that"    "elevate"
```

* Contain a repeated pair of letters (e.g. "church" contains "ch" repeated twice.)
  + "\\b(..)[A-Za-z]*\\1\\b"
  + \\b is a word boundary to ensure you match on a word, then a two character capture group followed by any number of characters a-z case insensitive and then repeated by the two character capture group


```r
sentence <- "This sentence has all the types of words that we are looking for like elevate or church or eleven"
pattern <- "\\b(..)[A-Za-z]*\\1\\b"

str_extract_all(string = sentence, pattern = pattern)
```

```
## [[1]]
## [1] "church"
```


* Contain one letter repeated in at least three places (e.g. "eleven" contains three "e"s.)
  + "\\w*(\\w)\\w*\\1\\w*\\1\\w*"
  + Start with `\\w*` to look for any word character as many times and then capture a word character. Afterwords, allow any word character and look for the captured word 2 other times then match if the criteria is met.  
  

```r
sentence <- "This sentence has all the types of words that we are looking for like elevate or church or eleven"
pattern <- "\\w*(\\w)\\w*\\1\\w*\\1\\w*"

str_extract_all(string = sentence, pattern = pattern)
```

```
## [[1]]
## [1] "sentence" "elevate"  "eleven"
```
  
