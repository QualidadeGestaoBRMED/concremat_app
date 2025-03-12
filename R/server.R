server <- function(input, output, session) {

  card_data <- reactiveValues( all_cards = NULL )

  # Inicializar os dados ao carregar o app
  observe({
    
    pgr_cards <- get_cards_all_cards_by_phase(315351874) |> processing_phase_cards(phase = 315351874)
    pcmso_cards <- get_cards_all_cards_by_phase(315003827) |> processing_phase_cards(phase = 315003827)

    card_data$all_cards <- bind_rows(pgr_cards, pcmso_cards)

    
    
  })

  # Atualizar os cards ao clicar no botão "enviar"
  # observeEvent(input$enviar, {

  #   Sys.sleep(2)
  #   pgr_cards <- get_cards_all_cards_by_phase(315351874) |> processing_phase_cards(phase = 315351874)
  #   pcmso_cards <- get_cards_all_cards_by_phase(315003827) |> processing_phase_cards(phase = 315003827)

  #   card_data$all_cards <- bind_rows(pgr_cards, pcmso_cards)
  # })

  # Criar listas de títulos para o seletor
  pgr_choises <- reactive({
    
    req(card_data$all_cards)
    card_data$all_cards |> filter(fase == "Aguardando Aprovação (PGR)") |> pull(title)
    
  })

  pcmso_choises <- reactive({
    
    req(card_data$all_cards)
    card_data$all_cards |> filter(fase == "Aguardando Aprovação (PCMSO)") |> pull(title)
    
  })


  observe({
    req(card_data$all_cards)  # Garante que os dados estão carregados antes de atualizar
    
    pgr_list <- pgr_choises()
    pcmso_list <- pcmso_choises()
  
    shinyWidgets::updateVirtualSelect(
      inputId = "card_id",
      label = NULL,
      choices = list(
        "Aprovação PGR" = as.list(pgr_list),
        "Aprovação PCMSO" = as.list(pcmso_list)
      )
    )
    
  })
  
  


  options(shiny.maxRequestSize = 10 * 1024^2)

  dados_card <- eventReactive(input$buscar, {
    
    req(input$card_id)


    
 

    card_phase <- get_card_phase(input$card_id, card_data$all_cards) 
    id_do_card <- get_card_id(input$card_id, card_data$all_cards)
  
    
    showLoadingModal(texto = "Buscando informações do card, por favor aguarde.")

    resposta_api <- get_card_info(card_id = id_do_card)
    child_df  <- make_df_return(res = resposta_api, phase_name = card_phase)
    validacao <- validate_card(res = resposta_api, expected_phase = card_phase)
    
    removeModal()

    if (validacao) {
      
      doc_file <- get_doc_url_file( res = resposta_api, phase =  card_phase)
      parent_card_id <- get_parent_card_id(res = resposta_api)
      parent_card <- get_card_info( card_id = parent_card_id)
      resposta_api <- make_df_fields(fields =  parent_card$data$card$fields)
      resposta_api <- bind_rows( resposta_api , child_df )

      
      
      return( list(resposta_api = resposta_api , file = doc_file ) )
    } else {
      return(NULL)
    }
  })

  output$card_error <- renderText({
    if (is.null(dados_card())) {
      return("Card não está na fase selecionada ou id do card incorreto. Favor verificar ID inserido")
    }
  })

  output$tabela <- reactable::renderReactable({

    df <- dados_card()$resposta_api


    if ( !is.null( df ) ){

    reactable(df,
        columns = list(
        value = colDef( html = TRUE)
       ), 
      defaultPageSize = 100, 
      searchable = FALSE, 
      pagination = FALSE, 
      highlight = TRUE, 
      bordered = TRUE, 
      striped = TRUE, 
      compact = FALSE, 
      fullWidth = TRUE)
    } 

   
  })

  output$tabela_visivel <- reactive({
    !is.null(dados_card()$resposta_api) && length(dados_card()$resposta_api) > 0
  })

  outputOptions(output, "tabela_visivel", suspendWhenHidden = FALSE)

  update_card <- observeEvent(input$enviar, {

    showLoadingModal(texto = "Enviando respostas" )

    card_phase <- get_card_phase(input$card_id, card_data$all_cards) 
    id_do_card <- get_card_id(input$card_id, card_data$all_cards)

    

    df_anexos <- input$file_upload
    
    df_anexos$pre_url <- map_chr( remove_special_characters( df_anexos$name ), make_Presigned_url )


    df_anexos$url_send_pipefy <- map_chr( df_anexos$pre_url, processing_url_to_value  )

    df_anexos$status_code <- map2( .x = df_anexos$datapath, .y = df_anexos$pre_url, function(.x, .y){
      make_put_file(file = .x, pre_signed_url = .y )
    })

    update_card_fields( card_id = 1076253364, field_id =  "outros_documentos", df_anexos$url_send_pipefy |>  as.list() )

    

    field_ids <-get_field_ids(card_phase)

    update_card_fields( card_id = 1076253364, field_id =  field_ids$anexo , df_anexos$url_send_pipefy |>  as.list() )

    success_response <- update_card_fields(card_id = id_do_card, field_id = field_ids$aprovado, input$resposta2)    

    success_justificativa <- update_card_fields(card_id = id_do_card, field_id = field_ids$justificativa, input$resposta_reprovada)
    
    removeModal()
    

    if (success_response & (success_justificativa | success_justificativa == "")) {
      
      texto_modal <- generate_modal_text(input$resposta2)
      
      sendSweetAlert(
        title = "Resposta Enviada",
        text = texto_modal,
        type = "success"
      )
      pgr_cards <- get_cards_all_cards_by_phase(315351874) |> processing_phase_cards(phase = 315351874)
      pcmso_cards <- get_cards_all_cards_by_phase(315003827) |> processing_phase_cards(phase = 315003827)

      card_data$all_cards <- bind_rows(pgr_cards, pcmso_cards)
      

      

      clear_inputs(session)

     


      
     
        
   

    } else {
      sendSweetAlert(
        title = "Error",
        text = "Houve um erro ao atualizar os dados. Verifique os dados e tente novamente ou entre em contato com algúem da BR MED",
        type = "error"
      )      
    }
    })


  output$download_arquivo <- downloadHandler(
      filename = function() {
        
        sendSweetAlert(
          title = "Gerando Arquivo",
          text = "Seu arquivo será baixando automaticamente asism que ficar pronto",
          type = "info"

        )

        
        
        clean_link <- str_split(dados_card()$file, "\\?")
        clean_link <- clean_link[[1]][[1]]
        file_name <- basename(clean_link)
        return(file_name)
      },
      
      content = function(file) {
        download.file(url = dados_card()$file, destfile = file, mode = "wb")
      }
    )
  
  
    
  }
  
   

 
  




 

