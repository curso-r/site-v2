baixar_dados <- function(force = FALSE) {
  temp <- tempdir()
  caminho_planilha <- paste0(temp, "/dados.xlsx")
  
  id <- "1jACV67tPXktUp1rmbAurVRxzxnrhSwzBZgikwNTH8gE"
  
  if (!file.exists(caminho_planilha) | force) {
    googledrive::drive_download(
      file = googledrive::as_id(id),
      path = caminho_planilha,
      overwrite = TRUE
    )
  }
  
  return(caminho_planilha)
}

pegar_info_curso <- function(id, info) {
  
  caminho_planilha <- baixar_dados()
  
  readxl::read_excel(caminho_planilha, sheet = "catalogo-de-cursos") %>%
    dplyr::filter(id_unico == id) %>% 
    dplyr::pull(info)
  
}

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

pegar_professores_turma <- function(id) {
  
  pegar_turma(id) %>% 
    dplyr::pull(professores) %>%
    stringr::str_split(", ?") %>% 
    purrr::flatten_chr()
  
}

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

verificar_turma_aberta <- function(id) {
  
  tab <- pegar_turma(id)
  
  if (tab$data_inicio > as.character(Sys.Date() - 2)) {
    return("true")
  } else {
    return("false")
  }
  
}

pegar_dia_semana <- function(data) {
  primeiro_dia <- data %>% 
    lubridate::wday(label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8") %>% 
    stringr::str_remove("Feira") %>%
    stringr::str_to_lower() %>% 
    stringr::str_squish() %>% 
    paste0("s")
  
  segundo_dia <- ifelse(primeiro_dia == "segundas", "quartas", "quintas")
  
  paste(primeiro_dia, "e", segundo_dia)
}

pegar_data_curso <- function(id) {
  
  data_inicio <- pegar_info_turma(id, "data_inicio") %>% lubridate::dmy()
  data_fim <- pegar_info_turma(id, "data_fim") %>% lubridate::dmy()
  horario <- pegar_info_turma(id, "horario") 
  modelo <- pegar_info_turma(id, "modelo")
  
  if (modelo == "curso") {
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
      "segundas e quintas",
      # pegar_dia_semana(data_inicio),
      ", das ",
      horario
    )
  } else (
    paste0(
      ifelse(
        lubridate::day(data_inicio) == 1, 
        "1º", 
        lubridate::day(data_inicio)
      ),
      " de ",
      lubridate::month(
        data_inicio, label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8"
      ) %>% tolower(),
      " e ",
      lubridate::day(data_fim),
      " de ",
      lubridate::month(
        data_fim, label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8"
      ) %>% tolower(),
      ", dois sábados",
      ", das ",
      horario
    )
  )
  
}

pegar_id_unico <- function(nome = NULL, nome_abrev = NULL, force = FALSE) {
  
  caminho_planilha <- baixar_dados(force)
  
  tab <- readxl::read_excel(caminho_planilha, sheet = "catalogo-de-cursos")
  
  if (!is.null(nome)) {
    tab %>% 
      dplyr::filter(title == nome) %>% 
      dplyr::pull(id_unico)
  } else if (!is.null(nome_abrev)) {
    tab %>% 
      dplyr::filter(abrev == nome_abrev) %>% 
      dplyr::pull(id_unico)
  } else {
    tab %>% 
      dplyr::select(id_unico, title, abrev)
  }
    
}

pegar_unit_price <- function(id) {
  pegar_info_turma(id, 'valor') %>% 
    format(scientific = FALSE)
}

ver_ordem_cursos <- function() {
  caminho_planilha <- baixar_dados(TRUE)
  readxl::read_excel(caminho_planilha, sheet = "catalogo-de-cursos") %>% 
    dplyr::select(title, ordem)
}

