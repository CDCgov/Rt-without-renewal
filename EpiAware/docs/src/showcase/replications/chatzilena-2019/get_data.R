install.packages("outbreaks")
library(outbreaks)

# Get data

data <- outbreaks::influenza_england_1978_school
write.csv(data, 
  "EpiAware/docs/src/showcase/replications/chatzilena-2019/influenza_england_1978_school.csv")
