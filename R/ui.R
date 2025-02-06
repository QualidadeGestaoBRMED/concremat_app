library(shiny)
library(bslib)

ui <- fluidPage(
  
  # theme = bs_theme(
  #   version = 4,
  #   bootswatch = "flatly",
  #   primary = "#193b4f",  # Cor principal personalizada
  #   secondary = "#84aed4",  # Cor secundária personalizada
  #   base_font = "Arial"  # Fonte base personalizada
  # ),
  
  div(
    style = "display: flex; justify-content: space-between;",
    titlePanel("App Concremat: Aprovação documental"),
    img(src = "https://s3.us-east-1.amazonaws.com/news.grupobrmed.com.br/E-mailPipefy/img/top.jpg")
  ),
  
  fluidRow(
    div(
      style = "display: flex; align-items: center; column-gap: 100px; padding-left: 50px; padding-right: 50px; margin: 0px;",
      div(
        style = "display: flex; align-items: center; column-gap: 10px;",
        div(
          style = "display: flex; flex-direction: column; align-items: center; margin: 0; width: 260px;",
          p("Etapa de Aprovação"),
          selectInput(
            inputId = "fase",
            label = NULL,
            choices = list(
              "Aprovação do PGR" = "Aguardando Aprovação (PGR)",
              "Aprovação do PCMSO" = "Aguardando Aprovação (PCMSO)"
            )
          )
        ),
        
        div(
          style = "display: flex; flex-direction: column; align-items: center; margin: 0; width: 120px;",
          p("Id do Card"),
          textInput(inputId = "card_id", label = NULL)
        ),
        
        div(
          style = "margin-top: 15px;",
          actionButton("buscar", "Buscar Card", icon = icon("search"))
        )
      ),
      
      div(
        style = "display: flex; align-items: center; column-gap: 10px;",
        div(
          conditionalPanel(
            condition = "output.tabela_visivel == true",
            style = "display: flex; flex-direction: column; align-items: start; width: 200px; font-size: 15px;",
            p("Documento Aprovado:"),
            column(
              width = 5,
              shiny::radioButtons("resposta2", NULL, c("Sim", "Não"), selected = character(0))
            )
          )
        ),
        
        conditionalPanel(
          condition = "input.resposta2 == 'Não'",
          div(
            style = "display: flex; flex-direction: column; align-items: center;",
            p("Justificar Resposta"),
            textAreaInput(
              inputId = "resposta_reprovada",
              label = NULL
            )
          )
        ),
        
        conditionalPanel(
          condition = "input.resposta2 != null",
          div(
            style = "margin-top: 15px;",
            actionButton("enviar", "Enviar Resposta")
          )
        )
      )
    )
  ),
  
  textOutput("card_error"),
  #dataTableOutput("tabela"),
  reactable::reactableOutput("tabela"),
  #reactable::reactableOutput("teste")
  
)