library(albersusa)
library(tidyverse)
library(sf)
library(tidycensus)
library(janitor)

### pull albers map
map <- albersusa::usa_sf()


### updated populations from tidycensus
## get var names from acs 2019
v19 <- load_variables(2019, "acs5", cache = TRUE)
### pull pops by state
pops <- get_acs(
            geography = "state",
            variables = c(pop_2019 = "B01001_001"),
            year = 2019
                )
### clean names for merge
pops %>%
  janitor::clean_names()->pops

### Make HHS Regions
### https://www.cms.gov/Outreach-and-Education/Medicare-Learning-Network-MLN/MLNProducts/Downloads/HHS_Regions_pops.pdf
pops$hhs_region[pops$name %in% c("Connecticut", "Maine", "Massachusetts", "New Hampshire", "Rhode Island", "Vermont")] <- 1
pops$hhs_region[pops$name %in% c("New Jersey", "New York", "Puerto Rico", "Virgin Islands")] <- 2
pops$hhs_region[pops$name %in% c("Delaware", "District of Columbia", "Maryland", "Pennsylvania", "Virginia", "West Virginia")] <- 3
pops$hhs_region[pops$name %in% c("Alabama", "Florida", "Georgia", "Kentucky", "Mississippi", "North Carolina", "South Carolina", "Tennessee")] <- 4
pops$hhs_region[pops$name %in% c("Illinois", "Indiana", "Michigan", "Minnesota", "Ohio", "Wisconsin")] <- 5
pops$hhs_region[pops$name %in% c("Arkansas", "Louisiana", "New Mexico", "Oklahoma", "Texas")] <- 6
pops$hhs_region[pops$name %in% c("Iowa", "Kansas", "Missouri", "Nebraska")] <- 7
pops$hhs_region[pops$name %in% c("Colorado", "Montana", "North Dakota", "South Dakota", "Utah", "Wyoming")] <- 8
pops$hhs_region[pops$name %in% c("Arizona", "California", "Hawaii", "Nevada")] <- 9
pops$hhs_region[pops$name %in% c("Alaska", "Idaho", "Oregon", "Washington")] <- 10

pops$hhs_region <- factor(pops$hhs_region, 
                         levels=seq(1:10), 
                         labels = c("Region 1 - Boston",
                                    "Region 2 - New York",
                                    "Region 3 - Philadelphia",
                                    "Region 4 - Atlanta",
                                    "Region 5 - Chicago",
                                    "Region 6 - Dallas",
                                    "Region 7 - Kansas City",
                                    "Region 8 - Denver",
                                    "Region 9 - San Francisco",
                                    "Region 10 - Seattle"))

### make pops by HHS region
pops %>%
  group_by(hhs_region) %>%
  summarise(
    pop_2019_hhs = sum(estimate, na.rm=T)
  ) %>%
    ungroup() -> pops2

### merge pops and pops2
pops <- merge(pops, pops2, by="hhs_region", all.x=T)
### drop moe
pops %>%
  select(-moe)-> pops

### merge
map <- merge(map, pops, by="name") -> map


test2 <- test[[1]]

ggplot(map) +
  geom_sf(aes(fill = pop_2019_hhs))

test <- who_nrevss(region = "national")
