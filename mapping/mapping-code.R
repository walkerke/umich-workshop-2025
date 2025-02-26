library(tidycensus)
library(tidyverse)
options(tigris_use_cache = TRUE)


# install.packages(c("tidycensus", "tidyverse", "mapview", "mapgl", "quarto"))

# library(tidycensus)
# 
# census_api_key("YOUR KEY GOES HERE", install = TRUE)

texas_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "TX",
  year = 2023
)

texas_income

texas_income_sf <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "TX",
  year = 2023,
  geometry = TRUE
)

plot(texas_income_sf['estimate'])

texas_income_sf

library(mapview)

mapview(
  texas_income_sf,
  zcol = "estimate"
)

library(mapview)

mapview(texas_income_sf, zcol = "estimate")

# vars <- load_variables(2023, "acs5")
# 
# View(vars)
# 

nyc_income <- get_acs(
  geography = "tract",
  variables = "B19013_001",
  state = "NY",
  county = c("New York", "Kings", "Queens",
             "Bronx", "Richmond"),
  year = 2023,
  geometry = TRUE
)


mapview(nyc_income, zcol = "estimate")

san_diego_race <- get_acs(
  geography = "tract",
  variables = c(
    Hispanic = "DP05_0075",
    White = "DP05_0082",
    Black = "DP05_0083",
    Asian = "DP05_0085"
  ),
  state = "CA",
  county = "San Diego",
  geometry = TRUE,
  year = 2023
)


san_diego_race

san_diego_race_wide <- get_acs(
  geography = "tract",
  variables = c(
    Hispanic = "DP05_0075",
    White = "DP05_0082",
    Black = "DP05_0083",
    Asian = "DP05_0085"
  ),
  state = "CA",
  county = "San Diego",
  geometry = TRUE,
  output = "wide",
  year = 2023
)

san_diego_race_wide

nyc_income_tiger <- get_acs(
  geography = "tract",
  variables = "B19013_001",
  state = "NY",
  county = c("New York", "Kings", "Queens",
             "Bronx", "Richmond"),
  year = 2023,
  cb = FALSE,
  geometry = TRUE
)

library(tigris)
library(sf)
sf_use_s2(FALSE)

nyc_erase <- erase_water(
  nyc_income_tiger,
  area_threshold = 0.5,
  year = 2023
)


mapview(nyc_erase, zcol = "estimate")

library(mapgl)
maplibre()

maplibre() |> set_projection("globe")

maricopa_age <- get_acs(
  geography = "tract",
  variables = "B01002_001",
  state = "AZ",
  county = "Maricopa",
  geometry = TRUE,
  year = 2023
)

maplibre(bounds = maricopa_age) |>
  add_fill_layer(
    id = "age",
    source = maricopa_age
  )

cont_choro <- maplibre(bounds = maricopa_age) |>
  add_fill_layer(
    id = "age",
    source = maricopa_age,
    fill_color = interpolate(
      column = "estimate",
      values = c(4, 77),
      stops = c("lightblue", "darkblue"),
      na_color = "lightgrey"
    ),
    fill_opacity = 0.7
  )

cont_choro

library(viridisLite)

colors <- viridis(5)

classed_choro <- maplibre(
  bounds = maricopa_age
) |>
add_fill_layer(
  id = "maricopa",
  source = maricopa_age,
  fill_color = step_expr(
    column = "estimate",
    base = colors[1],
    stops = colors[2:5],
    values = c(25, 40, 55, 70),
    na_color = "lightgrey"
  ),
  fill_opacity = 0.6
)

classed_choro

classed_choro |>
add_legend(
  "Median age",
  values = c(
    "Under 25",
    "25 to 40",
    "40 to 55",
    "55 to 70",
    "70 and up"
  ),
  colors = colors,
  type = "categorical"
)

choro_with_effects <- maplibre(
  bounds = maricopa_age
) |>
add_fill_layer(
  id = "maricopa",
  source = maricopa_age,
  fill_color = step_expr(
    column = "estimate",
    base = colors[1],
    stops = colors[2:5],
    values = c(25, 40, 55, 70),
    na_color = "lightgrey"
  ),
  fill_opacity = 0.6,
  tooltip = "estimate",
  hover_options = list(
    fill_opacity = 1,
    fill_color = "red"
  )
)

choro_with_effects

san_diego_race <- get_acs(
  geography = "tract",
  variables = c(
    Hispanic = "DP05_0076",
    White = "DP05_0082",
    Black = "DP05_0083",
    Asian = "DP05_0085"
  ),
  state = "CA",
  county = "San Diego",
  geometry = TRUE,
  year = 2023
)

library(sf)

san_diego_hispanic <- filter(
  san_diego_race,
  variable == "Hispanic"
)

san_diego_centers <- st_centroid(san_diego_hispanic)


grad_symbol <- maplibre(
  style = carto_style("positron"),
  bounds = san_diego_centers
) |>
  add_circle_layer(
    id = "circles",
    source = san_diego_centers,
    circle_radius = step_expr(
      column = "estimate",
      values = c(500, 1000, 1500, 2500),
      base = 2,
      stops = c(4, 6, 8, 10),
    ),
    circle_opacity = 0.6,
    circle_color = "navy",
    tooltip = "estimate"
  )

grad_symbol

grad_symbol |>
  add_legend(
    "Hispanic population",
    values = c(
      "Under 500",
      "500-1000",
      "1000-1500",
      "1500-2500",
      "2500 and up"
    ),
    sizes = c(2, 4, 6, 8, 10),
    colors = "navy",
    type = "categorical",
    circular_patches = TRUE,
    position = "top-right"
  )

san_diego_race_dots <- as_dot_density(
  san_diego_race,
  value = "estimate",
  values_per_dot = 200,
  group = "variable"
)

san_diego_race_dots

library(RColorBrewer)

groups <- unique(san_diego_race_dots$variable)
colors <- brewer.pal(length(groups), "Set1")

dot_density_map <- maplibre(
  style = carto_style("positron"),
  bounds = san_diego_race_dots
) |>
  add_circle_layer(
    id = "dots",
    source = san_diego_race_dots,
    circle_color = match_expr(
      column = "variable",
      values = groups,
      stops = colors
    ),
    circle_radius = 2
  )

dot_density_map

dot_density_map2 <- maplibre(
  style = carto_style("positron"),
  bounds = san_diego_race_dots
) |>
  add_circle_layer(
    id = "dots",
    source = san_diego_race_dots,
    circle_color = match_expr(
      column = "variable",
      values = groups,
      stops = colors
    ),
    circle_radius = interpolate(
      property = "zoom",
      values = c(9, 14),
      stops = c(1, 10)
    ),
    before_id = "watername_ocean"
  ) |>
  add_legend(
    "Race/ethnicity in San Diego<br>1 dot = 200 people",
    values = groups,
    colors = colors,
    circular_patches = TRUE,
    type = "categorical"
  )

dot_density_map2

library(dplyr)

us_value <- get_acs(
  geography = "state",
  variables = "B25077_001",
  year = 2023,
  survey = "acs1",
  geometry = TRUE,
  resolution = "5m"
) 

r <- range(us_value$estimate, na.rm = TRUE)

us_map1 <- maplibre(
  style = carto_style("positron"),
  bounds = us_value
) |> 
  add_fill_layer(
    id = "value",
    source = us_value,
    fill_color = interpolate(
      column = "estimate",
      values = r,
      stops = c("#1D00FC", "#00FF2F")
    ),
    fill_opacity = 0.7
  )

us_map1

us_map2 <- maplibre(
  style = carto_style("positron"),
  bounds = us_value
) |> 
  set_projection("globe") |> 
  add_fill_layer(
    id = "value",
    source = us_value,
    fill_color = interpolate(
      column = "estimate",
      values = r,
      stops = c("#1D00FC", "#00FF2F")
    ),
    fill_opacity = 0.7
  )

us_map2

library(tigris)

us_value_shifted <- shift_geometry(us_value)

us_map3 <- maplibre(
  style = carto_style("positron"),
  bounds = us_value_shifted
) |> 
  set_projection("globe") |> 
  add_fill_layer(
    id = "value",
    source = us_value_shifted,
    fill_color = interpolate(
      column = "estimate",
      values = r,
      stops = c("#1D00FC", "#00FF2F")
    ),
    fill_opacity = 0.7
  )

us_map3

# style_url <- "mapbox://styles/kwalkertcu/clz2wwap502f301pafh8ad1zv/draft"
# 
# us_value_shifted$tooltip <- paste0(us_value_shifted$NAME, ": $", us_value_shifted$estimate)
# 
# mapboxgl(
#   style = style_url,
#   projection = "albers",
#   center = c(-98.8, 37.68),
#   zoom = 2.5
# ) |>
#   add_fill_layer(
#     id = "value",
#     source = us_value_shifted,
#     fill_color = interpolate(
#       column = "estimate",
#       values = r,
#       stops = c("#1D00FC", "#00FF2F")
#     ),
#     fill_opacity = 0.7,
#     tooltip = "tooltip"
#   )

us_value_shifted$tooltip <- paste0(us_value_shifted$NAME, ": $", us_value_shifted$estimate)

style <- list(
  version = 8,
  sources = structure(list(), .Names = character(0)),
  layers = list(
    list(
      id = "background",
      type = "background",
      paint = list(
        `background-color` = "lightgrey"
      )
    )
  )
)

us_map4 <- maplibre(
  style = style,
  center = c(-98.8, 37.68),
  zoom = 2.5
) |> 
  add_fill_layer(
    id = "value",
    source = us_value_shifted,
    fill_color = interpolate(
      column = "estimate",
      values = r,
      stops = c("#1D00FC", "#00FF2F")
    ),
    fill_opacity = 0.7,
    tooltip = "tooltip"
  )

us_map4

library(tidycensus)
options(tigris_use_cache = TRUE)

# To run the code:
#
# us_income <- get_acs(
#   geography = "tract",
#   variables = "B19013_001",
#   state = c(state.abb, "DC", "PR"),
#   year = 2023,
#   geometry = TRUE,
#   resolution = "5m"
# )

# To read in the data:

us_income <- read_rds("data/us_tract_income.rds")

us_income

maplibre(
  style = carto_style("positron"),
  center = c(-98.5795, 39.8283),
  zoom = 3
) |>
  set_projection("globe") |>
  add_fill_layer(
    id = "fill-layer",
    source = us_income,
    fill_color = interpolate(
      column = "estimate",
      values = c(10000, 72000, 250000),
      stops = c("#edf8b1", "#7fcdbb", "#2c7fb8"),
      na_color = "lightgrey"
    ),
    fill_opacity = 0.7,
    tooltip = "estimate"
  )

maplibre(
  style = carto_style("positron"),
  center = c(-98.5795, 39.8283),
  zoom = 3
) |>
  set_projection("globe") |>
  add_source(
    id = "us-tracts",
    data = us_income,
    tolerance = 0
  ) |>
  add_fill_layer(
    id = "fill-layer",
    source = "us-tracts",
    fill_color = interpolate(
      column = "estimate",
      values = c(10000, 72000, 250000),
      stops = c("#edf8b1", "#7fcdbb", "#2c7fb8"),
      na_color = "lightgrey"
    ),
    fill_opacity = 0.7,
    tooltip = "estimate"
  )

us_county_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  year = 2023,
  geometry = TRUE,
  resolution = "5m"
)

maplibre(
  style = carto_style("positron"),
  center = c(-98.5795, 39.8283),
  zoom = 3
) |>
  set_projection("globe") |>
  add_fill_layer(
    id = "fill-layer",
    source = us_income,
    fill_color = interpolate(
      column = "estimate",
      values = c(10000, 65000, 250000),
      stops = c("#edf8b1", "#7fcdbb", "#2c7fb8"),
      na_color = "lightgrey"
    ),
    fill_opacity = 0.7,
    min_zoom = 8,
    tooltip = "estimate"
  ) |>
  add_fill_layer(
    id = "county-fill-layer",
    source = us_county_income,
    fill_color = interpolate(
      column = "estimate",
      type = "linear",
      values = c(10000, 65000, 250000),
      stops = c("#edf8b1", "#7fcdbb", "#2c7fb8"),
      na_color = "lightgrey"
    ),
    fill_opacity = 0.7,
    max_zoom = 7.99,
    tooltip = "estimate"
  ) |>
  add_continuous_legend(
    "Median household income",
    values = c("$10k", "$65k", "$250k"),
    colors = c("#edf8b1", "#7fcdbb", "#2c7fb8")
  )

library(tidycensus)
library(sf)
library(tidyverse)
library(tigris)
options(tigris_use_cache = TRUE)

dfw_counties <- counties(year = 2020) %>%
  filter(CBSAFP == "19100") %>%
  pull(COUNTYFP)

# 2010 variable lookup
vars10 <- load_variables(2010, "sf1")

dfw_pop_10 <- get_decennial(
  geography = "tract",
  state = "TX",
  county = dfw_counties,
  variables = "P001001",
  sumfile = "sf1",
  year = 2010,
  geometry = TRUE
) %>%
  st_transform(26914) %>%
  mutate(pop_density = as.numeric(value / (st_area(.) / 2589989.1738453)) )

dfw_pop_20 <- get_decennial(
  geography = "tract",
  variables = "P1_001N",
  state = "TX",
  county = dfw_counties,
  geometry = TRUE,
  year = 2020,
  sumfile = "dhc"
) %>%
  st_transform(26914) %>%
  mutate(pop_density = as.numeric(value / (st_area(.) / 2589989.1738453)) )

print(nrow(dfw_pop_10))
print(nrow(dfw_pop_20))

m10 <- maplibre(
  style = carto_style("positron"),
) |>
  fit_bounds(dfw_pop_10, animate = FALSE) |>
  add_fill_layer(
    id = "dfw10",
    source = dfw_pop_10,
    fill_color = interpolate(
      column = "pop_density",
      values = seq(0, 40000, 8000),
      stops = plasma(6)
    ),
    fill_opacity = 0.7
  ) |>
  add_legend(
    "Population density (persons/sqmi)<br>Left: 2010, Right: 2020",
    values = c("0", "8k", "16k", "24k", "32k", "40k"),
    colors = plasma(6)
  )

m20 <- maplibre(
  style = carto_style("positron"),
) |>
  add_fill_layer(
    id = "dfw20",
    source = dfw_pop_20,
    fill_color = interpolate(
      column = "pop_density",
      values = seq(0, 40000, 8000),
      stops = plasma(6)
    ),
    fill_opacity = 0.7
  )

compare(m10, m20)

m10_3d <- maplibre(
  style = carto_style("positron")
) |>
  fit_bounds(dfw_pop_10) |>
  add_fill_extrusion_layer(
    id = "dfw10",
    source = dfw_pop_10,
    fill_extrusion_color = interpolate(
      column = "pop_density",
      values = seq(0, 40000, 8000),
      stops = plasma(6)
    ),
    fill_extrusion_opacity = 0.7,
    fill_extrusion_height = get_column("pop_density")
  ) |>
  add_legend(
    "Population density (persons/sqmi)<br>Left: 2010, Right: 2020",
    values = c("0", "8k", "16k", "24k", "32k", "40k"),
    colors = plasma(6)
  )

m20_3d <- maplibre(
  style = carto_style("positron"),
) |>
  add_fill_extrusion_layer(
    id = "dfw20",
    source = dfw_pop_20,
    fill_extrusion_color = interpolate(
      column = "pop_density",
      values = seq(0, 40000, 8000),
      stops = plasma(6)
    ),
    fill_extrusion_opacity = 0.7,
    fill_extrusion_height = get_column("pop_density")
  ) |>
  add_legend(
    "Population density (persons/sqmi)<br>Left: 2010, Right: 2020",
    values = c("0", "8k", "16k", "24k", "32k", "40k"),
    colors = plasma(6)
  )

compare(m10_3d, m20_3d)
