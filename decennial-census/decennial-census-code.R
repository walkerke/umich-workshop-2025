library(tidycensus)
options(tigris_use_cache = TRUE)

# install.packages(c("tidycensus", "tidyverse", "mapview"))

# library(tidycensus)
# 
# census_api_key("YOUR KEY GOES HERE", install = TRUE)

pop20 <- get_decennial(
  geography = "state",
  variables = "P1_001N",
  year = 2020
)

pop20

table_p2 <- get_decennial(
  geography = "state", 
  table = "P2", 
  year = 2020
)

table_p2

mo_population <- get_decennial(
  geography = "county",
  variables = "P1_001N",
  state = "MO",
  sumfile = "dhc",
  year = 2020
)

mo_population

stl_blocks <- get_decennial(
  geography = "block",
  variables = "P1_001N",
  state = "MO",
  county = "St. Louis city",
  sumfile = "dhc",
  year = 2020
)

stl_blocks

# vars <- load_variables(2020, "dhc")
# 
# View(vars)
# 

single_year_age <- get_decennial(
  geography = "state",
  table = "PCT12",
  year = 2020,
  sumfile = "dhc"
)


single_year_age

single_year_age_wide <- get_decennial(
  geography = "state",
  table = "PCT12",
  year = 2020,
  sumfile = "dhc",
  output = "wide" 
)

single_year_age_wide

fl_samesex <- get_decennial(
  geography = "county",
  state = "FL",
  variables = c(married = "DP1_0116P",
                partnered = "DP1_0118P"),
  year = 2020,
  sumfile = "dp",
  output = "wide"
)

fl_samesex

library(tidyverse)

tidyverse_logo()

library(tidycensus)
library(tidyverse)

mo_population <- get_decennial(
  geography = "county",
  variables = "P1_001N",
  year = 2020,
  state = "MO",
  sumfile = "dhc"
)


arrange(mo_population, value)


arrange(mo_population, desc(value))

below1000 <- filter(mo_population, value < 1000)

below1000

race_vars <- c(
  Hispanic = "P5_010N",
  White = "P5_003N",
  Black = "P5_004N",
  Native = "P5_005N",
  Asian = "P5_006N",
  HIPI = "P5_007N"
)

cbsa_race <- get_decennial(
  geography = "cbsa",
  variables = race_vars,
  summary_var = "P5_001N", 
  year = 2020,
  sumfile = "dhc"
)

cbsa_race

cbsa_race_percent <- cbsa_race %>%
  mutate(percent = 100 * (value / summary_value)) %>% 
  select(NAME, variable, percent) 

cbsa_race_percent

largest_group <- cbsa_race_percent %>%
  group_by(NAME) %>% 
  filter(percent == max(percent)) 

# Optionally, use `.by`: 
# largest_group <- cbsa_race_percent %>%
#   filter(percent == max(percent), .by = NAME) 

largest_group

cbsa_race_percent %>%
  group_by(variable) %>% 
  summarize(median_pct = median(percent, na.rm = TRUE)) 

wv_over_65 <- get_decennial(
  geography = "tract",
  variables = "DP1_0024P",
  state = "WV",
  geometry = TRUE,
  sumfile = "dp",
  year = 2020
)


wv_over_65

library(mapview)

mapview(wv_over_65)

mapview(wv_over_65, zcol = "value")

mapview(wv_over_65, zcol = "value",
        layer.name = "% age 65 and up<br>Census tracts in Iowa")


library(viridisLite)

mapview(wv_over_65, zcol = "value",
        layer.name = "% age 65 and up<br>Census tracts in W. Virginia",
        col.regions = inferno(100))

# library(htmlwidgets)
# 
# m1 <- mapview(wv_over_65, zcol = "value",
#         layer.name = "% age 65 and up<br>Census tracts in W. Virginia",
#         col.regions = inferno(100))
# 
# saveWidget(m1@map, "wv_over_65.html")
# 

mn_population_groups <- get_decennial(
  geography = "state",
  variables = "T01001_001N",
  state = "MN",
  year = 2020,
  sumfile = "ddhca",
  pop_group = "all",
  pop_group_label = TRUE
)


mn_population_groups

available_groups <- get_pop_groups(2020, "ddhca")

try({
get_decennial(
  geography = "county",
  variables = "T02001_001N",
  state = "MN",
  county = "Hennepin",
  pop_group = "1325",
  year = 2020,
  sumfile = "ddhca"
)
})

check_ddhca_groups(
  geography = "county", 
  pop_group = "1325", 
  state = "MN", 
  county = "Hennepin"
)

library(tidycensus)

hennepin_somali <- get_decennial(
  geography = "tract",
  variables = "T01001_001N",
  state = "MN",
  county = "Hennepin",
  year = 2020,
  sumfile = "ddhca",
  pop_group = "1325",
  pop_group_label = TRUE,
  geometry = TRUE
)


mapview(hennepin_somali, zcol = "value")

somali_dots <- as_dot_density(
  hennepin_somali,
  value = "value",
  values_per_dot = 25
)

mapview(somali_dots, cex = 0.01, layer.name = "Somali population<br>1 dot = 25 people",
        col.regions = "navy", color = "navy")

county_pop_10 <- get_decennial(
  geography = "county",
  variables = "P001001", 
  year = 2010,
  sumfile = "sf1"
)


county_pop_10

county_pop_10_clean <- county_pop_10 %>%
  select(GEOID, value10 = value) 

county_pop_10_clean

county_pop_20 <- get_decennial(
  geography = "county",
  variables = "P1_001N",
  year = 2020,
  sumfile = "dhc"
) %>%
  select(GEOID, NAME, value20 = value)

county_joined <- county_pop_20 %>%
  left_join(county_pop_10_clean, by = "GEOID") 

county_joined

county_change <- county_joined %>%
  mutate( 
    total_change = value20 - value10, 
    percent_change = 100 * (total_change / value10) 
  ) 


county_change

filter(county_change, is.na(value10))
