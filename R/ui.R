library(shiny)
library(bslib)

js <- "
$(document).ready(function(){
  var $justifique = $('#justifique');

  // Garante que o painel esteja oculto ao carregar a página
  $justifique.hide();

  $justifique.on('show', function(){
    var $this = $(this);
    if (!$this.is(':visible')) { // Só anima se estiver oculto
      $this.hide().show(500);
    }
  }).on('hide', function(){
    var $this = $(this);
    setTimeout(function(){
      $this.show().hide(500);
    });
  });
});
"

ui <- fluidPage(
  tags$head(tags$script(HTML(js))),
  
  div(
    style = "display: flex; justify-content: space-between;",
    titlePanel("App Concremat: Aprovação documental"),
    img(src = "https://s3.us-east-1.amazonaws.com/news.grupobrmed.com.br/E-mailPipefy/img/top.jpg")
  ),
  
  sidebarLayout(
    sidebarPanel(
      div(
        style = "display: flex; justify-content: space-between; align-items: end; flex-wrap: wrap;",
        div(
          style = "display: flex; column-gap: 10px; align-items: end; flex-wrap: wrap;",
          div(
            style = "display: flex; flex-direction: column; align-items: start; margin: 0; width: 260px;",
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
              dropboxWrapper = "body",
              width = 260
            )
          ),
          actionButton(
            "buscar",
            "",
            icon = icon("search"),
            style = "font-size: 12px; margin-bottom: 17px;"
          )
        ),
        
        div(
          style = "margin-top: 15px;",
         
          conditionalPanel(
            condition ="output.tabela_visivel == true", 
            shiny::downloadButton(
              outputId = "download_arquivo",label = "Baixar Arquivo",
              style = " font-size: 12px; margin-bottom: 17px;"
            )
          )
          
        )
      ),

          
      div(
        style = "display: flex; flex-direction: column;",
        
        conditionalPanel(
          id = "justifique",
          condition = "input.resposta2 == 'Não'",
          style = "display: flex; flex-direction: column;",
          div(
            style = "display: flex; flex-direction: column; align-items: start;",
            p("Justificar Resposta"),
            textAreaInput(
              width = "100%",
              inputId = "resposta_reprovada",
              label = NULL,
              resize = "none"
            )
          ),
          div(
            style = "max-height: 75px;",
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

        div(
          style = "display: flex; justify-content: space-between; align-items: center;",
          conditionalPanel(
            condition = "output.tabela_visivel == true",
            style = "display: flex; flex-direction: column; align-items: start; width: 200px; font-size: 15px;",
            p("Documento Aprovado:"),
            
            column(
              width = 5,
              shiny::radioButtons("resposta2", NULL, c("Sim", "Não"), selected = character(0))
            )
          ),
          conditionalPanel(
            condition = "input.resposta2 != null",
            div(
              style = "margin-right: 20px;",
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
  ),

)