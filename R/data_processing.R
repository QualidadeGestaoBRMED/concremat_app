library(stringi)

make_df_fields <- function(fields) {
 
  df_fields <- fields |> as_tibble()
   
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
  
  
  links <- str_split(report_value, ",")[[1]]
  links <- trimws(links)  

  
  links_html <- sapply(seq_along(links), function(i) {
    
    paste0('<a href="', links[i], '" target="_blank" download>📥 Baixar Arquivo ', i, '</a>')
  })
  
  return(paste(links_html, collapse = "<br>"))
}


get_doc_url_file <- function(res, phase){
  # tira acentos e normaliza pra ASCII
  phase_ascii <- stri_trans_general(phase, "Latin-ASCII")
  message("DEBUG phase_ascii:", phase_ascii)

  doc_selected <- switch(
    phase_ascii,
    "Aguardando Aprovacao (PGR)"  = "Documento Segurança (PDF)",
    "Aguardando Aprovacao (PCMSO)"= "Documento Saúde (PDF)",
    NULL
  )
  if (is.null(doc_selected)) {
    stop("fase não mapeada → ", phase_ascii)
  }

  url_file <- res$data$card$fields |>
    filter(name %in% doc_selected) |>
    pull(report_value)
  if (length(url_file)==0) {
    warning("nenhum campo ‘", doc_selected, "’ encontrado")
    return(NA_character_)
  }
  url_file
}


make_Presigned_url <- function( file_name ){

  res_presigned_url <- conn$exec(query = query$queries$pre_signed_url,   list( file = "", file_name = file_name )) |> fromJSON()
  
  url <- res_presigned_url$data$createPresignedUrl$url
  
  return(url)
}



processing_phase_cards <- function(list, phase) {

  phase <- as.character(phase)
  
  df_phase_cards <- lapply(list, function(x) {
    x$phase$cards$edges |> unnest(cols = c(node.fields))
  })
  
  df_phase_cards <- df_phase_cards |> 
    bind_rows() |> 
    filter(name == "Portal Concremat") |> 
    select(id = node.id, title = node.title) 

  fase <- switch(phase,
    "315351874" =  "Aguardando Aprovação (PGR)",
    "315003827" =  "Aguardando Aprovação (PCMSO)"
  )

  df_phase_cards <- df_phase_cards |> add_column( fase = fase )
  
  return(df_phase_cards)
}


make_df_return <- function(res, phase_name) {
  
  child_cards <- get_child_card_id(res, phase_name)
  
  if (length(child_cards) > 0) {
    
    child_cards_df <- lapply(child_cards, function(x) {
      motivos <- get_card_info(x)
      motivos <- pivot_wider(motivos$data$card$fields, names_from = name, values_from = report_value)
      
      if (is_column_present(df = motivos, "Outros documentos")) {
        links <- motivos |> pull('Outros documentos') |> paste_links_for_download()
        motivos$`Motivo da Reprovação` <- motivos$`Motivo da Reprovação` |> paste("<br>", links)
      }
     return(motivos) 
    })
    
    child_cards_df <- child_cards_df |> bind_rows()
    
    child_cards_df$`Motivo da Reprovação` <- child_cards_df$`Motivo da Reprovação` |> 
      str_extract(pattern = "(?s)(?<=Motivo: ).*")
    
    child_cards_df$`Data da Reprovação` <- paste("Reprovado em: ", child_cards_df$`Data da Reprovação`)
    
    child_cards_df <- child_cards_df |> 
      select(`Data da Reprovação`, `Motivo da Reprovação`) |> 
      rename(name = 1, value = 2)
    
    child_cards_df <- child_cards_df |> filter(value != "")
    
    return(child_cards_df)
  }
  
  return(tibble(name = character(), value = character()))
}

