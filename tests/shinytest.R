library(shinytest)
shinytest::testApp(getwd())



shinytest2::record_test(app = getwd())
