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
m <- fit.prophet(m, df) 

# forecast
future <- make_future_dataframe(m, periods = 3600)
forecast <- predict(m, future)
plot(m, forecast)


