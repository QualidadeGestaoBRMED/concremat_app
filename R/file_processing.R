make_Presigned_url <- function( file_name ){

  res_presigned_url <- execute_pipefy_query("pre_url",query_string = createPresignedUrl, variables = list( file = "", file_name = file_name ))
  
  url <- res_presigned_url$data$createPresignedUrl$url
  
  return(url)
}



processing_url_to_value <- function( PreSignedUrl ){

    caminho_arquivo <- sub("https?://[^/]+/", "", PreSignedUrl)
    caminho_arquivo <- sub("\\?.*$", "", caminho_arquivo)
  
    return(caminho_arquivo)
  }

make_put_file <- function ( file_path, pre_signed_url ){

  res <- httr::PUT(
    pre_signed_url,
    body = httr::upload_file(file_path)
    )
  
  return(res$status_code)
}



#########
#
#Função para upload de anexo
#
##########


# call_presignes_url <- function( df_files_input ){

#   df_files_input$urls <-   map_chr(df_files_input$name, function(x){
#       make_Presigned_url(x)
#       }
#     )  
  
#     df_files_input$status_code <- map2( .x = "docs/63648814.pdf", .y =  df_files_input$urls , function(.x, .y ){
#     make_put_file(file = .x , pre_signed_url = .y)
#   } )

#   return(df_files_input)
  
# }