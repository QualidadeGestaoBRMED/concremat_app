readRenviron("config/.Renviron")

initialize_api <- function() {
  token <- Sys.getenv("token")
  url_pipefy <- Sys.getenv("PIPEFY_URL")
  
  conn <- GraphqlClient$new()
  conn$initialize(url = url_pipefy, headers = list(Authorization = token))
  
  return(conn)
}

conn <- initialize_api()
