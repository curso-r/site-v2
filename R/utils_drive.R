baixar_dados <- function() {
  temp <- tempdir()
  caminho_planilha <- paste0(temp, "/dados.xlsx")
  
  if (!file.exists(caminho_planilha)) {
    googledrive::drive_download(
      file = Sys.getenv("URL_GS_VENDAS_PAGARME"),
      path = caminho_planilha
    )
  }
  
  return(caminho_planilha)
}


#' Pega a informação de algum curso
#'
#' @param id 
#' @param info 
#'
#' @return
#' @export
#'
#' @examples
pegar_info_curso <- function(id, info) {
  
  caminho_planilha <- baixar_dados()
  
  readxl::read_excel(caminho_planilha, sheet = "catalogo-de-cursos") %>%
    dplyr::filter(id_unico == id) %>% 
    dplyr::pull(info)
  
}