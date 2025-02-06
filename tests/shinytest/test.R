install.packages("shinytest")

library(shinytest)

source("global.R")
recordTest(app = getwd())


shinytest2::record_test(app = getwd())


