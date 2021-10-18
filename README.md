FluViewR
================

### This package contains various functions to access raw data on [CDC FluView](https://www.cdc.gov/flu/weekly/index.htm) through web scraping. Note that some of these data may be available more readily on the [CDC Open Data Website](https://data.cdc.gov/). The benefit of scraping is you can more easily obtain basic data. The R package [RSocrata](https://cran.r-project.org/web/packages/RSocrata/index.html) is ideal for obtaining data from the open data API.

### Available Functions

1.  `fluviewr_data` utlizes the Fluview Interactive API as implemented
    by the
    [cdcfluview](https://cran.r-project.org/web/packages/cdcfluview/index.html)
    package available on CRAN. The `fluviewr_data` function essentially
    does the work of `fluview.scrape` and `fluview.stack` outlined
    below, both of which are being deprecated.

Currently, this function only scrapes nationally aggregate data for all
years available (1997 - present) though it will be updated to obtain
various geographies in the future.

To use this function, simply call:

``` r
df <- fluviewr_data()
```

The output of this function will contain stacked, cleaned and aggregated
clinical and public health data, separated or aggregated by general
influenza A vs B as well as the proportion of each for surveillance
purposes.

2.  `fluview.scrape` function contains a function to scrape clinical,
    public health, ILI, or ILI by age group data from HTML tables on the
    [CDC Flu View Website](https://www.cdc.gov/flu/weekly/index.htm).

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

3.  `fluview.stack` takes clinical and public health datasets obtained
    from `fluview.scrape`, and cleans/stacks them for analysis.

This function takes two arguments, `clin.data` and `ph.data`
corresponding to the clinical and public health datasets scraped using
the `fluview.scrape` function

The output is a single dataframe with the total fluA, fluB, total tests,
and relevant percentages.

Running the function is simple. Assuming you have a clinical dataset
from `fluview.scrape` called df.clin, and a public health dataset from
`fluview.scrape` called df.ph:

``` r
df.combined <- fluview.stack(df.clin, df.ph)
```

4.  `fluview.mortplot` provides a time series-decomposed anomaly
    detection plot for Pneumonia and Influenza-associated mortality.
    This function has no options but uses life data from [CDC Flu
    View](https://www.cdc.gov/flu/weekly/weeklyarchives2020-2021/data/NCHSData37.csv).
    The function will need updated when new influenza seasons are added
    as the date is hard coded into the URL. The time series is first
    decomposed using the
    [anomalize](https://cran.r-project.org/web/packages/anomalize/index.html)
    package using `auto` for both frequency and trend options. The
    decomposition method is `twitter` and the anomalize method is `gesd`
    with 0.05 `alpha` and 0.2 \`max\_anomalies. Use our [web
    application](https://surveillance.shinyapps.io/fluview) to alter
    these options.

To run the function, do the following:

``` r
fluview.mortplot()
```
