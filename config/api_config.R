library(ghql)
readRenviron("config/.Renviron")


  token <- Sys.getenv("token")
  url_pipefy <- Sys.getenv("PIPEFY_URL")
  
  conn <- ghql::GraphqlClient$new()
  conn$initialize(url = "https://api.pipefy.com/graphql", headers = list(Authorization = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VyIjp7ImlkIjozMDEzODUzODksImVtYWlsIjoicHJvamV0b3NAZ3J1cG9icm1lZC5jb20uYnIiLCJhcHBsaWNhdGlvbiI6MzAwMTE0MDU5fX0.PxuY9e9RTdq25MqPGrxV10JNYSdxfPajSJM2p7qzm4vILsi7ozD8T173lRuR5yh1OnUuy4zdCQ6LIya8KKW9DQ"))
  
 



