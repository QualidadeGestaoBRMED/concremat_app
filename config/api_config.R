library(ghql)
readRenviron("config/.Renviron")


  token <- Sys.getenv("token")
  url_pipefy <- Sys.getenv("PIPEFY_URL")
  
  conn <- ghql::GraphqlClient$new()
  conn$initialize(url = url_pipefy , headers = list(Authorization =  token))
  
 



