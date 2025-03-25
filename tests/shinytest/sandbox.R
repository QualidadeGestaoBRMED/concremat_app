

res <- get_card_info("1096660688")

df_teste <- res$data$card$fields |> pivot_wider(names_from = name, values_from = report_value)

Muitphase_name <- "Aguardando Aprovação (PGR)"


teste <- make_df_return(res = res, phase_name = "Aguardando Aprovação (PGR)")



make_df_return <- function(res, phase_name) {
  
  child_cards <- get_child_card_id(res, phase_name) |> str_split(pattern = ",")
  
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
      str_extract(pattern = "(?<=Motivo: ).*")
    
    child_cards_df$`Data da Reprovação` <- paste("Reprovado em: ", child_cards_df$`Data da Reprovação`)
    
    child_cards_df <- child_cards_df |> 
      select(`Data da Reprovação`, `Motivo da Reprovação`) |> 
      rename(name = 1, value = 2)
    
    child_cards_df <- child_cards_df |> filter(value != "")
    
    return(child_cards_df)
  }
}

df_teste$`Motivo da Reprovação`  |> str_extract(pattern = "(?s)(?<=Motivo: ).*")
