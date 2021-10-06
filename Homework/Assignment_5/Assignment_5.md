---
title: "Assignment 5"
author: "Santiago Torres"
date: September 26, 2021
output:
  prettydoc::html_pretty:
    theme: cayman
    highlight: vignette
    keep_md: true
---



# Cleaning and Analyzing Untidy Data

## Goals:

1. Understand if there is enough data to calculate the total population
2. Calculate the efficacy of the vaccines against the disease and what it means.
3. Compare the rate of severe cases in unvaccinated individuals versus vaccinated individuals.


## Israeli Vaccination Records

First step is to read in the excel file.


```r
israeli_vaccines <- read.xlsx("https://github.com/sserrot/DATA607/blob/main/Homework/Assignment_5/israeli_vaccination_data_analysis_start.xlsx?raw=true")
israeli_vaccines
```

```
##                                                                                                                                                                   Age
## 1                                                                                                                                                                <NA>
## 2                                                                                                                                                                 <50
## 3                                                                                                                                                                    
## 4                                                                                                                                                                 >50
## 5                                                                                                                                                                <NA>
## 6                                                                                                                                                         Definitions
## 7                                                                                                                                                                <NA>
## 8                                                                                                                                                                <NA>
## 9                                                   (1) Do you have enough information to calculate the total population?  What does this total population represent?
## 10                                                                                                      (2) Calculate the Efficacy vs. Disease; Explain your results.
## 11 (3) From your calculation of efficacy vs. disease, are you able to compare the rate of severe cases in unvaccinated individuals to that in vaccinated individuals?
##                                                                                                   Population.%
## 1                                                                                                   Not Vax\n%
## 2                                                                                                      1116834
## 3                                                                                          0.23300000000000001
## 4                                                                                                       186078
## 5                                                                                        7.9000000000000001E-2
## 6                                                                                                         <NA>
## 7                                                                                  Severe Cases = hospitalized
## 8  Efficacy vs. severe disease = 1 - (% fully vaxed severe cases per 100K / % not vaxed severe cases per 100K)
## 9                                                                                                         <NA>
## 10                                                                                                        <NA>
## 11                                                                                                        <NA>
##                     X3         Severe.Cases                  X5
## 1         Fully Vax\n% Not Vax\nper 100K\np Fully Vax\nper 100K
## 2              3501118                   43                  11
## 3                 0.73                 <NA>                <NA>
## 4              2133516                  171                 290
## 5  0.90400000000000003                 <NA>                <NA>
## 6                 <NA>                 <NA>                <NA>
## 7                 <NA>                 <NA>                <NA>
## 8                 <NA>                 <NA>                <NA>
## 9                 <NA>                 <NA>                <NA>
## 10                <NA>                 <NA>                <NA>
## 11                <NA>                 <NA>                <NA>
##              Efficacy
## 1  vs. severe disease
## 2                <NA>
## 3                <NA>
## 4                <NA>
## 5                <NA>
## 6                <NA>
## 7                <NA>
## 8                <NA>
## 9                <NA>
## 10               <NA>
## 11               <NA>
```
Relevant data only exists in the first 5 rows so we can drop those rows and the last column which we will calculate later.
We should rename the columns to more manageable names as well


```r
israeli_vaccines <- israeli_vaccines[2:5,1:5]

israeli_vaccines <-  israeli_vaccines %>% rename(age = Age, unvaccinated = `Population.%`, vaccinated = `X3`, severe_unvaccinated = Severe.Cases, severe_vaccinated = X5 )


israeli_vaccines
```

```
##    age          unvaccinated          vaccinated severe_unvaccinated
## 2  <50               1116834             3501118                  43
## 3        0.23300000000000001                0.73                <NA>
## 4  >50                186078             2133516                 171
## 5 <NA> 7.9000000000000001E-2 0.90400000000000003                <NA>
##   severe_vaccinated
## 2                11
## 3              <NA>
## 4               290
## 5              <NA>
```

```r
# manually add in the percentage identifiers
under_fifty_per <- israeli_vaccines[2,2:3]
under_fifty_per <- under_fifty_per %>% rename(unvaccinated_percent_under_fifty = unvaccinated, vaccinated_percent_under_fifty= vaccinated)

over_fifty_per <- israeli_vaccines[4,2:3]
over_fifty_per <- over_fifty_per %>% rename(unvaccinated_percent_over_fifty = unvaccinated, vaccinated_percent_over_fifty = vaccinated)



under_fifty_pop <- israeli_vaccines %>% filter(age == "<50") %>% select(vaccinated) %>% as.numeric()
```


### Question 1 - Total Population

We can do the manual calculation for total population in each age group. 
Since we know that 73% of the under 50 group is 3,501,118  
We solve for x =

73/100 = 3,501,118 / X  
73x = 350,111,800  
x  = 4,796,052  

We repeat the same for the over-fifty numbers to get the total population as defined in this data. The total population would include people who are not fully vaccinated or un-vaccinated - ex: only one dose.
This also assumes that one of these cohorts includes 50 year olds as the data itself is not clear of which segment includes 50 year olds.


```r
under_fifty_total <- israeli_vaccines %>% filter(age == "<50") %>% select(vaccinated) %>% as.numeric() * 100 / 73
over_fifty_total <- israeli_vaccines %>% filter(age == ">50") %>% select(vaccinated) %>% as.numeric() * 100 / 90.4
total_population <- under_fifty_total + over_fifty_total

format(total_population, big.mark=",")
```

```
## [1] "7,156,136"
```

### Question 2 - Efficacy vs Disease

Efficacy is defined in the dataset as 1 - (% of fully vaxed severe cases) / (% not vaxed severe cases per 100k)


```r
# get total vaccinated
under_fifty_vaxed <- israeli_vaccines %>% filter(age == "<50") %>% select(vaccinated) %>% as.numeric()
under_fifty_vaxed_severe <- israeli_vaccines %>% filter(age == "<50") %>% select(severe_vaccinated) %>% as.numeric()

over_fifty_vaxed <- israeli_vaccines %>% filter(age == ">50") %>% select(vaccinated) %>% as.numeric()
over_fifty_vaxed_severe <- israeli_vaccines %>% filter(age == ">50") %>% select(severe_vaccinated) %>% as.numeric()

total_vax <- under_fifty_vaxed + over_fifty_vaxed
total_vax_severe <- under_fifty_vaxed_severe + over_fifty_vaxed_severe
per_vax_severe <- total_vax_severe / total_vax
```

Same process for unvaccinated


```r
# un vaccinated

under_fifty_unvaxed <- israeli_vaccines %>% filter(age == "<50") %>% select(unvaccinated) %>% as.numeric()
under_fifty_unvaxed_severe <- israeli_vaccines %>% filter(age == "<50") %>% select(severe_unvaccinated) %>% as.numeric()

over_fifty_unvaxed <- israeli_vaccines %>% filter(age == ">50") %>% select(unvaccinated) %>% as.numeric()
over_fifty_unvaxed_severe <- israeli_vaccines %>% filter(age == ">50") %>% select(severe_unvaccinated) %>% as.numeric()

total_unvax <- under_fifty_unvaxed + over_fifty_unvaxed
total_unvax_severe <- under_fifty_unvaxed_severe + over_fifty_unvaxed_severe
per_unvax_severe <- total_unvax_severe / total_unvax
```

Calculate efficacy


```r
efficacy <- 1 - (per_vax_severe / per_unvax_severe)

efficacy
```

```
## [1] 0.6747614
```

### Question 3 - Compare the rate of severe cases

It is clear that the rate of severe cases is less in vaccinated individuals compared to un-vaccinated individuals since the efficacy is around 67%. This effectively means someone who is vaccinated is about 2/3rd less likely to get a severe case than someone who is unvaccinated.
