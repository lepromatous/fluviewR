library(tidyverse)
library(prophet)
library(Hmisc)

df <- fluviewr_data()
df <- subset(df, df$week%nin%seq(19,39))
df %>%
  mutate(
    pct_flu = total_flu/total_specimens*100
  ) %>%
  select(c(wk_date,pct_flu)) %>%
  rename(
    ds = "wk_date",
    y = "pct_flu"
  ) -> df


### split before/after COVID
df.pre <- subset(df, df$ds<"2020-09-27")
df.post<- data.frame(cbind(
                          "ds" = c(rep(NA, times=nrow(df.pre)), df$ds[df$ds>="2020-09-27"]), 
                          "y" = c(rep(NA, times=nrow(df.pre)), df$y[df$ds>="2020-09-27"])))
 df.post$ds <- df$ds                    

 ####################################################################
####################################################################
####################################################################
### set up model
m <- prophet(daily.seasonality= F, 
             weekly.seasonality = T,
             yearly.seasonality = T,
             interval.width = .8)
## add us holidays
m <- add_country_holidays(m, country_name = 'US')

## fit
m <- fit.prophet(m, df.pre) 

# forecast
future <- make_future_dataframe(m, periods = 1000)
forecast <- predict(m, future)
plot(m, forecast)

p<-plot(m, forecast)

t <- p +
  geom_point(data=df.post, aes(x=as.POSIXct(df.post$ds), y=y, colour="actual"))

plotly::ggplotly(t)
