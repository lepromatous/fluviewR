#########################################################################
### LOAD LIBRARIES
#########################################################################
library(rvest)
library(tidyverse)

### Create function to scrape clinical and public health raw data
### Loc = "clinical" or "public health" [character]
### start = number for start year of influenza season of interest
### stop = number for stop year of influenza season of interest
flu.scrape <- function(loc, start, stop) {
  if(loc == "clinical"){
    url <- paste0("https://www.cdc.gov/flu/weekly/weeklyarchives", start, "-", stop, "/data/whoAllregt_cl37.html")
  } else if(loc == "public health"){
    url <- paste0("https://www.cdc.gov/flu/weekly/weeklyarchives", start, "-", stop, "/data/whoAllregt_phl37.html")
    
  }
  
  url %>%
    read_html %>%
    html_table() %>%
    .[[1]] -> out
  return(out)
}


### EXAMPLE RUN SCRIPTS FOR BOTH CLINICAL AND PUBLIC HEALTH 2015 - 2021
df.clin <-
  rbind(
    flu.scrape(loc ="clinical", start=2015, stop=2016),
    flu.scrape(loc ="clinical", start=2016, stop=2017),
    flu.scrape(loc ="clinical", start=2017, stop=2018),
    flu.scrape(loc ="clinical", start=2018, stop=2019),
    flu.scrape(loc ="clinical", start=2019, stop=2020),
    flu.scrape(loc ="clinical", start=2020, stop=2021)
  )

df.ph <-
  rbind(
    flu.scrape(loc ="public health", start=2015, stop=2016),
    flu.scrape(loc ="public health", start=2016, stop=2017),
    flu.scrape(loc ="public health", start=2017, stop=2018),
    flu.scrape(loc ="public health", start=2018, stop=2019),
    flu.scrape(loc ="public health", start=2019, stop=2020),
    flu.scrape(loc ="public health", start=2020, stop=2021)
  )






