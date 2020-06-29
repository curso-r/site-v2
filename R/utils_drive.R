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

#' Pega a informação da turma mais recente de um curso
#'
#' @param id 
#' @param info 
#'
#' @return
#' @export
#'
#' @examples
pegar_info_turma <- function(id, info) {
  
  pegar_turma(id) %>% 
    dplyr::pull(info)
  
}

pegar_turma <- function(id) {
  
  caminho_planilha <- baixar_dados()
  nome_curso <- pegar_info_curso(id, 'title')
  
  readxl::read_excel(caminho_planilha, sheet = "cursos") %>%
    dplyr::filter(curso == nome_curso) %>% 
    dplyr::filter(curso_id == max(curso_id))

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
  
  pegar_turma(id) %>% 
    dplyr::pull(professores) %>%
    stringr::str_split(", ?") %>% 
    purrr::flatten_chr()
  
}

#' Pega e formata a carga horária do curso
#'
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
pegar_carga_horaria <- function(id) {
  
  tab <-  pegar_turma(id) %>% 
    dplyr::select(carga_horaria, num_aulas)
  
  paste0(
    tab$num_aulas,
    ifelse(tab$num_aulas > 1, " aulas", " aula"),
    ", ",
    tab$carga_horaria,
    " horas de curso"
  )
  
}

#' Pega e formata o preço fo curso
#'
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
pegar_preco <- function(id) {
  pegar_turma(id) %>% 
    dplyr::mutate(valor = valor / 100) %>% 
    dplyr::pull(valor) %>% 
    scales::dollar(
      prefix = "R$", 
      accuracy = 0.01, 
      big.mark = ".", 
      decimal.mark = ","
    )
}


#' Verifica se existe uma turma aberta
#'
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
verificar_turma_aberta <- function(id) {
  
  tab <- pegar_turma(id)
  
  if (tab$data_inicio > as.character(Sys.Date() - 2)) {
    return("true")
  } else {
    return("false")
  }
  
}

pegar_dia_semana <- function(data) {
  data %>% 
    lubridate::wday(label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8") %>% 
    stringr::str_remove("Feira") %>%
    stringr::str_to_lower() %>% 
    stringr::str_squish() %>% 
    paste0("s")
}

#' Title
#'
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
pegar_data_curso <- function(id) {
  
  data_inicio <- pegar_info_turma(id, "data_inicio")
  data_fim <- pegar_info_turma(id, "data_fim")
  horario <- pegar_info_turma(id, "horario")
  
  paste0(
    ifelse(lubridate::day(data_inicio) == 1, "1º", lubridate::day(data_inicio)),
    " de ",
    lubridate::month(
      data_inicio, label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8"
    ) %>% tolower(),
    " a ",
    lubridate::day(data_fim),
    " de ",
    lubridate::month(
      data_fim, label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8"
    ) %>% tolower(),
    ", às ",
    pegar_dia_semana(data_inicio),
    " e ",
    pegar_dia_semana(data_fim),
    ", das ",
    horario
  )
}


