server <- function(input, output, session) {

  tabela_dados <- reactiveVal(NULL)

  dados_card <- eventReactive(input$buscar, {
    req(input$card_id)

    showModal(
      modalDialog(
        title = "Carregando informações",
        "Buscando informações do card, por favor aguarde.",
        footer = NULL,
        size = "m",
        easyClose = FALSE
      )
    )

    resposta_api <- get_card_info(input$card_id)
    validacao <- validate_card(resposta_api, expected_phase = input$fase)
    removeModal()

    if (validacao) {
      parent_card_id <- get_parent_card_id(resposta_api)
      parent_card <- get_card_info(parent_card_id)
      resposta_api <- make_df_fields(parent_card$data$card$fields)
      return(resposta_api)
    } else {
      return(NULL)
    }
  })

  output$card_error <- renderText({
    if (is.null(dados_card())) {
      return("ID do card inválido. Certifique-se que o card está")
    }
  })

  output$tabela <- renderDataTable({
    dados <- dados_card()
    datatable(
      dados,
      escape = FALSE,
      options = list(
        pageLength = 500, searching = FALSE, lengthChange = FALSE,
        paging = FALSE, info = FALSE, ordering = FALSE, processing = TRUE
      ),
      selection = "none",
      filter = "none",
      style = "bootstrap"
    )
  })

  output$tabela_visivel <- reactive({
    !is.null(dados_card())
  })

  outputOptions(output, "tabela_visivel", suspendWhenHidden = FALSE)

  update_card <- observeEvent(input$enviar, {
    field_ids <- switch(input$fase,
      "Aguardando Aprovação (PGR)" = list(aprovado = "documento_aprovado", justificativa = "motivos_da_rejei_o"),
      "Aguardando Aprovação (PCMSO)" = list(aprovado = "pcmso_aprovado", justificativa = "observa_o_do_pcmso")
    )

    response_aprovado <- update_card_fields(card_id = input$card_id, field_id = field_ids$aprovado, input$resposta2)
    success_response <- response_aprovado$data$updateCardField$success

    response_justificativa <- update_card_fields(card_id = input$card_id, field_id = field_ids$justificativa, input$resposta_reprovada)
    success_justificativa <- response_justificativa$data$updateCardField$success

    if (success_response & (success_justificativa | success_justificativa == "")) {
      texto_modal <- switch(input$resposta2,
        "Sim" = "Ficamos felizes por ter aprovado o documento. \n
        Aguarde só mais um pouquinho. A nossa equipe de Saúde Ocupacional já está colocando o PCMSO no forno. Entregaremos o mais rápido possível.\n
        Nos vemos em breve =D",
        "Não" = "Pedimos desculpa pelo inconveniente. O seu documento já está sendo reajustado. Retornaremos o mais rápido possível."
      )

      showModal(
        modalDialog(
          title = "Resposta enviada!",
          texto_modal,
          easyClose = TRUE,
          footer = modalButton("Fechar")
        )
      )

      updateTextInput(session, "card_id", value = "")
      updateRadioButtons(session, "resposta2", selected = character(0))
      updateTextAreaInput(session, "resposta_reprovada", value = "")
    } else {
      showModal(
        modalDialog(
          title = "Erro",
          "Houve um erro ao atualizar os dados. Verifique os dados e tente novamente.",
          easyClose = TRUE,
          footer = modalButton("Fechar")
        )
      )
    }
  })
}
