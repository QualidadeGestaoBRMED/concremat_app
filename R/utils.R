get_card_info <- function(card_id) {
  query <- Query$new()
  query$query('get_card', query_get_card)
  
  res <- conn$exec(
    query$queries$get_card, 
    variables = list(card = "", card_id = card_id)
  ) |> jsonlite::fromJSON(flatten = TRUE)
  
  return(res)
}

update_card_fields <- function(card_id, field_id, new_value) {
  query <- Query$new()
  query$query("update_field", query_update_field)
  
  response <- conn$exec(
    query$queries$update_field, 
    list(card = "", field = "", card_id = card_id, field_id = field_id, field_value = new_value)
  ) |> jsonlite::fromJSON(flatten = TRUE)
  
  return(response)
}

get_parent_card_id <- function(res) {
  card_id <- res$data$card$parent_relations |> 
    unnest(cols = c(cards)) |> 
    filter(name == "Conexão SST") |> 
    pull(id)
  
  return(card_id)
}

make_df_fields <- function(fields) {
  df_fields <- fields |> as_tibble()
  
  df_fields <- df_fields |> 
    mutate(
      value = ifelse(
        str_detect(report_value, "http"),
        paste0(' <a href="', report_value, '" target="_blank" download>📥 Baixar Anexo</a>'),
        report_value
      )
    )
  
  df_fields <- df_fields |> select(name, value)
  
  return(df_fields)
}