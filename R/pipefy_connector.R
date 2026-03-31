
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
  parent_relations <- res$data$card$parent_relations
  expected_parent_names <- c("Conexão SST", "SST (CMAT)", "SST")
  
  if (is.null(parent_relations) || nrow(parent_relations) == 0) {
    warning("DEBUG Pipefy: parent_relations vazio no card selecionado.")
    return(character(0))
  }
  
  relations_expanded <- parent_relations |>
    unnest(cols = c(cards), keep_empty = TRUE)
  
  if ("name" %in% names(relations_expanded)) {
    relations_expanded <- relations_expanded |>
      filter(name %in% expected_parent_names)
  }
  
  card_id <- character(0)
  
  if ("id" %in% names(relations_expanded)) {
    card_id <- relations_expanded |>
      pull(id)
  } else if ("cards.id" %in% names(relations_expanded)) {
    card_id <- relations_expanded |>
      pull("cards.id")
  } else if ("cards" %in% names(relations_expanded)) {
    if (is.character(relations_expanded$cards)) {
      card_id <- relations_expanded$cards
    }
  }
  
  card_id <- card_id |>
    unique()
  card_id <- card_id[!is.na(card_id)]
  card_id <- card_id[card_id != ""]
  
  if (length(card_id) == 0) {
    available_names <- if ("name" %in% names(parent_relations)) {
      paste(unique(parent_relations$name), collapse = ", ")
    } else {
      "indisponível"
    }
    
    warning(
      paste0(
        "DEBUG Pipefy: nenhuma parent relation encontrada. Esperadas: [",
        paste(expected_parent_names, collapse = ", "),
        "]. Disponíveis no card: [",
        available_names,
        "]."
      )
    )
  }
  
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

  child_relations <- res$data$card$child_relations
  current_phase <- res$data$card$current_phase$name
  
  if (is.null(current_phase) || length(current_phase) == 0) {
    current_phase <- NA_character_
  }
  
  if (is.null(child_relations) || nrow(child_relations) == 0) {
    warning(
      paste0(
        "DEBUG Pipefy: child_relations vazio para card na fase esperada '",
        phase_name,
        "' (fase retornada: '",
        current_phase,
        "')."
      )
    )
    return(character(0))
  }
  
  child_card_names <- if (phase_name == "Aguardando Aprovação (PGR)") {
    c("Historico Reprovação", "Historico de Reprovação")
  } else {
    c("Historico de Reprovação", "Historico Reprovação")
  }
  
  available_names <- unique(child_relations$name)

  card_id <- child_relations |> 
    unnest(cols = c(cards)) |> 
    filter(name %in% child_card_names) |> 
    pull(id) |>
    unique()
  
  if (length(card_id) == 0) {
    warning(
      paste0(
        "DEBUG Pipefy: nenhuma child relation encontrada. Esperadas: [",
        paste(child_card_names, collapse = ", "),
        "]. Disponíveis no card: [",
        paste(available_names, collapse = ", "),
        "]."
      )
    )
  }
  
  return(card_id)
}
