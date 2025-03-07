library(shiny)
library(bslib)



ui <- fluidPage(
  
 
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
          shinyWidgets::virtualSelectInput(
            inputId = "card_id",
            label = NULL,
            choices = list(
              "Aprovação PGR" = NULL,
              "Aprovação PCMSO" = NULL
            ),
            multiple = FALSE,
            disableOptionGroupCheckbox = FALSE,
            dropboxWrapper = "body"
          )
        ),
        
        # div(
        #   style = "display: flex; flex-direction: column; align-items: center; margin: 0; width: 120px;",
        #   p("Id do Card"),
        #   textInput(inputId = "card_id", label = NULL)
        # ),
        
        div(
          style = "margin-top: 15px;",
          actionButton("buscar", "Buscar Card", icon = icon("search"),style = "padding: 5px 10px; font-size: 12px;"  ),
         
          conditionalPanel(
            condition ="output.tabela_visivel == true", 
            shiny::downloadButton(outputId = "download_arquivo",label = "baixar arquivo",
            style = "padding: 5px 10px; font-size: 12px;")
        )
          
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
            ),
            fileInput(
              inputId = "file_upload",
              label = "Anexar arquivo" ,
              multiple = T,
              placeholder = "Selecione um arquivo",
              capture = T,
              buttonLabel = "Buscar"          

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

  mainPanel(
  
  textOutput("card_error"), 
  reactable::reactableOutput("tabela")
  )
 
  
  
)