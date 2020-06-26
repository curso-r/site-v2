baixar_dados <- function() {
  temp <- tempdir()
  caminho_planilha <- paste0(temp, "/dados.xlsx")
  
  id <- "1jACV67tPXktUp1rmbAurVRxzxnrhSwzBZgikwNTH8gE"
  
  if (!file.exists(caminho_planilha)) {
    googledrive::drive_download(
      file = googledrive::as_id(id),
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

#' Pega a informação da turma de algum curso
#'
#' @param id 
#' @param info 
#'
#' @return
#' @export
#'
#' @examples
pegar_professores_turma <- function(id) {
  
  caminho_planilha <- baixar_dados()
  
  nome_curso <- pegar_info_curso(id, 'title')
  
  readxl::read_excel(caminho_planilha, sheet = "cursos") %>%
    dplyr::filter(curso == nome_curso) %>% 
    dplyr::pull(professores) %>% 
    dplyr::last() %>% 
    stringr::str_split(", ?") %>% 
    purrr::flatten_chr()
  
}
