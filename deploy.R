library(rsconnect)

readRenviron("config/.Renviron")

shiny_name <- Sys.getenv("shiny_name")
shiny_token <- Sys.getenv("shiny_token")
shiny_secret <- Sys.getenv("shiny_secret")

rsconnect::setAccountInfo(name = shiny_name, token = shiny_token, secret = shiny_secret)

rsconnect::deployApp(appDir = getwd(), launch.browser = T,account = "84t2xk-felipe-costa")

rsconnect::accounts()





