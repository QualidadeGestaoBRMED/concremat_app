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
  
  
  print("Valores originais de report_value:")
  print(df_fields$report_value)
  
  
  df_fields <- df_fields |> 
    rowwise() |>  
    mutate(
      report_value = trimws(report_value), 
      
      
      value = case_when(
        str_detect(report_value, "http") ~ paste_links_for_download(report_value),
        report_value == "" ~ "Nenhum valor disponível",
        TRUE ~ report_value
      )
    ) |> 
    ungroup()
  
  return(df_fields |> select(name, value))
}

paste_links_for_download <- function(report_value) {
  print(paste("Valor original de report_value:", report_value))  
  
  links <- str_split(report_value, ",")[[1]]
  links <- trimws(links) 


  print(paste( "link apóes extração", links, sep = " " ))

  # Cria links HTML
  links_html <- sapply(seq_along(links), function(i) {
    print(paste("Link atual:", links[i])) 
    paste0('<a href="', links[i], '" target="_blank" download>📥 Baixar Arquivo ', i, '</a>')
  })
  
  return(paste(links_html, collapse = "<br>"))
}



