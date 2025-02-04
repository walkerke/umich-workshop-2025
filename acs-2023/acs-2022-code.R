options(tigris_use_cache = TRUE)

## install.packages(c("tidycensus", "tidyverse"))

## install.packages(c("mapview", "survey", "srvyr"))

## library(tidycensus)
## 
## census_api_key("YOUR KEY GOES HERE", install = TRUE)

library(tidycensus)

median_value <- get_acs(
  geography = "county",
  variables = "B25077_001",
  year = 2022
)

median_value

median_value_1yr <- get_acs(
  geography = "place",
  variables = "B25077_001",
  year = 2022,
  survey = "acs1"
)

median_value_1yr

income_table <- get_acs(
  geography = "county", 
  table = "B19001", 
  year = 2022
)

income_table

sd_value <- get_acs(
  geography = "tract", 
  variables = "B25077_001", 
  state = "CA", 
  county = "San Diego",
  year = 2022
)

sd_value

## vars <- load_variables(2022, "acs5")
## 
## View(vars)
## 

age_sex_table <- get_acs(
  geography = "state", 
  table = "B01001", 
  year = 2022,
  survey = "acs1",
)


age_sex_table

age_sex_table_wide <- get_acs(
  geography = "state", 
  table = "B01001", 
  year = 2022,
  survey = "acs1",
  output = "wide" 
)

age_sex_table_wide

ca_education <- get_acs(
  geography = "county",
  state = "CA",
  variables = c(percent_high_school = "DP02_0062P", 
                percent_bachelors = "DP02_0065P",
                percent_graduate = "DP02_0066P"), 
  year = 2021
)

ca_education

get_acs(
  geography = "state",
  variables = "B16001_054",
  year = 2022,
  survey = "acs1"
)

get_acs(
  geography = "state",
  variables = "B16001_054",
  year = 2022,
  survey = "acs5"
)

utah_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "UT",
  year = 2022
) 

library(ggplot2)

utah_plot <- ggplot(utah_income, aes(x = estimate, y = NAME)) + 
  geom_point()

utah_plot

utah_plot <- ggplot(utah_income, aes(x = estimate, 
                                y = reorder(NAME, estimate))) + 
  geom_point(color = "darkblue", size = 2)

utah_plot

library(scales)
library(stringr)

utah_plot <- utah_plot + 
  scale_x_continuous(labels = label_dollar()) + 
  scale_y_discrete(labels = function(x) str_remove(x, " County, Utah")) 

utah_plot

utah_plot <- utah_plot + 
  labs(title = "Median household income, 2018-2022 ACS",
       subtitle = "Counties in Utah",
       caption = "Data acquired with R and tidycensus",
       x = "ACS estimate",
       y = "") + 
  theme_minimal(base_size = 12)

utah_plot

## View(utah_income)

utah_plot_errorbar <- ggplot(utah_income, aes(x = estimate, 
                                        y = reorder(NAME, estimate))) + 
  geom_errorbar(aes(xmin = estimate - moe, xmax = estimate + moe), #<<
                width = 0.5, linewidth = 0.5) + #<<
  geom_point(color = "darkblue", size = 2) + 
  scale_x_continuous(labels = label_dollar()) + 
  scale_y_discrete(labels = function(x) str_remove(x, " County, Utah")) + 
  labs(title = "Median household income, 2018-2022 ACS",
       subtitle = "Counties in Utah",
       caption = "Data acquired with R and tidycensus. Error bars represent margin of error around estimates.",
       x = "ACS estimate",
       y = "") + 
  theme_minimal(base_size = 12)

utah_plot_errorbar

cook_education <- get_acs(
  geography = "tract",
  variables = "DP02_0068P",
  state = "IL",
  county = "Cook",
  year = 2022,
  geometry = TRUE
)

cook_education

library(mapview)

mapview(cook_education)

mapview(cook_education, zcol = "estimate")

tx_education <- get_acs(
  geography = "county",
  variables = "DP02_0068P",
  state = "TX",
  year = 2022,
  survey = "acs1",
  geometry = TRUE
)

mapview(tx_education, zcol = "estimate")

wa_wfh <- get_acs(
  geography = "puma",
  variables = "DP03_0024P",
  state = "WA",
  survey = "acs1",
  year = 2022,
  geometry = TRUE
)

library(mapview)

mapview(wa_wfh, zcol = "estimate")

ct_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "CT",
  year = 2022,
  survey = "acs1",
  geometry = TRUE
)

mapview(ct_income, zcol = "estimate")


library(tigris)
library(mapview)
ct_tract_21 <- tracts("CT", cb = TRUE, year = 2021)
ct_tract_22 <- tracts("CT", cb = TRUE, year = 2022)

mapview(ct_tract_21) | mapview(ct_tract_22)

library(tidycensus)

or_pums <- get_pums(
  variables = c("SEX", "AGEP", "HHT"),
  state = "OR",
  survey = "acs1",
  year = 2022
)

or_pums

library(tidyverse)

or_age_40 <- filter(or_pums, AGEP == 40)

print(sum(or_pums$PWGTP))
print(sum(or_age_40$PWGTP))

get_acs("state", "B01003_001", state = "OR", survey = "acs1", year = 2022)

## View(pums_variables)

or_pums_recoded <- get_pums(
  variables = c("SEX", "AGEP", "HHT"),
  state = "OR",
  survey = "acs1",
  year = 2022,
  recode = TRUE
)

or_pums_recoded

or_pums_filtered <- get_pums(
  variables = c("SEX", "AGEP", "HHT"),
  state = "OR",
  survey = "acs5",
  variables_filter = list(
    SEX = 2,
    AGEP = 30:49
  ),
  year = 2022
)

or_pums_filtered

or_age_by_puma <- get_pums(
  variables = c("PUMA", "AGEP"),
  state = "OR",
  survey = "acs1",
  year = 2022
)

or_age_by_puma

or_pums_replicate <- get_pums(
  variables = c("AGEP", "PUMA"),
  state = "OR",
  survey = "acs1",
  year = 2022,
  rep_weights = "person" 
)


or_pums_replicate

or_survey <- to_survey(
  or_pums_replicate,
  type = "person"
)

class(or_survey)

library(srvyr)

or_survey %>%
  filter(AGEP == 40) %>%
  survey_count() %>%
  mutate(n_moe = n_se * 1.645)

or_survey %>%
  group_by(PUMA) %>%
  summarize(median_age = survey_median(AGEP)) %>%
  mutate(median_age_moe = median_age_se * 1.645)

or_age_puma <- get_acs(
  geography = "puma",
  variables = "B01002_001",
  state = "OR",
  year = 2022,
  survey = "acs1"
)
