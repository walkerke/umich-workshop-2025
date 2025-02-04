options(tigris_use_cache = TRUE)

# install.packages(c("tidycensus", "tidyverse"))

# install.packages(c("mapview", "survey", "srvyr", "arcgislayers"))

# library(tidycensus)
# 
# census_api_key("YOUR KEY GOES HERE", install = TRUE)

library(tidycensus)

median_value <- get_acs(
  geography = "county",
  variables = "B25077_001",
  year = 2023
)

median_value

median_value_1yr <- get_acs(
  geography = "place",
  variables = "B25077_001",
  year = 2023,
  survey = "acs1"
)

median_value_1yr

income_table <- get_acs(
  geography = "county", 
  table = "B19001", 
  year = 2023
)

income_table

sd_value <- get_acs(
  geography = "tract", 
  variables = "B25077_001", 
  state = "CA", 
  county = "San Diego",
  year = 2023
)

sd_value

# vars <- load_variables(2023, "acs5")
# 
# View(vars)
# 

age_sex_table <- get_acs(
  geography = "state", 
  table = "B01001", 
  year = 2023,
  survey = "acs1",
)


age_sex_table

age_sex_table_wide <- get_acs(
  geography = "state", 
  table = "B01001", 
  year = 2023,
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
  year = 2023
)

ca_education

get_acs(
  geography = "state",
  variables = "B16001_054",
  year = 2023,
  survey = "acs1"
)

get_acs(
  geography = "state",
  variables = "B16001_054",
  year = 2023,
  survey = "acs5"
)

utah_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "UT",
  year = 2023
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
  labs(title = "Median household income, 2019-2023 ACS",
       subtitle = "Counties in Utah",
       caption = "Data acquired with R and tidycensus",
       x = "ACS estimate",
       y = "") + 
  theme_minimal(base_size = 12)

utah_plot

# View(utah_income)

utah_plot_errorbar <- ggplot(utah_income, aes(x = estimate, 
                                        y = reorder(NAME, estimate))) + 
  geom_errorbar(aes(xmin = estimate - moe, xmax = estimate + moe), #<<
                width = 0.5, linewidth = 0.5) + #<<
  geom_point(color = "darkblue", size = 2) + 
  scale_x_continuous(labels = label_dollar()) + 
  scale_y_discrete(labels = function(x) str_remove(x, " County, Utah")) + 
  labs(title = "Median household income, 2019-2023 ACS",
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
  year = 2023
)

library(arcgislayers)

cook_geo <- arc_read("https://tigerweb.geo.census.gov/arcgis/rest/services/Generalized_ACS2023/Tracts_Blocks/MapServer/4", where = "COUNTY = '031' AND STATE = '17'")

cook_geo

library(dplyr)

cook_education_geo <- cook_geo %>%
  select(GEOID) %>%
  left_join(cook_education, by = "GEOID")

cook_education_geo

library(mapview)

mapview(cook_education_geo)

mapview(cook_education_geo, zcol = "estimate")

tx_education <- get_acs(
  geography = "county",
  variables = "DP02_0068P",
  state = "TX",
  year = 2023,
  survey = "acs1"
)

tx_counties <- arc_read("https://tigerweb.geo.census.gov/arcgis/rest/services/Generalized_ACS2023/State_County/MapServer/11", where = "STATE = '48'")

tx_geo <- left_join(tx_counties, tx_education, by = "GEOID")

mapview(tx_geo, zcol = "estimate")

tx_wfh <- get_acs(
  geography = "puma",
  variables = "DP03_0024P",
  state = "TX",
  survey = "acs1",
  year = 2023
)

tx_pumas <- arc_read("https://tigerweb.geo.census.gov/arcgis/rest/services/Generalized_TAB2020/PUMA_TAD_TAZ_UGA_ZCTA/MapServer/4", where = "STATE = '48'")

tx_geo <- left_join(tx_pumas, tx_wfh, by = "GEOID")

library(mapview)

mapview(tx_geo, zcol = "estimate")

library(tidycensus)

la_pums <- get_pums(
  variables = c("SEX", "AGEP", "HHT"),
  state = "LA",
  survey = "acs1",
  year = 2023
)

la_pums

library(tidyverse)

la_age_41 <- filter(la_pums, AGEP == 41)

print(sum(la_pums$PWGTP))
print(sum(la_age_41$PWGTP))

get_acs("state", "B01003_001", state = "LA", survey = "acs1", year = 2023)

# View(pums_variables)

la_pums_recoded <- get_pums(
  variables = c("SEX", "AGEP", "HHT"),
  state = "LA",
  survey = "acs1",
  year = 2023,
  recode = TRUE
)

la_pums_recoded

la_pums_filtered <- get_pums(
  variables = c("SEX", "AGEP", "HHT"),
  state = "LA",
  survey = "acs5",
  variables_filter = list(
    SEX = 2,
    AGEP = 30:49
  ),
  year = 2023
)

la_pums_filtered

la_age_by_puma <- get_pums(
  variables = c("PUMA", "AGEP"),
  state = "LA",
  survey = "acs1",
  year = 2023
)

la_age_by_puma

la_pums_replicate <- get_pums(
  variables = c("AGEP", "PUMA"),
  state = "LA",
  survey = "acs1",
  year = 2023,
  rep_weights = "person" 
)


la_pums_replicate

la_survey <- to_survey(
  la_pums_replicate,
  type = "person"
)

class(la_survey)

library(srvyr)

la_survey %>%
  filter(AGEP == 41) %>%
  survey_count() %>%
  mutate(n_moe = n_se * 1.645)

la_survey %>%
  group_by(PUMA) %>%
  summarize(median_age = survey_median(AGEP)) %>%
  mutate(median_age_moe = median_age_se * 1.645)

la_age_puma <- get_acs(
  geography = "puma",
  variables = "B01002_001",
  state = "LA",
  year = 2023,
  survey = "acs1"
)
