library(shiny)
getwd()


fs::dir_tree()

source("global.R")
source("R/ui.R")
source("R/server.R")



shinyApp(ui = ui, server = server)
