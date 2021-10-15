#########################################################################
### LOAD LIBRARIES
#########################################################################
library(rvest)
library(tidyverse)
library(cdcfluview)

fluviewr_data<-function(regionz = "national"){
  df <- cdcfluview::who_nrevss(region = "national")
  df[[1]] %>%
    rowwise %>%
    mutate(
      a_all = sum(a_2009_h1n1, a_h1, a_subtyping_not_performed,
                  a_h3, a_unable_to_subtype, h3n2v),
      b_all = sum(b) 
    )%>%
    select(-c(a_h1, a_h3, a_2009_h1n1, percent_positive, 
              a_subtyping_not_performed, a_unable_to_subtype,
              h3n2v, b))-> df_old
  df[[2]] %>%
    rowwise %>%
    mutate(
      a_all = sum(a_2009_h1n1, a_h3, a_subtyping_not_performed, h3n2v),
      b_all = sum(b, bvic, byam)
    )  %>%
    select(-c(a_2009_h1n1, a_h3,
              a_subtyping_not_performed,
              h3n2v, b, bvic, byam))-> df_ph
   df[[3]] %>%
     rename(
       a_all = "total_a",
       b_all = "total_b"
     ) %>%
     select(-c(percent_positive,
               percent_a,
               percent_b)) -> df_clin
  
  df_new <- merge(df_ph, df_clin, by="wk_date", all=T)
  df_new$total_specimens <- rowSums(df_new[, c("total_specimens.x", "total_specimens.y")])
  df_new$a_all <- rowSums(df_new[,c("a_all.x", "a_all.y")])
  df_new$b_all <- rowSums(df_new[,c("b_all.x", "b_all.y")])
  
  df_new %>%
    rename(
      region_type = "region_type.x",
      year = "year.x",
      week = "week.x",
      region = "region.x",
    ) -> df_new
  df_new <- df_new[,names(df_old)]
  
  df <- rbind(df_old, df_new)
  
  df$total_flu <- rowSums(df[,c("a_all", "b_all")])
  df$percent_a <- round(df$a_all / df$total_specimens *100,1)
  df$percent_b <- round(df$b_all / df$total_specimens *100,1)
  return(df)
}


### Create function to scrape clinical and public health raw data
### Loc = "clinical", "public health", "ILI", or "ILI age [character]
### start = number for start year of influenza season of interest
### stop = number for stop year of influenza season of interest
fluview.scrape <- function(loc, start, stop = start+1) {
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
# df.clin <-
#   rbind(
#     fluview.scrape(loc ="clinical", start=2015),
#     fluview.scrape(loc ="clinical", start=2016),
#     fluview.scrape(loc ="clinical", start=2017),
#     fluview.scrape(loc ="clinical", start=2018),
#     fluview.scrape(loc ="clinical", start=2019),
#     fluview.scrape(loc ="clinical", start=2020)
#   )
# 
# df.ph <-
#   rbind(
#     fluview.scrape(loc ="public health", start=2015),
#     fluview.scrape(loc ="public health", start=2016),
#     fluview.scrape(loc ="public health", start=2017),
#     fluview.scrape(loc ="public health", start=2018),
#     fluview.scrape(loc ="public health", start=2019),
#     fluview.scrape(loc ="public health", start=2020)
#   )



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
#test <- fluview.stack(df.clin, df.ph)



#### PLOTTER PER EID Article
library(vroom)
library(ISOweek)
library(dplyr)
library(anomalize)

fluview.mortplot <- function(){
  ## Step 1, obtain data - will need to update dates manually in the future
  df <- data.frame(vroom::vroom("https://www.cdc.gov/flu/weekly/weeklyarchives2020-2021/data/NCHSData37.csv"))
  
  ## step 2,, fix week
  df[,"wkyr"]<-paste0(df[,"Year"], "-", ifelse(nchar(df[,"Week"])==1, paste0("0", df[,"Week"]), df[,"Week"]))
  df[,"wkyr"] <- sub("(\\d{4}-)(\\d{2})", "\\1W\\2-1", df[,"wkyr"])
  df[,"wkyr"] <- ISOweek::ISOweek2date(df[,"wkyr"])
  df[,"mort"]<-df[,"Percent.of.Deaths.Due.to.Pneumonia.and.Influenza..P.I."]
  
  df %>%
    dplyr::tibble() %>%
    anomalize::time_decompose(mort, frequency="auto", trend="auto", method="twitter") %>%
    anomalize::anomalize(remainder, alpha = 0.05, max_anoms = 0.2, method = "gesd") %>%
    anomalize::time_recompose() %>%
    anomalize::plot_anomalies(time_recomposed = TRUE) -> p4
  
  ### extract and re-plot
  low.ylim<-(floor(min(df[,"mort"], na.rm=T))-1) - ((floor(min(df[,"mort"], na.rm=T))-1) %% 2) 
  hi.ylim<-(ceiling(max(df[,"mort"], na.rm=T))+1) + ((ceiling(min(df[,"mort"], na.rm=T))+1) %% 2) 
  xlab<-df[,"Week"][df[,"Week"]%%10==0]
  x.ind<-as.numeric(as.character(row.names(df)[df[,"Week"]%in%as.numeric(as.character(xlab))]))
  min(df[,"mort"])
  par(mar=c(4,5,1,1))
  plot(df[,"mort"], type="l", ylim=c(low.ylim,hi.ylim),
       xaxt="n", yaxt="n", ylab="", xlab="MMWR Week Number")
  polygon(c(seq(1,nrow(df)), rev(seq(1,nrow(df)))), c(p4$data$recomposed_l2, rev(p4$data$recomposed_l1)), col="grey94", border=NA)
  lines(df[,"mort"])
  points(df[,"mort"], cex=ifelse(p4$data$anomaly=="Yes", 1, 0), col=ifelse(p4$data$anomaly=="Yes", "red", "white"), pch=ifelse(p4$data$anomaly=="Yes", 18, 0))
  axis(1, at=x.ind, labels=xlab)
  axis(2, at=seq(low.ylim,hi.ylim, by=2), labels=paste0(seq(low.ylim,hi.ylim, by=2),"%"), las=2)
  mtext(side=2, text="Percent of All Deaths \nDue to Pneumonia and Influenza", line = 3)
  text(x=2, y=2, "2013", cex=0.8)
  text(x=43, y=2, "2014", cex=0.8)
  yearz<-names(table(df[,"Year"]))
  for(i in 3:length(yearz)){
    text(x=43+(52*(i-2)), y=low.ylim, yearz[i], cex=0.8)
  }
  mtext(side=1, line=4, "Red Points = Anomalies")
}
