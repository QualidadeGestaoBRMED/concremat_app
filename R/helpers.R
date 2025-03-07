get_card_phase <- function(card_title, card_table) { 
 
  
  return( card_table$fase[card_table$title == card_title])
}


get_card_id <- function(card_title, card_table) {
  return(card_table$id[card_table$title == card_title])
}


showLoadingModal <- function(texto) {
  showModal(
    modalDialog(
      title = "Carregando informações",
      texto,
      footer = NULL,
      size = "m",
      easyClose = FALSE
    )
  )
}

generate_modal_text <- function(response) {
  switch(response,
    "Sim" = "Ficamos felizes por ter aprovado o documento. Aguarde só mais um pouquinho. A nossa equipe de Saúde Ocupacional já está colocando o PCMSO no forno. Entregaremos o mais rápido possível. Nos vemos em breve =D",
    "Não" = "Pedimos desculpa pelo inconveniente. O seu documento já está sendo reajustado. Retornaremos o mais rápido possível."
  )
}



get_field_ids <- function(card_phase) {
  field_mapping <- list(
    "Aguardando Aprovação (PGR)" = list(aprovado = "documento_aprovado", justificativa = "motivos_da_rejei_o"),
    "Aguardando Aprovação (PCMSO)" = list(aprovado = "pcmso_aprovado", justificativa = "observa_o_do_pcmso")
  )

  return(field_mapping[[card_phase]])
}

clear_inputs <- function(session) {
  updateTextInput(session, "card_id", value = "")
  updateRadioButtons(session, "resposta2", selected = character(0))
  updateTextAreaInput(session, "resposta_reprovada", value = "")
}


remove_special_characters <- function(file_name) {
  # Substitui qualquer caractere que não seja uma letra, número, hífen ou sublinhado por nada
  clean_name <- gsub("[^a-zA-Z0-9_.-]", "_", file_name)
  return(clean_name)
}
