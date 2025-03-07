
execute_pipefy_query <- function(query_name, query_string, variables = list()) {
  query <- Query$new()
  query$query(query_name, query_string)
  
  res <- conn$exec(query$queries[[query_name]], variables) |> jsonlite::fromJSON(flatten = TRUE)
  
  return(res)
}


get_card_info <- function(card_id) {
  res <- execute_pipefy_query("get_card", query_get_card, list(card = "", card_id = card_id))
  return(res)
}




update_card_fields <- function(card_id, field_id, new_value) {
  response <- execute_pipefy_query("update_field", query_update_field, 
                                    list(card = "", field = "", card_id = card_id, field_id = field_id, field_value = new_value))
  return(response$data$updateCardField$success)
}


get_parent_card_id <- function(res) {
  card_id <- res$data$card$parent_relations |> 
    unnest(cols = c(cards)) |> 
    filter(name == "Conexão SST") |> 
    pull(id)  
  return(card_id)
}


wait_for_report_to_be_done <- function(report_id) {
  
  
  status_code <- "in_progress"
  
  
  while (status_code != "done") {
    
    report_values <- execute_pipefy_query("get_report_file", get_report_file, list(report = "", report_id = report_id))
    
    
    status_code <- report_values$data$pipeReportExport$state
    
    
    Sys.sleep(2)
  }
  
  
  return(report_values$data$pipeReportExport$fileURL)
}



#########################
#
# Descontinuado
#
#######################

# get_cards_all_cards_by_phase <- function() {
  
#   response <- execute_pipefy_query("get_report_id", get_report_id)
#   report_id <- response$data$exportPipeReport$pipeReportExport$id
  
  
#   file_url <- wait_for_report_to_be_done(report_id)
  
  
#   report_df <- openxlsx::read.xlsx(file_url)
  
#   return(report_df)
# }


get_cards_all_cards_by_phase <- function(phase_id) {
  
  first_call <- execute_pipefy_query(
    "phase",
    query_get_cards_phase,
    variables = list(phase = "", phase_id = phase_id)
  )
  
  hasNextPage <- first_call$data$phase$cards$pageInfo$hasNextPage
  end_cursor <- first_call$data$phase$cards$pageInfo$startCursor
  
  while (hasNextPage) {
    
    call_api <- execute_pipefy_query(
      "next_pages",
      query_get_cards_phase_other_cards,
      variables = list(phase = "", phase_id = phase_id, after = end_cursor)
    )
    
    first_call <- append(first_call, call_api)  
    
    hasNextPage <- call_api$data$phase$cards$pageInfo$hasNextPage
    end_cursor <- call_api$data$phase$cards$pageInfo$startCursor
  }
  
  return(first_call)
}


get_child_card_id <- function(res, phase_name ) {

  child_card_name <- ifelse( phase_name == "Aguardando Aprovação (PGR)", yes = "Historico Reprovação", "Historico de Reprovação" )

  card_id <- res$data$card$child_relations |> 
    unnest(cols = c(cards)) |> 
    filter(name == child_card_name) |> 
    pull(id)
  
  return(card_id)
}
