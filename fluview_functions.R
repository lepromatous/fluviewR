#########################################################################
### LOAD LIBRARIES
#########################################################################
library(rvest)
library(tidyverse)

### Create function to scrape clinical and public health raw data
### Loc = "clinical", "public health", "ILI", or "ILI age [character]
### start = number for start year of influenza season of interest
### stop = number for stop year of influenza season of interest
fluview.scrape <- function(loc, start, stop) {
  if(loc == "clinical"){
    url <- paste0("https://www.cdc.gov/flu/weekly/weeklyarchives", start, "-", stop, "/data/whoAllregt_cl37.html")
  } else if(loc == "public health"){
    url <- paste0("https://www.cdc.gov/flu/weekly/weeklyarchives", start, "-", stop, "/data/whoAllregt_phl37.html")
  }else if(loc == "ILI"){
    url <- paste0("https://www.cdc.gov/flu/weekly/weeklyarchives", start, "-", stop, "data/senAllregt37.html")
  }else if(loc == "ILI age"){
    url <- paste0("https://www.cdc.gov/flu/weekly/weeklyarchives", start, "-", stop, "/data/iliage37.html")
  }
  
  url %>%
    read_html %>%
    html_table() %>%
    .[[1]] -> out
  out$Week <- factor(out$Week)
  return(out)
}


### EXAMPLE RUN SCRIPTS FOR BOTH CLINICAL AND PUBLIC HEALTH 2015 - 2021
df.clin <-
  rbind(
    fluview.scrape(loc ="clinical", start=2015, stop=2016),
    fluview.scrape(loc ="clinical", start=2016, stop=2017),
    fluview.scrape(loc ="clinical", start=2017, stop=2018),
    fluview.scrape(loc ="clinical", start=2018, stop=2019),
    fluview.scrape(loc ="clinical", start=2019, stop=2020),
    fluview.scrape(loc ="clinical", start=2020, stop=2021)
  )

df.ph <-
  rbind(
    fluview.scrape(loc ="public health", start=2015, stop=2016),
    fluview.scrape(loc ="public health", start=2016, stop=2017),
    fluview.scrape(loc ="public health", start=2017, stop=2018),
    fluview.scrape(loc ="public health", start=2018, stop=2019),
    fluview.scrape(loc ="public health", start=2019, stop=2020),
    fluview.scrape(loc ="public health", start=2020, stop=2021)
  )



fluview.stack <- function(clin.data = df.clin, ph.data = df.ph){
  ph.data$n.fluA <- rowSums(ph.data[,c(2,3,4,5,6)])
  ph.data$n.fluB <- rowSums(ph.data[,c(7,8,9)])
  ph.data$total.tested <- ph.data[,10]
  
  clin.data %>%
    rename(
     n.fluA = "Total A",
     n.fluB = "Total B",
     total.tested = "Total # Tested"
    ) -> clin.data
 
  clin.data <- clin.data[,c("Week", "n.fluA", "n.fluB", "total.tested")]
  ph.data <- ph.data[,c("Week", "n.fluA", "n.fluB", "total.tested")]
  
  df <- rbind(ph.data, clin.data)
  
  df %>%
    group_by(as.factor(Week)) %>%
    summarise(
      n.fluA = sum(n.fluA),
      n.fluB = sum(n.fluB),
      n.flu = sum(n.fluA, n.fluB),
      total.tested = sum(total.tested)
    ) %>%
  mutate(
    percent.fluA = round(n.fluA/n.flu*100,1),
    percent.fluB = round(n.fluB/n.flu*100,1),
    percent.positive = round(n.flu/total.tested *100,1) 
    ) %>%
    rename(
      week = "as.factor(Week)"
    ) %>%
    ungroup() -> df
  return(df)
}


#### run
test <- fluview.stack(df.clin, df.ph)

