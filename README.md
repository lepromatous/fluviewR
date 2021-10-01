FluViewR
================

### This package contains various functions to access raw data on [CDC FluView](https://www.cdc.gov/flu/weekly/index.htm) through web scraping. Note that some of these data may be available more readily on the [CDC Open Data Website](https://data.cdc.gov/). The benefit of scraping is you can more easily obtain basic data. The R package [RSocrata](https://cran.r-project.org/web/packages/RSocrata/index.html) is ideal for obtaining data from the open data API.

### Available Functions

1.  `fluview.scrape` contains a function to scrape clinical, public
    health, ILI, or ILI by age group data from HTML tables on the [CDC
    Flu View Website](https://www.cdc.gov/flu/weekly/index.htm).

`fluview.scrape` contains two options:

1.  `loc`, which is a character vector of length 1 taking one of the
    following: “clinical”, “public health”, “ILI”, or “ILI age”- this
    identifies the corresponding table

2.  `start`, which is a numeric vector of length 1 corresponding to the
    4 digit year of the start of the influenza season of interest

A single year can be derived with:

``` r
fluview.scrape("clinical", 2017)
```

This would give you the 2017-2018 influenza season data for clinical
reports.

To obtain data for multiple years:

``` r
df.clin <-
  rbind(
    fluview.scrape(loc ="clinical", start=2015),
    fluview.scrape(loc ="clinical", start=2016),
    fluview.scrape(loc ="clinical", start=2017),
    fluview.scrape(loc ="clinical", start=2018),
    fluview.scrape(loc ="clinical", start=2019),
    fluview.scrape(loc ="clinical", start=2020)
  )
```

Alternatively, you can use an apply function or a for loop:

``` r
df.clin <- sapply(seq(2015,2020), function(x) fluview.scrape(loc = "clinical", function(x) start=x))
```

2.  `fluview.stack` takes clinical and public health datasets obtained
    from `fluview.scrape`, and cleans/stacks them for analysis.

This function takes two arguments, `clin.data` and `ph.data`
corresponding to the clinical and public health datasets scraped using
the `fluview.scrape` function

The output is a single dataframe with the total fluA, fluB, total tests,
and relevant percentages.

Running the function is simple. Assuming you have a clinical dataset
from `fluview.scrape` called df.clin, and a public health dataset from
`fluview.scrap`e called df.ph:

``` r
df.combined <- fluview.stack(df.clin, df.ph)
```
