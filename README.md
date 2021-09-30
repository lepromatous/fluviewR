# fluviewR
Programs to access raw data on CDC FluView

fluview.scrape contains a function to scrape clinical, public health, ILI, or ILI by age group data from HTML tables on the CDC fluview website. Keep in mind these data are likely available on data.cdc.gov and could then be accessed with RSocrata. However, scraping is more fun and allows an easier pull.

fluview.scrape contains two options:
loc, which is a character vector of length 1 taking one of the following: "clinical", "public health", "ILI", or "ILI age"- this identifies the corresponding table
start, which is a numeric vector of length 1 corresponding to the 4 digit year of the start of the influenza season of interest

A single year can be derived with:

fluview.scrape("clinical", 2017)

This would give you the 2017-2018 influenza season data for clinical reports.  For  multiple years:

df.clin <-
  rbind(
    fluview.scrape(loc ="clinical", start=2015),
    fluview.scrape(loc ="clinical", start=2016),
    fluview.scrape(loc ="clinical", start=2017),
    fluview.scrape(loc ="clinical", start=2018),
    fluview.scrape(loc ="clinical", start=2019),
    fluview.scrape(loc ="clinical", start=2020)
  )
  
  or use apply/for loop
df.clin <- sapply(seq(2015,2020), function(x) fluview.scrape(loc = "clinical", function(x) start=x)


fluview.stack takes clinical and public health datasets, cleans and stacks them for surveillance purposes.

This function takes two arguments, clin.data and ph.data corresponding to the clinical and public health datasets scraped using fluview.scrape()

The output is a single dataframe with the total fluA, fluB, total tests, and relevant percentages.
