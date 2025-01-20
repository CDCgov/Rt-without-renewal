install.packages("covidregionaldata",
  repos = "https://epiforecasts.r-universe.dev"
)

library(covidregionaldata)
library(dplyr)
library(ggplot2)
library(scales)

start_using_memoise()

# Get data

data <- get_national_data("South Korea", source = "ecdc") |>
  filter(date <= "2020-7-31") |>
  select(date, cases_new, deaths_new)
plot(data$cases_new)

write.csv(data, "EpiAware/docs/src/examples/south_korea_data.csv")
